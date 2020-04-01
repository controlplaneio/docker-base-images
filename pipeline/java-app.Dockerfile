#####################################################
FROM instrumenta/conftest as pre-start

COPY . /project
RUN conftest test -i Dockerfile base.Dockerfile
RUN conftest test -i Dockerfile --namespace commands base.Dockerfile


#####################################################
FROM controlplane/mvn:3.6.3 as parent

WORKDIR /home/user

USER root

RUN curl -OL https://github.com/spring-guides/gs-spring-boot/archive/2.1.6.RELEASE.tar.gz \
&& tar -xzf 2.1.6.RELEASE.tar.gz \
&& mv gs-spring-boot-2.1.6.RELEASE myapp \
&& rm 2.1.6.RELEASE.tar.gz \
&& cd myapp/complete \
&& mvn -B clean package \
	-DskipTests \
	-Dmaven.gitcommitid.skip \
	-Dmaven.exec.skip=true \
	-Dmaven.install.skip \
&& chown -R user:user /home/user

USER user

#####################################################

FROM controlplane/openjdk:8-jdk as package
COPY --from=parent  /home/user/myapp/complete/target/gs-spring-boot-0.1.0.jar /home/user/gs-spring-boot-0.1.0.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/home/user/gs-spring-boot-0.1.0.jar"]


####################################################
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
RUN goss -g - validate < goss-mvn.yaml

# ####################################################
FROM package as appTest

ENV GOSS_VERSION="v0.3.6"
USER root
RUN \
    set -x; \
    \
    curl --fail -L "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64" \
    -o /usr/local/bin/goss \
    && chmod +rx /usr/local/bin/goss

USER user
COPY goss-java-app.yaml goss-java-app.yaml
RUN goss -g - validate < goss-java-app.yaml

#####################################################
FROM package as vulcheck

USER root
ARG token=token
ADD https://get.aquasec.com/microscanner .
RUN yum install -y ca-certificates
RUN chmod +x microscanner
USER user
RUN ./microscanner $token > cve-report.txt


#####################################################
FROM package as final

COPY --from=vulcheck  /home/user/cve-report.txt /home/user/cve-report.txt
ARG vcs_ref=unespecied
LABEL org.label-schema.name="SpringBoot Test App" \
      org.label-schema.description="Control Plane SpringBoot Test App" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      io.controlplane.language="java" \
      io.controlplane.java.version="1.8.0_242" \
      io.control-plane.ci-agent="circleci" \
      io.control-plane.test="goss-passed"
