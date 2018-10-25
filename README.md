# GoldenGate-Oracle2Kafka-RemoteCapture
Oracle DB Source -> ORacle GoldenGate for Oracle-> [Oracle GoldenGate for Bigdata + Apache Kafka_2.11-0.9.0.0]

# 0. Prerequisites

## Useful links
https://www.tutorialspoint.com/apache_kafka/apache_kafka_installation_steps.htm  
http://www.ateam-oracle.com/oracle-goldengate-big-data-adapter-apache-kafka-producer/  
https://docs.oracle.com/goldengate/bd1221/gg-bd/GADBD/GUID-2561CA12-9BAC-454B-A2E3-2D36C5C60EE5.htm#GADBD449  


## Oracle Source DB credentials
> sqlplus system/oracle@datasource:1521/xe  
> sqlplus sys/oracle@datasource:1521/xe as sysdba  

## Used Docker images
* oracle/goldengate-standard:12.3.0.1.4 (Read here https://github.com/oracle/docker-images/tree/master/OracleGoldenGate)  
* sath89/oracle-12c
* ubuntu:latest

## Docker consoles for Terminal
> docker exec -it GG-datasource-kafka bash  
> docker exec -it GG-goldengateora-kafka bash  
> docker exec -it GG-kafka-kafka bash  

# 1. Oracle DB Source Init

## 1.1. Container name
GG-datasource-kafka  

## 1.2. Database params
```sql
alter system set enable_goldengate_replication=TRUE;  
alter database add supplemental log data;  
alter database force logging;  
alter system switch logfile;  
```

## 1.3. Credentials

### 1.3.1. OGG user
```sql
CREATE USER gg_extract IDENTIFIED BY gg_extract;  
GRANT CREATE SESSION, CONNECT, RESOURCE, ALTER ANY TABLE, ALTER SYSTEM, DBA, SELECT ANY TRANSACTION TO gg_extract;
```

### 1.3.2. Transaction user
```sql
CREATE USER trans_user IDENTIFIED BY trans_user;  
GRANT CREATE SESSION, CONNECT, RESOURCE TO trans_user;  
ALTER USER trans_user QUOTA UNLIMITED ON USERS;
```

## 1.4. Data source objects
```sql
CREATE TABLE trans_user.test (  
         empno      NUMBER(5) PRIMARY KEY,  
         ename      VARCHAR2(15) NOT NULL);  


 COMMENT ON TABLE test IS 'Testing GoldenGate';
```

# 2. Oracle GoldenGate for Oracle - Configure extract 

## Container name
GG-goldengateora-kafka  

## 2.1. Extract configuration

### 2.1.1. Connect as oracle to GoldenGate instance:
> su oracle  

### 2.1.2. Run GGSCI and edit extract params file(e.g. VIM will be runned):
> **GGSCI (a3abfded7bc7) 2>** edit params getExt  
```
EXTRACT getExt
USERIDALIAS oggadmin
LOGALLSUPCOLS
TRANLOGOPTIONS EXCLUDEUSER gg_extract
TRANLOGOPTIONS DBLOGREADER
EXTTRAIL ./dirdat/in
TABLE trans_user.test;
```

### 2.1.3. Run GGSCI and register&start extract params file:
> **GGSCI (a3abfded7bc7) 2>** ADD EXTRACT getExt, TRANLOG, BEGIN NOW  
> **GGSCI (a3abfded7bc7) 2>** ADD EXTTRAIL ./dirdat/in, EXTRACT getext  
> **GGSCI (a3abfded7bc7) 2>** START EXTRACT getExt  
> **GGSCI (a3abfded7bc7) 2>** info extract getext, detail 

## 2.2. DataPump configuration

### 2.2.1. Connect as oracle to GoldenGate instance:
> su oracle  

### 2.2.2. Run GGSCI and edit extract params file(e.g. VIM will be runned):
> **GGSCI (a3abfded7bc7) 2>** edit params pumpExt  
```
EXTRACT pumpext
RMTHOST kafka, MGRPORT 7801, TIMEOUT 30
RMTTRAIL /opt/oggbd/dirdat/in
PASSTHRU
TABLE trans_user.*;
```

### 2.2.3. Run GGSCI and register&start extract params file:
> **GGSCI (a3abfded7bc7) 2>** add extract pumpext, EXTTRAILSOURCE ./dirdat/in, begin now
> **GGSCI (a3abfded7bc7) 2>** add rmttrail /ogg/oggbd/dirdat/in, extract pumpext, megabytes 50
> **GGSCI (a3abfded7bc7) 2>** start pumpext
> **GGSCI (a3abfded7bc7) 2>** info extract pumpext, detail

# 3. Apache Kafka - Configure

### Container name
GG-kafka-kafka  

### Environment variables
> export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/zookeeper-3.4.6/bin:/opt/kafka_2.11-0.9.0.0:/opt/oggbd  
> export JAVA_HOME=/usr/lib/jvm/java-8-oracle  
> export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-oracle/jre/lib/amd64/server  
> export KAFKA_HOME=/opt/kafka_2.11-0.9.0.0  
> export JRE_HOME=/usr/lib/jvm/java-8-oracle/jre  
> export OGG_HOME=/opt/oggbd  

### Necessary files
/distr/install_kafka.sh  
/distr/install_oggbd.sh  
/distr/install_zoo.sh  
/distr/zoo.cfg  

## 3.1. Install Zookeeper

### install_zoo.sh
> cd /distr  
> if [ ! -f zookeeper-3.4.6.tar.gz ]  
> then  
>  wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz  
> fi  
> cd /opt  
> tar -zxf /distr/zookeeper-3.4.6.tar.gz  
> cd zookeeper-3.4.6  
> mkdir data  
> cp /distr/zoo.cfg /opt/zookeeper-3.4.6/conf/  

## 3.2. Install Kafka

### install_kafka.sh
> cd /distr  
> if [ ! -f kafka_2.11-0.9.0.0.tgz ]  
> then  
>  wget https://archive.apache.org/dist/kafka/0.9.0.0/kafka_2.11-0.9.0.0.tgz  
> fi  
> tar -zxf kafka_2.11-0.9.0.0.tgz -C /opt  

## 3.3. Install GoldenGate for Bigdata

### install_oggbd.sh
> mkdir /opt/oggbd  
> cp /distr/OGG_BigData_Linux_x64_12.3.2.1.1.zip /opt/oggbd  
> cd /opt/oggbd  
> unzip OGG_BigData_Linux_x64_12.3.2.1.1.zip  
> tar -xf OGG_BigData_Linux_x64_12.3.2.1.1.tar  
> ggsci <<EOF  
> CREATE SUBDIRS  
> Exit  
> EOF  
> echo "PORT 7801" > ./dirprm/mgr.prm  
> ggsci <<EOF  
> START MGR  
> INFO MGR  
> Exit  
> EOF  

# 4. Oracle GoldenGate for BigData - Kafka handler - Configure replicat 

Copy all files from /distr/ogg_files/* to /opt/oggbd/dirprm
### Necessary files
/distr/ogg_files/custom_kafka_producer.properties  
/distr/ogg_files/kafka.props  
/distr/ogg_files/rkafka.prm  

> cd /opt/oggbd
> ggsci
> ggsci: add replicat rkafka, exttrail ./dirdat/in
> ggsci: start replicat rkafka
> ggsci: info replicat rkafka, detail

To check error log of the replicat:  
vim /opt/oggbd/ggserr.log

# 5. Oracle GoldenGate for Bigdata - Kafka - Emulate replication

## 5.1. Start Services

In different terminals:  
> bin/zookeeper-server-start.sh config/zookeeper.properties  
> bin/kafka-server-start.sh config/server.properties  

## 5.2. Check kafka is runned
> cd /opt/kafka_2.11-0.9.0.0  
> jps  

## 5.3. Create Kafka topic
> cd /opt/kafka_2.11-0.9.0.0  
> bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic GG  

## 5.4. Create Kafka consumer
> bin/kafka-console-consumer.sh --zookeeper localhost:2181 —topic GG --from-beginning --whitelist GG  

## 5.5. Create optional Kafka producer
> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic GG  

Here you can type any text under runned producer to check the consumer output.

## 5.6. Insert - Source
```sql
insert into trans_user.test(empno, ename) 
select max(empno)+1, max(ename) from trans_user.test;
commit;
```

## 5.7 Update - Source
```sql
update trans_user.test
set ename='so'
where empno=1
```

