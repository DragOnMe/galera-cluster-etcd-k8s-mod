# Mariadb Galera Cluster in K8s #

### Technical details

##### Prerequites
- A working k8s cluster with persistent storage(glusterfs)
- kubectl, etc.
- Tested on k8s 1.9.x~1.11.3

----------

##### Creating mariadb cluster with etcd cluster
- Before creating mariadb cluster, we need to create an ETCD data store
  for storing galera cluster status
```bash
$ kubectl apply -f 00-etcd-cluster.yaml
```

- After that, just run as following:
```
$ kubectl get pods -n ns-galera-cluster -w
```

- And then, check if etcd cluster is ok
```
$ kubectl exec -it -n ns-galera-etcd etcd0 -- etcdctl cluster-health
```

- Now create the galera cluster with statefulset
```
$ kubectl apply -f 01-galera-mariadb-ss.yaml
$ kubectl get statefulset -n ns-galera-etcd galera-ss -w
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

##### Tearing down all the cluster resourcess and namespace

- Just run the scripts for complete deletion
```
$ ./99-teardown.sh
```
