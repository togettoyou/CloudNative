package main

import (
	"os"
	"simple/pkg/podstate"

	"k8s.io/component-base/cli"
	_ "k8s.io/component-base/metrics/prometheus/clientgo" // for rest client metric registration
	_ "k8s.io/component-base/metrics/prometheus/version"  // for version metric registration
	"k8s.io/kubernetes/cmd/kube-scheduler/app"
)

func main() {
	command := app.NewSchedulerCommand(
		app.WithPlugin(podstate.Name, podstate.New),
	)

	code := cli.Run(command)
	os.Exit(code)
}
