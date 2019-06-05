#!/usr/bin/env bash

for i in $(seq 0 2); \
  do kubectl exec -it -n ns-galera galera-ss-$i -- mysql -uroot -pmysql -e "select * from information_schema.GLOBAL_STATUS where VARIABLE_NAME like 'wsrep_local_index' or VARIABLE_NAME like 'wsrep_local_state_comment' or VARIABLE_NAME like 'wsrep_connected' or VARIABLE_NAME like 'wsrep_cluster_size' or VARIABLE_NAME like 'wsrep_cluster_status' or VARIABLE_NAME like 'wsrep_ready';"; \
done
