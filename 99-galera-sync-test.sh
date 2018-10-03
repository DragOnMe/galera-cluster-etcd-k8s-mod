#!/usr/bin/env bash

# 1. Create db and table - galera-ss-0
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "create database synctest; use synctest; create table test (id char(10), name varchar(20));"

# 2. Insert into table - galera-ss-0
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "use synctest; insert into test values ('aaa', 'xxx');"
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "use synctest; insert into test values ('id', 'this is my name');"
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "use synctest; select * from test;"

# 3. Show table data - galera-ss-1
kubectl exec -it -n ns-galera-etcd galera-ss-1 -- mysql -uroot -pmysql -e "use synctest; select * from test;"

# 4. Show table data - galera-ss-2
kubectl exec -it -n ns-galera-etcd galera-ss-2 -- mysql -uroot -pmysql -e "use synctest; select * from test;"

# 5. Delete table data - galera-ss-2
kubectl exec -it -n ns-galera-etcd galera-ss-2 -- mysql -uroot -pmysql -e "use synctest; delete from test where id = 'aaa';"

# 6. Show table data - galera-ss-0
kubectl exec -it -n ns-galera-etcd galera-ss-0 -- mysql -uroot -pmysql -e "use synctest; select * from test;"

# 7. Show table data - galera-ss-1
kubectl exec -it -n ns-galera-etcd galera-ss-1 -- mysql -uroot -pmysql -e "use synctest; select * from test;"
