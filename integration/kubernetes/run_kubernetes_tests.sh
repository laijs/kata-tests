#!/bin/bash
#
# Copyright (c) 2018 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

source /etc/os-release || source /usr/lib/os-release
kubernetes_dir=$(dirname $0)

# Currently, Kubernetes tests only work on Ubuntu.
# We should delete this condition, when it works for other Distros.
if [ "$ID" != ubuntu  ]; then
	echo "Skip Kubernetes tests on $ID"
	echo "kubernetes tests on $ID aren't supported yet"
	exit
fi

# Docker is required to initialize kubeadm, even if we are
# using cri-o as the runtime.
systemctl is-active --quiet docker || sudo systemctl start docker

pushd "$kubernetes_dir"
./init.sh
bats nginx.bats
bats k8s-uts+ipc-ns.bats
bats k8s-env.bats
bats k8s-pid-ns.bats
bats k8s-cpu-ns.bats
bats k8s-parallel.bats
bats k8s-memory.bats
bats k8s-liveness-probes.bats
bats k8s-attach-handlers.bats
bats k8s-qos-pods.bats
bats k8s-pod-quota.bats
bats k8s-volume.bats
./cleanup_env.sh
popd
