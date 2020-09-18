#!/usr/bin/env groovy

@Library('jenkins-shared-library') _

pipelineDemo([
  stages: [
    gitSecrets          : true,
    gitCommitConformance: true,
    containerLint       : true,
    // TODO(ajm) escaping vuln
    containerBuild      : [cmd: "make build test"],
    containerPush       : [cmd: "make push"],

    // TODO(ajm): how to get image hashes to scan?
    containerScan       : false,
  ],
])
