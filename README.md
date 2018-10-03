# Mariadb Galera Cluster in K8s #

### Technical details

##### Prerequites
- A working k8s cluster with glusterfs persistent storage
- kubectl, etc.

##### Creating mariadb cluster with etcd cluster
- Before creating mariadb cluster, we need to create an ETCD data store
  for storing galera cluster status
```bash
$ kubectl create -f 00-etcd-cluster.yaml
```

- After that, just run as following:
```
$ kubectl create -f 01-galera-mariadb-ss.yaml
$ kubectl get pods -n ns-galera-cluster -w
```
