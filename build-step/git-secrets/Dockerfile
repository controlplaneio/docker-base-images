FROM controlplane/build-step-build-env-base:latest AS build-step

# ===

FROM ubuntu:18.04

LABEL org.label-schema.license="MIT" \
    org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.name="controlplaneio/build-step-git-secrets" \
    org.label-schema.vendor="controlplaneio" \
    org.label-schema.docker.schema-version="1.0"

RUN apt-get update && apt-get install --no-install-recommends -y \
  git=\* \
  curl=\* \
  tar=\* \
  ca-certificates=\* \
  python3=\* \
  python3-venv=\* \
  python3-pip=\* \
  python3-setuptools=\* \
  bash=\* \
  make=\* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3003
RUN git clone  https://github.com/awslabs/git-secrets \
    && cd git-secrets \
    && make install \
    && cd .. \
    && rm -rf git-secrets

RUN curl -sLo gitleaks https://github.com/zricethezav/gitleaks/releases/download/v6.1.2/gitleaks-linux-amd64 \
    && chmod a+x gitleaks \
    && mv gitleaks /usr/local/bin/gitleaks

RUN pip3 install gitdb2==3.0.0 truffleHog==2.0.99 gittyleaks==0.0.31

COPY scan.sh /scan.sh

COPY --from=build-step \
  /build-step/entrypoint.sh \
  /build-step/harden.sh \
  /
ENV COMMAND="/scan.sh"

ENTRYPOINT [ "/entrypoint.sh" ]
