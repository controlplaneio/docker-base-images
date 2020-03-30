# Building and Testing Docker images

One of the more common questions we get is `How do you test a Docker image?` which is a very fair question. However, why testing a docker image should be different than testing any other piece of code? In our code we usully have unit tests that validate that the code does what it should do. Those tests are run as part of the build process. Right, how do we add unti tests to our Docker images? by doing two things:

* Deciding your testing framework.
* Using a Docker multi-stage build where, yes, one of the stages is the container that will do the unit testing.

In our case, we have gone with [goss](https://github.com/aelsabbahy/goss) as our testing framework, and we have modified the `Dockerfile` of all out images to include unit testing.

The pattern is as follows:

* One or more than one stages where we compile, build and pakage our application.
* One or more than one stages where we test the previous images.
* A last image where we add some relevant metadata

## How do we handle the testing framework?

As we sais above we're using `goss` to test our docker images. Note that there's a difference between testinga  docker image and testing an application. In this repo we include a test that validates the application, but that test is not what we consider a docker image unit test.

What we do is to create a container using a container image created during a previous stage. We add our testing framework and the set of tests we want to run.

Finally, we run the tests. For example, in our `CentOS` base image we start with a stage called `base` that is the latest official image available for CenOS: 

```
FROM centos:8.1.1911 as base
```

In this stage we add and update the few dependencies that we want to include in the base layers. Then, in the next stage we validate our configurtion. This is our unit testing. This new docker image tests and validates that the base image contains all the dependencies that we need. As we have specified above we create a new image inheriting from that `base` image we've just created:

```
FROM base as test
```

Finally, we create another stage called `final` where we specify a few labels:

```
FROM base as final
ARG vcs_ref=unespecied
LABEL org.label-schema.name="Control Plane Base CenOS image" \
      org.label-schema.description="Control Plane Base CenOS image" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/controlplaneio/docker-base-images" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      io.control-plane.ci-agent="circleci" \
      io.control-plane.test="goss-passed"
```

Note that `final` does not inherit from test but from base, this is because we don't want to include our tests in our base image. We include name, description, the date when the image was built, the git repo where the `Dockerfile` lives and the commit sha (passed as an `build-arg`). This allows traceability and helps to find where the docker image was created from.

```
docker build --build-arg vcs_ref=$(git rev-parse --verify HEAD) -t controlplane/mvn:3.6.3 -f Dockerfile.mvn .
```

## What about testing the application in a container?

Testing the application happens after the docker build. You could add an extra step that validates the just built docker image by launching a docker container and running a few tests againts it. this means that you ahve to run two containers at least: one for your application, and one with the tests and the test framework.

In our case we have a docker image that contains `goss` where we can mount the tests and run them againts the container created from a just built docker image. These are the steps you have to follow to tests the new container:

* Create a docker network
* Launch a container using the new built image containing your application
* Launch the container with the testing framework and the mounted volume containing the tests
* Stop the containers (remove them if you don't launch them with the `--rm` flag)
* Remove the docker network 

## Why do you do it this way?

We want to fail early, so, if a test stage fails, the docker build will fail as well. We don't build an image that doesn't pass the tests. As simple as that. Yes, adding all these stages might seem a nuisance, but once you get used to the pattern it gets as any other unit testing of any other language.