#!/usr/bin/env bash

export GALERA_NAMESPACE="ns-galera-etcd"

# 1. delete galera statefulset
kubectl delete -f 01-galera-mariadb-ss.yaml

# 2. delete persistentvolumeclaim in namespace
for i in $(seq 0 2); \
  do kubectl delete persistentvolumeclaim -n ${GALERA_NAMESPACE} mysql-datadir-galera-ss-$i; \
done

# 3. delete etcd cluster
kubectl delete -f 00-etcd-cluster.yaml

# 4. check if pv exists
sleep 20
kubectl get pv

# 5. check if gluster volume exists
#sleep 30
#heketi-cli volume lis
