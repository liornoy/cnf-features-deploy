//go:build !unittests
// +build !unittests

package setup_test

import (
	"flag"
	"log"
	"path"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	"github.com/onsi/ginkgo/v2/types"
	. "github.com/onsi/gomega"

	ginkgo_reporters "github.com/onsi/ginkgo/v2/reporters"
	kniK8sReporter "github.com/openshift-kni/k8sreporter"
	qe_reporters "kubevirt.io/qe-tools/pkg/ginkgo-reporters"

	testclient "github.com/openshift-kni/cnf-features-deploy/cnf-tests/testsuites/pkg/client"
	testutils "github.com/openshift-kni/cnf-features-deploy/cnf-tests/testsuites/pkg/utils"
)

// TODO: we should refactor tests to use client from controller-runtime package
// see - https://github.com/openshift/cluster-api-actuator-pkg/blob/master/pkg/e2e/framework/framework.go

var (
	junitPath  *string
	reportPath *string
	reporter   *kniK8sReporter.KubernetesReporter
	err        error
)

func init() {
	junitPath = flag.String("junit", "", "the path for the junit format report")
	reportPath = flag.String("report", "", "the path of the report file containing details for failed tests")
}

func TestTest(t *testing.T) {
	RegisterFailHandler(Fail)
	_, reporterConfig := GinkgoConfiguration()

	if *junitPath != "" {
		junitFile := path.Join(*junitPath, "setup_junit.xml")
		reporterConfig.JUnitReport = junitFile
	}
	if *reportPath != "" {
		reportFile := path.Join(*reportPath, "setup_failure_report.log")
		reporter, err = testutils.NewReporter(reportFile)
		if err != nil {
			log.Fatalf("Failed to create log reporter %s", err)
		}
	}

	RunSpecs(t, "CNF Features e2e setup", reporterConfig)
}

var _ = BeforeSuite(func() {
	Expect(testclient.Client).NotTo(BeNil(), "Verify the KUBECONFIG environment variable")
})

var _ = AfterSuite(func() {

})

var _ = ReportAfterSuite("configsuite", func(report types.Report) {
	if qe_reporters.Polarion.Run {
		ginkgo_reporters.ReportViaDeprecatedReporter(&qe_reporters.Polarion, report)
	}
})

var _ = ReportAfterEach(func(specReport types.SpecReport) {
	if specReport.Failed() == false {
		return
	}

	if *reportPath != "" {
		reporter.Dump(testutils.LogsExtractDuration, specReport.FullText())
	}
})
