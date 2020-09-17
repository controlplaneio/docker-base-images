#! /bin/bash

set -Eeuxo pipefail

pwd
ls -lasp

GIT_SECRETS=""
GIT_SECRETS_OPTIONS=""
TRUFFLEHOG=""
TRUFFLEHOG_OPTIONS=""
GITLEAKS=""
GITLEAKS_OPTIONS=""
GITTYLEAKS=""
GITTYLEAKS_OPTIONS=""

while [ $# -gt 0 ]; do
  case $1 in
  --git-secrets)
    GIT_SECRETS="true"
    ;;
  --trufflehog)
    TRUFFLEHOG="true"
    ;;
  --gitleaks)
    GITLEAKS="true"
    ;;
  --gittyleaks)
    GITTYLEAKS="true"
    ;;
  --git-secrets-options)
    shift
    GIT_SECRETS_OPTIONS="${1}"
    ;;
  --trufflehog-options)
    shift
    TRUFFLEHOG_OPTIONS="${1}"
    ;;
  --gitleaks-options)
    shift
    GITLEAKS_OPTIONS="${1}"
    ;;
  --gittyleaks-options)
    shift
    GITTYLEAKS_OPTIONS="${1}"
    ;;
  --)
    shift
    break
    ;;
  *) ARGUMENTS+=("$1") ;;
  esac
  shift
done

if [[ -z $GIT_SECRETS && -z $TRUFFLEHOG && -z $GITLEAKS && -z $GITTYLEAKS ]]; then
  if [[ -z $GIT_SECRETS_OPTIONS ]]; then
    git secrets --scan
  else
    git secrets --scan "$GIT_SECRETS_OPTIONS"
  fi

  if [[ -z $TRUFFLEHOG_OPTIONS ]]; then
    trufflehog --regex "file://${PWD}"
  else
    trufflehog --regex "${TRUFFLEHOG_OPTIONS}" "file://${PWD}"
  fi

  if [[ -z $GITTYLEAKS_OPTIONS ]]; then
    gittyleaks --find-anything
  else
    gittyleaks "$GITTYLEAKS_OPTIONS"
  fi

  if [[ -z $GITLEAKS_OPTIONS ]]; then
    gitleaks --repo-path=.
  else
    gitleaks --repo-path=. "$GITLEAKS_OPTIONS"
  fi

fi

if [[ $GIT_SECRETS == "true" ]]; then
  if [[ -z $GIT_SECRETS_OPTIONS ]]; then
    git secrets --scan
  else
    git secrets --scan "$GIT_SECRETS_OPTIONS"
  fi
fi

if [[ $TRUFFLEHOG == "true" ]]; then
  if [[ -z $TRUFFLEHOG_OPTIONS ]]; then
    trufflehog --regex "file://${PWD}"
  else
    trufflehog --regex "$TRUFFLEHOG_OPTIONS" "file://${PWD}"
  fi
fi

if [[ $GITTYLEAKS == "true" ]]; then
  if [[ -z $GITTYLEAKS_OPTIONS ]]; then
    gittyleaks --find-anything
  else
    gittyleaks "$GITTYLEAKS_OPTIONS"
  fi
fi

if [[ $GITLEAKS == "true" ]]; then
  if [[ -z $GITLEAKS_OPTIONS ]]; then
    gitleaks --repo-path=.
  else
    gitleaks --repo-path=. "$GITLEAKS_OPTIONS"
  fi
fi
