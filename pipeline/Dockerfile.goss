FROM controlplane/base

ENV GOSS_VERSION="v0.3.6"
USER root
COPY goss/wait-for-it.sh /usr/local/bin/
RUN \
    set -x; \
    \
    curl --fail -L "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64" \
    -o /usr/local/bin/goss \
    && chmod +rx /usr/local/bin/goss \
    && chmod +rx /usr/local/bin/wait-for-it.sh

USER user
WORKDIR /home/user

COPY ./goss-* tests/

ARG vcs_ref=unespecied
LABEL org.label-schema.name="Container with Goss" \
      org.label-schema.description="Control Plane Goss Test container" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      io.control-plane.ci-agent="circleci" 