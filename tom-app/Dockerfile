FROM maven:3.8.4-openjdk-11 AS maven
WORKDIR /tmp
COPY application.properties /tmp/application.properties
RUN git clone https://github.com/Uliwazeer/Project.git && \
    cd Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr && \
    cp /tmp/application.properties ./src/main/resources/application.properties && \
    mvn clean install
FROM tomcat:9.0.75-jdk11 AS tomcat
RUN rm -fr /usr/local/tomcat/webapps/*
COPY --from=maven /tmp/Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
