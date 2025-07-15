FROM tomcat:jre21-temurin-noble

# COPY /var/lib/jenkins/workspace/jenkins-container1/target/java-tomcat-maven-example.war /usr/local/tomcat/webapps/java-tomcat-maven-example.war
# COPY **/*.war /usr/local/tomcat/webapps/java-tomcat-maven-example.war

# to run app directly in the IP 
COPY **/*.war /usr/local/tomcat/webapps/ROOT.war

WORKDIR /usr/local/tomcat/bin/
EXPOSE 8080

CMD ["./catalina.sh" , "run"]

# CMD ["catalina.sh", "run"]  # yesari rakhda pani huncha 