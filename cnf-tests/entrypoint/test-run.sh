#!/bin/bash

if [[ -z "$SUITES" ]]; then
  SUITES=("configsuite" "validationsuite" "cnftests")
else
  SUITES=($SUITES)
fi

if [ "$FOCUS_TESTS" != "" ]; then
  FOCUS="-ginkgo.focus="$(echo "$FOCUS_TESTS" | tr ' ' '|')
fi

if [ "$SKIP_TESTS" != "" ]; then
	SKIP="-ginkgo.skip="$(echo "$SKIP_TESTS" | tr ' ' '|')
fi

# Validate SUITES variable is valid
for SUITE in "${SUITES[@]}"; do
  case $SUITE in
    "configsuite")
      ;;
    "validationsuite")
      ;;
    "cnftests")
      ;;
    *)
      echo "Invalid suite name: $SUITE"
      exit 1
      ;;
  esac
done

# Pring the test run Configurations
echo "--------------Test Run Configurations--------------"
echo "Skip the following: $SKIP"
echo "Focus the following: $FOCUS"
echo "Run the following ginkgo params: $GINKGO_PARAMS"
echo "Report path for JUnit: $JUNIT_REPORT_PATH"
echo "Report path for failed tests (k8sreporter): $TESTS_REPORTS_PATH"
echo "---------------------------------------------------"

if [[ ! -z "$JUNIT_REPORT_PATH" ]]; then
  JUNIT_REPORT_PATH="-junit $JUNIT_REPORT_PATH"
fi

if [[ ! -z "$TESTS_REPORTS_PATH" ]]; then
  TESTS_REPORTS_PATH="-report $TESTS_REPORTS_PATH"
fi

for SUITE in "${SUITES[@]}"; do
# If the FEATURES variable is empty, run all the features for suite
  if [[ -z "$FEATURES" ]]; then
    case $SUITE in
      "configsuite")
        SUITE_FEATURES=("nto")
        ;;
      "validationsuite")
        SUITE_FEATURES=("cluster" "metallb")
        ;;
      "cnftests")
        SUITE_FEATURES=("integration" "metallb" "nto" "ptp-parallel" "ptp-serial" "sriov")
        ;;
      *)
        echo "Invalid suite name: $SUITE"
        exit 1
        ;;
    esac
  else
    SUITE_FEATURES=($FEATURES)
  fi

  echo "Now running suite ($SUITE) with the feature(s) (${SUITE_FEATURES[@]})"
  for FEATURE in "${SUITE_FEATURES[@]}"; do
    TEST_FILE="cnf-tests/bin/$SUITE/$FEATURE.test"
    if [[ -f "$TEST_FILE" ]]; then
      ./"$TEST_FILE" $JUNIT_REPORT_PATH $TESTS_REPORTS_PATH $FOCUS $SKIP $GINKGO_PARAMS
    else
      echo "Invalid feature name for suite $SUITE: $FEATURE"
      exit 1
    fi
  done
done
