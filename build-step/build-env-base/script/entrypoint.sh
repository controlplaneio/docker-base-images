#!/bin/bash

set -Eeuxo pipefail

if [[ "${IS_IN_AUTOMATION:-}" != "" ]]; then
  echo "IS_IN_AUTOMATION env var specified. Falling-back to default entrypoint behaviour" >&2
  exec "${@:-}"
fi

if [[ -d /workdir/ ]]; then
  cd /workdir/
fi

if [[ "${DEBUG_COMMAND:-}" != "" ]]; then
  bash -Eeuxo pipefail -c "${DEBUG_COMMAND:-}" || true
fi

exec \
  "${COMMAND}" \
  $([[ "${ARGS:-}" != "" ]] && echo "${ARGS}") \
  $([[ "${@:-}" != "" ]] && echo "${@}")
