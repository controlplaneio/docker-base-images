FROM controlplane/openjdk:8-jdk as parent

USER root
ARG MAVEN_VERSION=3.6.3
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN yum install -y which \
  && mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "/home/user/.m2"

COPY mvn/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY mvn/settings-docker.xml /usr/share/maven/ref/

RUN chmod +x /usr/local/bin/mvn-entrypoint.sh

USER user

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]

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
COPY goss-mvn.yaml goss-mvn.yaml

# First we test the dependencies/parent image
RUN goss -g - validate < goss-base.yaml
RUN goss -g - validate < goss-jdk.yaml
# Now we test the currentimage
RUN goss -g - validate < goss-mvn.yaml

#####################################################
FROM parent as final

ARG vcs_ref=unespecied
LABEL org.label-schema.name="Maven" \
      org.label-schema.description="Control Plane Maven ${MAVEN_VERSION}" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      io.controlplane.language="java" \
      io.controlplane.java.version="1.8.0_242" \
      io.controlplane.mvn.version="3.6.3" \
      io.control-plane.ci-agent="circleci" \
      io.control-plane.test="goss-passed"