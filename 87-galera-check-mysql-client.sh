#!/usr/bin/env bash

kubectl run mysql-client --image=mysql:5.7 --restart=Never --env="MYSQL_ROOT_PASSWORD=temp"

while true; do
  kubectl exec -it mysql-client -- mysql -h galera-read.ns-galera.svc.spc.local -uroot -pmysql -e 'select * from information_schema.GLOBAL_STATUS where VARIABLE_NAME like "wsrep_local_index" or VARIABLE_NAME like "wsrep_local_state_comment" or VARIABLE_NAME like "wsrep_connected" or VARIABLE_NAME like "wsrep_cluster_size" or VARIABLE_NAME like "wsrep_cluster_status" or VARIABLE_NAME like "wsrep_ready";' 
  echo '----------'
  sleep 10
done
