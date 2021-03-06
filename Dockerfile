FROM gettyimages/spark:2.2.0-hadoop-2.7

# Zeppelin
ENV ZEPPELIN_PORT 8080
ENV ZEPPELIN_HOME /usr/zeppelin
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_COMMIT v0.7.3
ARG MEM="2g"
ARG MAX_PERM_SIZE="1024m"
ENV SCALA_VERSION="2.11"
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN set -ex \
 && buildDeps=' \
    git \
    bzip2 \
    nodejs \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends $buildDeps \
 && curl -sL http://archive.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz \
   | gunzip \
   | tar x -C /tmp/ \
 && git clone https://github.com/apache/zeppelin.git /usr/src/zeppelin \
 && cd /usr/src/zeppelin \
 && git checkout -q $ZEPPELIN_COMMIT \
 && dev/change_scala_version.sh "$SCALA_VERSION" \
 && MAVEN_OPTS="-Xmx$MEM -XX:MaxPermSize=$MAX_PERM_SIZE" /tmp/apache-maven-3.5.0/bin/mvn --batch-mode package -DskipTests -Pscala-$SCALA_VERSION -Pbuild-distr \
  -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,spark,markdown,angular,shell,hbase,postgresql,jdbc,python,elasticsearch,zeppelin-web,zeppelin-server,zeppelin-distribution' \
 && tar xvf /usr/src/zeppelin/zeppelin-distribution/target/zeppelin*.tar.gz -C /usr/ \
 && mv /usr/zeppelin* $ZEPPELIN_HOME \
 && mkdir -p $ZEPPELIN_NOTEBOOK_DIR \
 && mkdir -p $ZEPPELIN_HOME/logs \
 && mkdir -p $ZEPPELIN_HOME/run \
 && apt-get purge -y --auto-remove $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/src/zeppelin \
 && rm -rf /root/.m2 \
 && rm -rf /root/.npm \
 && rm -rf /root/.cache/bower \
 && rm -rf /tmp/*

RUN ln -s /usr/bin/pip3 /usr/bin/pip \
 && rm -rf /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

# S3 endpoint and accessKey/secretKey info can be set via XML
#ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/core-site.xml
RUN $SPARK_HOME/bin/spark-shell --packages org.apache.hadoop:hadoop-aws:2.7.2

# Example Notebook with basic SQL 
ADD ./examples/notebook $ZEPPELIN_NOTEBOOK_DIR

WORKDIR $ZEPPELIN_HOME
CMD ["bin/zeppelin.sh"]
