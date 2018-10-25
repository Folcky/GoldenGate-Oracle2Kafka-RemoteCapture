#Install Zoo

cd /distr
if [ ! -f zookeeper-3.4.6.tar.gz ]
then
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
fi
cd /opt
tar -zxf /distr/zookeeper-3.4.6.tar.gz
cd zookeeper-3.4.6
mkdir data
cp /distr/zoo.cfg /opt/zookeeper-3.4.6/conf/

#Start Zoo
#. zkServer.sh start
#CLI
#. zkCli.sh
#Stop Zoo
#. zkServer.sh stop


