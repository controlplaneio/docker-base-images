FROM controlplaneio/build-env-base:ajm-test AS build-step

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

RUN curl -sLo gitleaks https://github.com/zricethezav/gitleaks/releases/download/v4.3.1/gitleaks-linux-amd64 \
    && chmod a+x gitleaks \
    && mv gitleaks /usr/local/bin/gitleaks

RUN curl -sLo scanrepo https://github.com/UKHomeOffice/repo-security-scanner/releases/download/0.4.0/scanrepo-0.4.0-linux-amd64.tar.gz \
    && tar -xvf scanrepo \
    && mv scanrepo /usr/local/bin/scanrepo

RUN pip3 install gitdb2==3.0.0 truffleHog==2.0.99 gittyleaks==0.0.31

COPY secrets.sh /secrets.sh

COPY --from=build-step \
  /build-step/entrypoint.sh \
  /build-step/harden.sh \
  /
ENV COMMAND="/secrets.sh"

ENTRYPOINT [ "/entrypoint.sh" ]

# Suggested run invocation: docker run --rm -v $(pwd):/code -it secrets
