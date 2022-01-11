#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

set -x

source "kit/helper.sh"

cd "${WORKDIR}"

"${ROOT}"/hack/wrapper.sh bash -c "curl -sSL https://kind.sigs.k8s.io/dl/latest/linux-amd64.tgz | tar xvfz" -C "${PATH%%:*}/" && e2e-k8s.sh
