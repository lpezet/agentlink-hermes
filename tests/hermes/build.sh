#!/bin/bash
# Builds a local Hermes Agent image with python3-yaml and other skill dependencies.
# Run once (or after Dockerfile changes): ./tests/hermes/build.sh

IMAGE="${HERMES_IMAGE:-agentlink-hermes}"
docker build -t "$IMAGE" "$(dirname "$0")"
