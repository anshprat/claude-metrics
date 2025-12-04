#!/bin/bash

# Convenience wrapper for telemetry.sh using gRPC protocol
# Usage:
#   source telemetry-grpc.sh                          # gRPC on localhost
#   source telemetry-grpc.sh --host=custom-host.com   # gRPC on custom host
#
# This is equivalent to: source telemetry.sh --protocol=grpc

# Extract host argument if provided
HOST_ARG=""
for arg in "$@"; do
  case $arg in
    --host=*)
      HOST_ARG="$arg"
      ;;
  esac
done

# Source the main telemetry script with gRPC protocol
source "$(dirname "${BASH_SOURCE[0]}")/telemetry.sh" --protocol=grpc $HOST_ARG
