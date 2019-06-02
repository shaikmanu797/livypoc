FROM oraclelinux:7

LABEL maintainer="Mansoor Shaik"

ENV JAVA_HOME /usr/lib/jvm/java
ENV SPARK_HOME /opt/spark
ENV HADOOP_CONF_DIR /etc/hadoop/conf
ENV LIVY_HOME /opt/incubator-livy
ENV PATH $PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$LIVY_HOME/bin

RUN yum install -y wget unzip git hadoop-client

RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo && \
    yum install -y apache-maven

RUN cd /opt && \
    wget http://apache.claz.org/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz && \
    tar -zxvf spark-2.4.3-bin-hadoop2.7.tgz && \
    rm -f spark-2.4.3-bin-hadoop2.7.tgz && \
    ln -s /opt/spark-2.4.3-bin-hadoop2.7  /opt/spark

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    pip install pyspark

RUN cd /opt && \
    git clone https://github.com/apache/incubator-livy.git && \
    cd incubator-livy && \
    mvn -DskipTests clean package && \
    mkdir -p /opt/incubator-livy/logs /apps/livy/upload

COPY livy.conf $LIVY_HOME/conf/

RUN yum clean all; rm -rf /var/cache/yum

EXPOSE 8998/tcp

WORKDIR /apps/livy/upload

VOLUME /apps/livy/upload

ENTRYPOINT [ "sh", "-c", "livy-server", "start" ]