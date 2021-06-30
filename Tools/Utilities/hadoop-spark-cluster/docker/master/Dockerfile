FROM irm/hadoop-cluster-base
MAINTAINER irm

WORKDIR /root

# install Spark
RUN wget http://apache.rediris.es/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz && \
    tar -xvf spark-2.4.5-bin-hadoop2.7.tgz && \
    mv spark-2.4.5-bin-hadoop2.7 /usr/local/spark && \
    rm spark-2.4.5-bin-hadoop2.7.tgz

ENV PATH=$PATH:/usr/local/spark/bin
ENV SPARK_HOME=/usr/local/spark
ENV LD_LIBRARY_PATH=/usr/local/hadoop/lib/native:$LD_LIBRARY_PATH

ADD config/spark-defaults.conf /usr/local/spark/conf
RUN chown root:root /usr/local/spark/conf/spark-defaults.conf
RUN wget https://archives.streamsets.com/transformer/3.13.0/tarball/streamsets-transformer-all-3.13.0.tgz && \
    tar -xvf streamsets-transformer-all-3.13.0.tgz && \
    mv streamsets-transformer-3.13.0 /opt && \
    rm streamsets-transformer-all-3.13.0.tgz

ADD config/bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]

EXPOSE 18080
