#!/bin/bash

kubectl exec -it -n ns-galera etcd0 -- etcdctl cluster-health
