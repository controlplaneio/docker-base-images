FROM autonomy/conform:latest AS source

#RUN ls -lasp /bin/conform

# ===

FROM controlplane/build-step-build-env-base:latest AS build-step

# ===

FROM controlplane/base-centos:latest

LABEL org.label-schema.license="MIT" \
    org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.name="controlplaneio/build-step-conform" \
    org.label-schema.vendor="controlplaneio" \
    org.label-schema.docker.schema-version="1.0"

COPY --from=build-step \
  /build-step/entrypoint.sh \
  /build-step/harden.sh \
  /

# ===

ENV COMMAND="/bin/conform"
ENV DEBUG_COMMAND="ls -lasp /workdir; cat /workdir/.conform.yaml"
ENV ARGS="enforce"

COPY --from=source /conform "${COMMAND}"


USER root
RUN DEBUG="" /harden.sh
USER user

ENTRYPOINT ["/entrypoint.sh"]
