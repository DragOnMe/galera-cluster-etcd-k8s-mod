#!/usr/bin/env bash

# 1. Create db and table - galera-ss-0
echo "1. Create database & table(node 0):"
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "create database synctest; use synctest; create table test (id char(10), name varchar(20));"

# 2. Insert into table - galera-ss-0
echo "2. Insert 2 records into table(node 0):"
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "use synctest; insert into test values ('aaa', 'xxx');"
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "use synctest; insert into test values ('id', 'this is my name');"
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "select * from information_schema.GLOBAL_STATUS where VARIABLE_NAME like 'wsrep_local_index'; use synctest; select * from test;"

# 3. Show table data - galera-ss-1
echo  "3. Show data(node 1):"
kubectl exec -it -n ns-galera-etcd galera-ss-1 -- mysql -uroot -pmysql -e "select * from information_schema.GLOBAL_STATUS where VARIABLE_NAME like 'wsrep_local_index'; use synctest; select * from test;"

# 4. Show table data - galera-ss-2
echo  "4. Show data(node 2):"
kubectl exec -it -n ns-galera-etcd galera-ss-2 -- mysql -uroot -pmysql -e "select * from information_schema.GLOBAL_STATUS where VARIABLE_NAME like 'wsrep_local_index'; use synctest; select * from test;"

# 5. Delete table data - galera-ss-2
echo "5. Delete data(node 2):"
kubectl exec -it -n ns-galera-etcd galera-ss-2 -- mysql -uroot -pmysql -e "use synctest; delete from test where id = 'aaa';"

# 6. Show table data - galera-ss-0
echo  "6. Show data(node 0):"
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "select * from information_schema.GLOBAL_STATUS where VARIABLE_NAME like 'wsrep_local_index'; use synctest; select * from test;"

# 7. Show table data - galera-ss-1
echo  "7. Show data(node 1):"
kubectl exec -it -n ns-galera-etcd galera-ss-1 -- mysql -uroot -pmysql -e "select * from information_schema.GLOBAL_STATUS where VARIABLE_NAME like 'wsrep_local_index'; use synctest; select * from test;"

# 8. Show table data - galera-ss-1
echo "8. Delete database & table(node 1):"
kubectl exec -it -n ns-galera-etcd galera-ss-1 -- mysql -uroot -pmysql -e "use synctest; drop table test; drop database synctest; show databases;"
