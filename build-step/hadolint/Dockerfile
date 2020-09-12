FROM hadolint/hadolint:latest AS source

RUN ls -lasp /bin/hadolint

# ===

FROM controlplane/build-step-build-env-base:latest AS build-step

# ===

FROM controlplane/base-centos:latest

LABEL org.label-schema.license="MIT" \
    org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.name="controlplaneio/build-step-hadolint" \
    org.label-schema.vendor="controlplaneio" \
    org.label-schema.docker.schema-version="1.0"

COPY --from=build-step \
  /build-step/entrypoint.sh \
  /build-step/harden.sh \
  /

# ===

ENV COMMAND="/bin/hadolint"
COPY --from=source /bin/hadolint "${COMMAND}"

USER root
RUN DEBUG="" /harden.sh
USER user

ENTRYPOINT ["/entrypoint.sh"]
