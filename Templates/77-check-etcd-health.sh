#!/bin/bash

kubectl exec -it -n __namespace__ etcd0 -- etcdctl cluster-health
