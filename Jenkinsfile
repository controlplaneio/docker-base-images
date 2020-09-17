#!/usr/bin/env groovy

@Library('jenkins-shared-library') _

pipelineDemo([
  stages: [
    gitSecrets          : true,
    gitCommitConformance: true,
    containerLint       : true,
    // TODO(ajm) escaping vuln
    containerBuild      : [cmd: "make build test"],

    // TODO(ajm): how to get image hashes to scan?
    // containerScan       : true,
    containerPush       : [cmd: "make push"],
  ],
])
