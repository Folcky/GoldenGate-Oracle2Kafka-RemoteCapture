#Install Kafka
cd /distr
if [ ! -f kafka_2.11-0.9.0.0.tgz ]
then
 wget https://archive.apache.org/dist/kafka/0.9.0.0/kafka_2.11-0.9.0.0.tgz
fi
tar -zxf kafka_2.11-0.9.0.0.tgz -C /opt

#Start Kafka
#bin/zookeeper-server-start.sh config/zookeeper.properties
#bin/kafka-server-start.sh config/server.properties

#Check kafka
#cd /opt/kafka_2.11-0.9.0.0
#jps

#Stop Kafka
#bin/kafka-server-stop.sh config/server.properties


#Create topic
cd /opt/kafka_2.11-0.9.0.0
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic GG


#Create consumer
bin/kafka-console-consumer.sh --zookeeper localhost:2181 —topic GG --from-beginning --whitelist GG




add replicat rkafka, exttrail ./dirdat/in
start replicat rkafka
info replicat rkafka, detail

vim /opt/oggbd/ggserr.log
