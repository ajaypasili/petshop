FROM ubuntu
RUN apt-get update && apt-get install -y openjdk-21-jdk git maven wget tar
WORKDIR /opt
RUN git clone https://github.com/ajaypasili/petshop.git 
RUN cd petshop  && mvn clean package
ADD https://downloads.apache.org/tomcat/tomcat-11/v11.0.24/bin/apache-tomcat-11.0.24.tar.gz /opt
RUN tar -xvf apache-tomcat-11.0.24.tar.gz
RUN cp /opt/petshop/target/*.war /opt/apache-tomcat-11.0.24/webapps/petshop.war
EXPOSE 8080
CMD ["/opt/apache-tomcat-11.0.24/bin/catalina.sh" ,"run"]
