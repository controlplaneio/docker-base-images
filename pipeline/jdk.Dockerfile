#####################################################
FROM controlplane/base-centos:latest as parent

USER root
ENV JAVA_VERSION 1.8.0
RUN yum update -y && yum install -y java-"${JAVA_VERSION}"-openjdk java-"${JAVA_VERSION}"-openjdk-devel && yum clean all
ENV JAVA_HOME /etc/alternatives/java_sdk
USER user


#####################################################

FROM parent as test

ENV GOSS_VERSION="v0.3.6"
USER root
RUN \
    set -x; \
    \
    curl --fail -L "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64" \
    -o /usr/local/bin/goss \
    && chmod +rx /usr/local/bin/goss

USER user
COPY goss-base.yaml goss-base.yaml
COPY goss-jdk.yaml goss-jdk.yaml

# First we test the dependencies/parent image
RUN goss -g - validate < goss-base.yaml
RUN goss -g - validate < goss-jdk.yaml


#####################################################
FROM parent as final

ARG vcs_ref=unespecied
LABEL org.label-schema.name="Control Plane JDK" \
      org.label-schema.description="Control Plane JDK ${JAVA_VERSION}" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      io.controlplane.language="java" \
      io.controlplane.java.version="1.8.0_242" \
      io.control-plane.ci-agent="circleci" \
      io.control-plane.test="goss-passed"
