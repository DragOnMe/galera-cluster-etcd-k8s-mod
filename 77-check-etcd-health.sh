#!/bin/bash

kubectl exec -it -n ns-galera-etcd etcd0 -- etcdctl cluster-health
