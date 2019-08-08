# Mariadb Galera Cluster in K8s with ETCD

### Technical details

A working Mariadb Galera Cluster on K8s. All galera cluster's State Snapshot Transfers(SSTs), Incremental State Transfer(SST) are implemented via etcd.

Based on https://github.com/severalnines/galera-docker-mariadb, modified and tested for Kubernetes cluster from v1.11.x to v1.13.3 

##### Prerequites
- A working k8s cluster with persistent storage(glusterfs, nfs, ...) with at least 1 default storage class
- kubectl, etc.
- Tested on k8s 1.9.x, 1.11.3, 1.13.3, 1.14.1

----------

##### Creating mariadb cluster with etcd cluster
- First, generate yaml and sh files from Template/. namespace should exist beforehand.
```
$ ./000-gen-cmd-recipe ns-galera default
```

The option 'default' means using default storage class for the PV's. If you want to use hostPath PV, use 'local' instead and then, 02-pv.yaml file will be copied from Templates/ folder.

And then, just run 000-gen-cmd-recipe!

Or else, see below 1 to 3.

###### 1.

- Before creating mariadb cluster, we need to create an ETCD data store
  for storing galera cluster status
```bash
$ kubectl apply -f 00-etcd-cluster.yaml
```

###### 2.

- And then, check if etcd cluster is ok
```
$ ./77-check-etcd-health.sh
```

- After that, just run as following:
```
$ kubectl get pods -n ns-galera -w
```

###### 3.

- Now create the galera cluster with statefulset and test by mysql client
```
$ kubectl apply -f 01-galera-mariadb-ss.yaml
$ ./87-galera-check-mysql-client.sh
```

----------

##### Check galera cluster with scripts

- Check replication status
```
$ ./88-galera-test.sh
```

- Check if replication works as expected 
```
$ ./89-galera-sync-test.sh
```

----------

##### Tearing down all the cluster resourcess whthin the namespace

- Just run the scripts for complete deletion
```
$ ./99-teardown.sh
```

Caution: If 'local' option was used, you need to delete each PVC's manually by
```
$ for i in `seq 0 2`; do kubectl delete pvc galera-pv$i-volume -n ns-galera; done
```
----------

### Managing ETCD cluster

Manual scale-in or out

##### Deleting etcd node

```
[root@kube-1 galera-cluster-etcd-k8s-mod]# kubectl get pods -n ns-galera -l app=etcd
NAME    READY   STATUS    RESTARTS   AGE
etcd0   1/1     Running   0          6h1m
etcd1   1/1     Running   0          4h12m
etcd2   1/1     Running   0          6h1m
[root@kube-1 galera-cluster-etcd-k8s-mod]# kubectl delete pod -n ns-galera etcd2
pod "etcd2" deleted
[root@kube-1 galera-cluster-etcd-k8s-mod]# kubectl delete service -n ns-galera etcd2
service "etcd2" deleted
```

```
[root@kube-1 galera-cluster-etcd-k8s-mod]# kubectl exec -it -n ns-galera etcd0 -- sh
/ # etcdctl cluster-health
member 54d49836d722ca72 is healthy: got healthy result from http://etcd1:2379
member cf1d15c5d194b5c9 is healthy: got healthy result from http://etcd0:2379
failed to check the health of member d282ac2ce600c1ce on http://etcd2:2379: Get http://etcd2:2379/health: dial tcp 10.233.41.209:2379: i/o timeout
member d282ac2ce600c1ce is unreachable: [http://etcd2:2379] are all unreachable
cluster is degraded
/ # 
/ # etcdctl member remove d282ac2ce600c1ce
Removed member d282ac2ce600c1ce from cluster
/ # etcdctl cluster-health
member 54d49836d722ca72 is healthy: got healthy result from http://etcd1:2379
member cf1d15c5d194b5c9 is healthy: got healthy result from http://etcd0:2379
cluster is healthy
```

##### Adding an etcd node(or replacement with a new etcd node just after above steps)

```
[root@kube-1 galera-cluster-etcd-k8s-mod]# kubectl exec -it -n ns-galera etcd0 -- sh
/ # etcdctl member list
54d49836d722ca72: name=etcd1 peerURLs=http://etcd1:2380 clientURLs=http://etcd1:2379 isLeader=false
cf1d15c5d194b5c9: name=etcd0 peerURLs=http://etcd0:2380 clientURLs=http://etcd0:2379 isLeader=true
/ # etcdctl member add etcd2 http://etcd2:2380
Added member named etcd2 with ID 3f64a6d9f1fb5b6a to cluster

ETCD_NAME="etcd2"
ETCD_INITIAL_CLUSTER="etcd2=http://etcd2:2380,etcd1=http://etcd1:2380,etcd0=http://etcd0:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
/ # 
/ # etcdctl member list
3f64a6d9f1fb5b6a[unstarted]: peerURLs=http://etcd2:2380
54d49836d722ca72: name=etcd1 peerURLs=http://etcd1:2380 clientURLs=http://etcd1:2379 isLeader=false
cf1d15c5d194b5c9: name=etcd0 peerURLs=http://etcd0:2380 clientURLs=http://etcd0:2379 isLeader=true
```

Edit etcd2-svc-pod.yaml:

```
apiVersion: v1
kind: Pod
metadata:
  namespace: ns-galera
  labels:
    app: etcd
    etcd_node: etcd2
  name: etcd2
spec:
  containers:
  - command:
    - /usr/local/bin/etcd
    - --name
    - etcd2
    - --initial-advertise-peer-urls
    - http://etcd2:2380
    - --listen-peer-urls
    - http://0.0.0.0:2380
    - --listen-client-urls
    - http://0.0.0.0:2379
    - --advertise-client-urls
    - http://etcd2:2379
    - --initial-cluster
    # Edit here - start : add new node URL
    - etcd0=http://etcd0:2380,etcd1=http://etcd1:2380,etcd2=http://etcd2:2380
    - --initial-cluster-state
    # Initially, "- new"
    - existing
    # Edit here - end
    image: quay.io/coreos/etcd:latest
    imagePullPolicy: IfNotPresent
    name: etcd2
    ports:
    - containerPort: 2379
      name: client
      protocol: TCP
    - containerPort: 2380
      name: server
      protocol: TCP
  restartPolicy: Never

---

apiVersion: v1
kind: Service
metadata:
  namespace: ns-galera
  labels:
    etcd_node: etcd2
  name: etcd2
spec:
  ports:
  - name: client
    port: 2379
    protocol: TCP
    targetPort: 2379
  - name: server
    port: 2380
    protocol: TCP
    targetPort: 2380
  selector:
    etcd_node: etcd2
```

```
[root@kube-1 galera-cluster-etcd-k8s-mod]# kubectl apply -f etcd2-svc-pod.yaml 
pod/etcd2 created
service/etcd2 created
```

```
[root@kube-1 galera-cluster-etcd-k8s-mod]# kubectl exec -it -n ns-galera etcd0 -- sh
/ # etcdctl member list
3f64a6d9f1fb5b6a: name=etcd2 peerURLs=http://etcd2:2380 clientURLs=http://etcd2:2379 isLeader=false
54d49836d722ca72: name=etcd1 peerURLs=http://etcd1:2380 clientURLs=http://etcd1:2379 isLeader=false
cf1d15c5d194b5c9: name=etcd0 peerURLs=http://etcd0:2380 clientURLs=http://etcd0:2379 isLeader=true
/ # 
/ # etcdctl cluster-health
member 3f64a6d9f1fb5b6a is healthy: got healthy result from http://etcd2:2379
member 54d49836d722ca72 is healthy: got healthy result from http://etcd1:2379
member cf1d15c5d194b5c9 is healthy: got healthy result from http://etcd0:2379
cluster is healthy
/ # 
```
