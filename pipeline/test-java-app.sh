#!/usr/bin/env bash

# Create network
docker network create -d bridge testing > /dev/null 2>&1

# Start dependency/app to be tests
docker run -d --rm -p 8080:8080 --name javaapp --network=testing controlplane/javatest > /dev/null 2>&1

# Run the tests
docker run -it --rm --network=testing -v $(PWD):/home/user/tests controlplane/goss sh -c "wait-for-it.sh javaapp:8080 -- goss -g - validate < tests/goss-ext-java-app.yaml"

# Clean up
docker stop javaapp > /dev/null 2>&1
docker network rm testing > /dev/null 2>&1