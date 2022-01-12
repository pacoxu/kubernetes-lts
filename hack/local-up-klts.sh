#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

set -x

source "kit/helper.sh"
export GOPATH="${GOPATH:-${HOME}/go}"
echo ${GOPATH}

docker run -d --name entrypoint gcr.io/k8s-prow/entrypoint:v20220105-8e97316bf9
mkdir -p /tmp/entrypoint
mkdir -p /home/runner/go/bin/
docker cp entrypoint:/entrypoint /tmp/entrypoint
chmod +x /tmp/entrypoint
# -v  /tmp/entrypoint:/tools/entrypoint --entrypoint=/tools/entrypoint
docker run --network=host --privileged -v /var/run/:/var/run/  -e FOCUS=. -e SKIP="\[Slow\]|\[Disruptive\]|\[Flaky\]|\[Feature:.+\]|PodSecurityPolicy|LoadBalancer|load.balancer|Simple.pod.should.support.exec.through.an.HTTP.proxy|subPath.should.support.existing|NFS|nfs|inline.execution.and.attach|should.be.rejected.when.no.endpoints.exist" \
-e PARALLEL="true" -v  "${WORKDIR}":/home/prow/go/src/k8s.io/kubernetes -v /home/runner/go/bin/:/home/runner/go/bin/ -w /home/prow/go/src/k8s.io/kubernetes \
gcr.io/k8s-staging-test-infra/krte:v20211217-ea95cec1d4-master wrapper.sh bash -c 'go env && curl -sSL https://kind.sigs.k8s.io/dl/latest/linux-amd64.tgz | tar xvfz - -C "${PATH%%:*}/" && e2e-k8s.sh'

docker rm -f entrypoint