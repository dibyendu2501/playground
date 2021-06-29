FROM openjdk:11-jdk-slim as development

ENV HOME=/home/java
WORKDIR /app
RUN useradd --create-home --home-dir $HOME --uid 1000 --gid 0 java && \
    chown java:root /app && \
    chmod g=u /app $HOME
USER java:root

ENV GRADLE_USER_HOME="/home/java/.gradle" \
    GRADLE_OPTS="-Dorg.gradle.daemon=false"
COPY --chown=java:root gradlew ./
COPY --chown=java:root gradle ./gradle/
RUN ./gradlew

COPY --chown=java:root ./ ./
ARG version="local"

USER root:root
RUN apt-get update && \
    apt-get -y install curl && \
    mkdir actions-runner && \
    cd actions-runner && \
    curl -o actions-runner-linux-x64-2.278.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.278.0/actions-runner-linux-x64-2.278.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64-2.278.0.tar.gz

USER java:root
#RUN ./gradlew build testClasses -x test -Pversion=${version}

# ENTRYPOINT ["./gradlew"]
# CMD ["test", "integTest", "codeCoverage" ,"testReport", "jacocoTestCoverageVerification"]

###

FROM openjdk:11-jre-slim as production

ENV HOME=/home/java
WORKDIR /app
RUN useradd --create-home --home-dir $HOME --uid 1000 --gid 0 java && \
    chown java:root /app && \
    chmod g=u /app $HOME
USER java:root

COPY --from=development --chown=java:root /app/build/libs/*.jar ./

ADD --chown=java:root https://artifactory.appdirect.tools/artifactory/repo/com/datadoghq/dd-java-agent/0.68.0/dd-java-agent-0.68.0.jar /app/lib/dd-java-agent.jar
ENV JAVA_OPTS="-javaagent:/app/lib/dd-java-agent.jar"

EXPOSE 9090
EXPOSE 9091
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar *.jar"]