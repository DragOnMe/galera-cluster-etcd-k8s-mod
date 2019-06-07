#!/usr/bin/env bash

export GALERA_NAMESPACE="__namespace__"

# 1. delete galera statefulset
kubectl delete -f 01-galera-mariadb-ss.yaml

# 2. delete persistentvolumeclaim in namespace
for i in $(seq 0 2); \
  do kubectl delete persistentvolumeclaim -n ${GALERA_NAMESPACE} mysql-datadir-galera-ss-$i; \
done

# 3. delete etcd cluster
kubectl delete -f 00-etcd-cluster.yaml

# 4. check if pv exists
sleep 10
kubectl get pv
kubectl delete -f 02-pv.yaml
echo "You need to delete each volume directory by hand if used local hostPath volume by command like below:"
echo "for i in \`seq 1 5\` ; do ssh root@kube-\$i \"hostname && rm -rf /mnt/data/${GALERA_NAMESPACE:3}-pv?-volume\"; done"

# 5. check if gluster volume exists
#sleep 30
#heketi-cli volume lis
