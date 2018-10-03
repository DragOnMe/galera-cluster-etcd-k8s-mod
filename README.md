# Maraidb Galera Cluster in K8s Cluster using MariaDB 10.1 Docker Image (Galera) #


## Overview ##

The image supports running MariaDB 10.1 (Galera is included) with Docker orchestration tool like Docker Engine Swarm Mode and Kubernetes and requires an etcd (standalone or cluster) to run homogeneously. It can also run on a standalone environment.

## Requirement ##

A healthy etcd cluster. Please refer to Severalnines' [blog post](http://severalnines.com/blog/mysql-docker-deploy-homogeneous-galera-cluster-etcd) on how to setup this.

## Image Description ##

To pull the image, simply:

```bash
$ docker pull severalnines/mariadb
```

The image consists of MariaDB 10.1 (Galera ready) and all of its components:
* MariaDB client package.
* Percona Xtrabackup.
* jq - Lightweight and flexible command-line JSON processor.
* report_status.sh - report Galera status to etcd every `TTL`.
* healthcheck.sh
