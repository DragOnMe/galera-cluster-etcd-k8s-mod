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

###1.

- Before creating mariadb cluster, we need to create an ETCD data store
  for storing galera cluster status
```bash
$ kubectl apply -f 00-etcd-cluster.yaml
```

###2.

- And then, check if etcd cluster is ok
```
$ ./77-check-etcd-health.sh
```

- After that, just run as following:
```
$ kubectl get pods -n ns-galera -w
```

###3.

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

##### Tearing down all the cluster resourcess and namespace

- Just run the scripts for complete deletion
```
$ ./99-teardown.sh
```

Caution: If 'local' option was used, you need to delete each PVC's manually by
```
$ for i in `seq 0 2`; do kubectl delete pvc galera-pv$i-volume -n ns-galera; done
```
