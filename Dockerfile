################################
# Docker image for CI automation tasks using Tekton CI
#
# Contains basic tooling: java mvn kubectl helm tkn mysql-client jq git-crypt
################################
# build via:
# DOCKER_REPO=julianweberdev
# IMAGE=ubuntu-ci
# TAG=latest

# docker build -t "$DOCKER_REPO/$IMAGE:$TAG" .
# run bash in container via:
# docker run --name ci -it --rm "$DOCKER_REPO/$IMAGE:$TAG"

# run on k8s cluster:
# kubectl run ubuntu-ci --rm -i --tty --image="$DOCKER_REPO/$IMAGE:$TAG" --command /bin/bash

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

ARG MAVEN_VERSION=3.6.3
ARG TKN_CLI_VERSION="0.17.0"
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

# packages
RUN apt-get update && apt-get install -y curl gnupg && \
  rm -rf /var/lib/apt/lists/*

# add repos
## kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list

## helm
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add -
RUN echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

RUN apt-get update && apt-get install -y openjdk-8-jdk \
  git jq ant ca-certificates-java findutils apt-transport-https gnupg2 git-crypt \
  dnsutils kubectl helm mysql-client nano && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer

# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Install maven
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Install tkn cli for tekton interaction
RUN curl -LO https://github.com/tektoncd/cli/releases/download/v${TKN_CLI_VERSION}/tkn_${TKN_CLI_VERSION}_Linux_x86_64.tar.gz && \
  tar xvzf tkn_${TKN_CLI_VERSION}_Linux_x86_64.tar.gz -C /usr/bin/ tkn && rm tkn_${TKN_CLI_VERSION}_Linux_x86_64.tar.gz

CMD ["/bin/bash"]