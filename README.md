# docker-base-images

Docker base images

# Purpose

- no best practice, this is dependent on the policies in the company
- this is an opinionated repo to emulate enterprise base image ownership hierarchies
  - build server agnostic, makefile-driven
  - intended to model an enterprise build server with different teams owning different images
  - suitable for a PR-based workflow for base image rebuild jobs to raise a PR against descendent images (require a manifest of those image)
  - 
- the underlying build server doesn't matter
- business process and workflows, especially responses to vulnerabilities, are not in scope
  - bureaucracy and politics are the killers to this workflow
  - empowering users and other teams is all-important
  - showing that the new platform and workflow automation allows them to focus on the important things, rather than replacing them
- **TODO**
  - exception handling
  - base image rebuild notification to consumers
  - test suite bundling (in-container in `/test`, in repo under subdirectory of folder with Dockerfile)

## Pros and Cons

| Monorepo                          | Individual Repos                                    |
| --------------------------------- | --------------------------------------------------- |
| Single place to see for all tests | A view on all tests is distributed across all repos |
| ...                               |                                                     |
|                                   |                                                     |



## Testing

- goss is bundled in the base container
- goss use cases
  - testing image
    - file system inspection
    - application startup
  - health checking in Kubernetes

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
