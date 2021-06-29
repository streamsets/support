FROM streamsets/datacollector:latest

WORKDIR /etc/sdc

COPY --chown=sdc:sdc  /sdc_config/sdc.properties sdc.properties
COPY --chown=sdc:sdc  /sdc_config/form-realm.properties form-realm.properties
USER root
RUN chmod -R 755 /opt/java/openjdk/jre/lib/security/cacerts
RUN keytool -export -alias sdc -file mysdccert -keystore keystore.jks
RUN keytool -import -alias sdc -file mysdccert -noprompt -keystore /opt/java/openjdk/jre/lib/security/cacerts -trustcacerts -storepass changeit

