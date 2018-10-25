# GoldenGate-Oracle2Kafka-RemoteCapture
Oracle DB Source -> ORacle GoldenGate for Oracle-> [Oracle GoldenGate for Bigdata + Apache Kafka_2.11-0.9.0.0]

# 0. Prerequisites

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

## Conatainer name
GG-datasource-kafka  

## Database params
```sql
alter system set enable_goldengate_replication=TRUE;  
alter database add supplemental log data;  
alter database force logging;  
alter system switch logfile;  
```

## Credentials

### OGG user
```sql
CREATE USER gg_extract IDENTIFIED BY gg_extract;  
GRANT CREATE SESSION, CONNECT, RESOURCE, ALTER ANY TABLE, ALTER SYSTEM, DBA, SELECT ANY TRANSACTION TO gg_extract;
```

### Transaction user
```sql
CREATE USER trans_user IDENTIFIED BY trans_user;  
GRANT CREATE SESSION, CONNECT, RESOURCE TO trans_user;  
ALTER USER trans_user QUOTA UNLIMITED ON USERS;
```

## Data source objects
```sql
CREATE TABLE trans_user.test (  
         empno      NUMBER(5) PRIMARY KEY,  
         ename      VARCHAR2(15) NOT NULL);  


 COMMENT ON TABLE test IS 'Testing GoldenGate';
```

# 2. Oracle GoldenGate for Oracle - Configure extract 

## Conatainer name
GG-goldengateora-kafka  

## 2.1. Extract configuration

### Connect as oracle to GoldenGate instance:
> su oracle  

### Run GGSCI and edit extract params file(e.g. VIM will be runned):
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

### Run GGSCI and register&start extract params file:
> **GGSCI (a3abfded7bc7) 2>** ADD EXTRACT getExt, TRANLOG, BEGIN NOW  
> **GGSCI (a3abfded7bc7) 2>** ADD EXTTRAIL ./dirdat/in, EXTRACT getext  
> **GGSCI (a3abfded7bc7) 2>** START EXTRACT getExt  
> **GGSCI (a3abfded7bc7) 2>** info extract getext, detail 

## 2.2. DataPump configuration

### Connect as oracle to GoldenGate instance:
> su oracle  

### Run GGSCI and edit extract params file(e.g. VIM will be runned):
> **GGSCI (a3abfded7bc7) 2>** edit params pumpExt  
```
EXTRACT pumpext
RMTHOST kafka, MGRPORT 7801, TIMEOUT 30
RMTTRAIL /opt/oggbd/dirdat/in
PASSTHRU
TABLE trans_user.*;
```

### Run GGSCI and register&start extract params file:
> **GGSCI (a3abfded7bc7) 2>** add extract pumpext, EXTTRAILSOURCE ./dirdat/in, begin now
> **GGSCI (a3abfded7bc7) 2>** add rmttrail /ogg/oggbd/dirdat/in, extract pumpext, megabytes 50
> **GGSCI (a3abfded7bc7) 2>** start pumpext
> **GGSCI (a3abfded7bc7) 2>** info extract pumpext, detail

# 3. Apache Kafka - Configure

## Environment variables
> export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/zookeeper-3.4.6/bin:/opt/kafka_2.11-0.9.0.0:/opt/oggbd  
> export JAVA_HOME=/usr/lib/jvm/java-8-oracle  
> export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-oracle/jre/lib/amd64/server  
> export KAFKA_HOME=/opt/kafka_2.11-0.9.0.0  
> export JRE_HOME=/usr/lib/jvm/java-8-oracle/jre  
> export OGG_HOME=/opt/oggbd  

## Conatainer name
GG-kafka-kafka  

### Neccesary files
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

