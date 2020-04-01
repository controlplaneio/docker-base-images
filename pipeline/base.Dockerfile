#####################################################
FROM instrumenta/conftest as pre-start

COPY . /project
RUN conftest test -i Dockerfile base.Dockerfile
# RUN conftest test -i Dockerfile --namespace commands base.Dockerfile


#####################################################
FROM centos:8.1.1911 as base

USER root
RUN yum -y upgrade \
    && rm -rf /var/cache/yum \
    && yum clean all


#####################################################
FROM base as hardening

RUN \
    groupadd --system --gid 30000 user && \
    useradd --system --shell /sbin/nologin --uid 30000 --gid 30000 user

WORKDIR /home/user


#####################################################
FROM hardening as test


ENV GOSS_VERSION="v0.3.6"
USER root
RUN \
    set -x; \
    \
    curl --fail -L "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64" \
    -o /usr/local/bin/goss \
    && chmod +rx /usr/local/bin/goss

USER user
COPY goss-base.yaml goss.yaml
RUN goss -g - validate < goss.yaml


#####################################################

FROM hardening as final

ARG vcs_ref=unespecied
LABEL org.label-schema.name="Control Plane Base CenOS image" \
      org.label-schema.description="Control Plane Base CenOS image" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      io.control-plane.ci-agent="circleci" \
      io.control-plane.test="goss-passed"
