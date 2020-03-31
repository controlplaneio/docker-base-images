# docker-base-images

Docker base images

# Purpose

- no best practice, this is dependent on the policies in the company
- this is an opinionated repo to 
- the underlying build server doesn't matter
- business process and workflows, especially responses to vulnerabilities, are not in scope
  - bureaucracy and politics are the killers to this workflow
  - empowering users and other teams is all-important
  - showing that the new platform and workflow automation allows them to focus on the important things, rather than replacing them

## Build

```bash
make build
make build-all
make build-base
make build-base-centos
make build-jre
```

## Test

```bash
make test
make test-all
make test-base
make test-base-centos
make test-jre
```

## Push

```bash
make push
make push-all
make push-base
make push-base-centos
make push-jre
```
