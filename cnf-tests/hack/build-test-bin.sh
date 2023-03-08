#!/bin/bash

set -e
set +x

. $(dirname "$0")/common.sh

if ! which go; then
  echo "No go command available"
  exit 1
fi

GOPATH="${GOPATH:-~/go}"
export GOFLAGS="${GOFLAGS:-"-mod=vendor"}"

export PATH=$PATH:$GOPATH/bin
DONT_REBUILD_TEST_BINS="${DONT_REBUILD_TEST_BINS:-false}"

if ! which ginkgo; then
	echo "Downloading ginkgo tool"
	go install -mod=readonly github.com/onsi/ginkgo/v2/ginkgo@v2.8.4
fi

mkdir -p bin/cnftests
mkdir -p bin/configsuite
mkdir -p bin/validation


function build_and_move_suite {
  suite=$1
  component=$2
  source=$3
  target./bin/${suite}/${component}
  if [ "$DONT_REBUILD_TEST_BINS" == "false" ] || [ ! -f "$target" ]; then
    ginkgo build ./testsuites/"$suite"
    mv ./testsuites/"$suite"/"$suite".test "$target"
  fi
}

build_and_move_suite "cnftests" "integration" "./testsuites/e2esuite"
build_and_move_suite "cnftests" "metallb" "metallb-operator/test/e2e/functional/tests"
build_and_move_suite "cnftests" "nto-performance" "cluster-node-tuning-operator/test/e2e/performanceprofile/functests/1_performance"
build_and_move_suite "cnftests" "nto-latency" "cluster-node-tuning-operator/test/e2e/performanceprofile/functests/4_latency"
build_and_move_suite "cnftests" "ptp-parallel" "ptp-operator/test/conformance/parallel"
build_and_move_suite "cnftests" "ptp-serial" "ptp-operator/test/conformance/serial"
build_and_move_suite "cnftests" "sriov" "sriov-network-operator/test/conformance/tests"

build_and_move_suite "configsuite" "nto" "cluster-node-tuning-operator/test/e2e/performanceprofile/functests/0_config"

build_and_move_suite "validationsuite" "cluster" "./testsuites/validationsuite"
build_and_move_suite "validationsuite" "metallb" "metallb/metallb-operator/test/e2e/validation/tests"


if [ "$DONT_REBUILD_TEST_BINS" == "false" ] || [ -f ./cnf-tests/bin/mirror ]; then
  go build -o ./bin/mirror mirror/mirror.go
fi
