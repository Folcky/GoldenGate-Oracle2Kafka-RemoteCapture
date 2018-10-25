# GoldenGate-Oracle2Kafka-RemoteCapture
Oracle DB Source -> ORacle GoldenGate for Oracle-> [Oracle GoldenGate for Bigdata + Apache Kafka_2.11-0.9.0.0]

# 0. Prerequisites

## Oracle Source DB credentials
> sqlplus system/oracle@datasource:1521/xe  
> sqlplus sys/oracle@datasource:1521/xe as sysdba  

## Used Docker images
* oracle/goldengate-standard:12.3.0.1.4 (Read here https://github.com/oracle/docker-images/tree/master/OracleGoldenGate)  
* sath89/oracle-12c

## Docker consoles for Terminal
> docker exec -it GG-datasource-kafka bash  
> docker exec -it GG-goldengateora-kafka bash  
> docker exec -it GG-kafka-kafka bash  

# 1. Oracle DB Source Init

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
