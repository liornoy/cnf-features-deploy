#!/bin/bash

. $(dirname "$0")/common.sh

export PATH=$PATH:$GOPATH/bin
export failed=false
export failures=()
export TEST_SUITES=${TEST_SUITES:-'cnftests, configsuite, validationsuite'}
# In CI we don't care about cleaning the profile, because we may either throw the cluster away
# or need to run the tests again. In both cases the execution will be faster without deleting the profile.
export CLEAN_PERFORMANCE_PROFILE="false"

# metallb-operator init var
export IS_OPENSHIFT="${IS_OPENSHIFT:-true}"




#mkdir -p "$TESTS_REPORTS_PATH"
EXEC_TESTS="cnf-tests/entrypoint/test-run.sh $SKIP $FOCUS $GINKGO_PARAMS -junit $TESTS_REPORTS_PATH -report $TESTS_REPORTS_PATH"


reports="cnftests_failure_report.log setup_failure_report.log validation_failure_report.log"
for report in $reports; do 
  if [[ -f "$TESTS_REPORTS_PATH/$report" || -d "$TESTS_REPORTS_PATH/$report" ]]; then  
    tar -czf "$TESTS_REPORTS_PATH/$report.""$(date +"%Y-%m-%d_%T")".gz -C "$TESTS_REPORTS_PATH" "$report" --remove-files --force-local
  fi
done

if ! $EXEC_TESTS; then
  failed=true
  failures+=( "Tier 2 tests for $FEATURES" )
fi

if $failed; then
  echo "[WARN] Tests failed:"
  for failure in "${failures[@]}"; do
    echo "$failure"
  done;
  exit 1
fi
