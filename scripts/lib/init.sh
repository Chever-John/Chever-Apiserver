#!/usr/bin/env bash

# Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
# Use of this source code is governed by a MIT style
# license that can be found in the LICENSE file.


set -o errexit
set +o nounset
set -o pipefail

unset CDPATH

# Default use go modules
export GO111MODULE=on

# The root of the build/dist directory
CAS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

source "${CAS_ROOT}/scripts/lib/util.sh"
source "${CAS_ROOT}/scripts/lib/logging.sh"
source "${CAS_ROOT}/scripts/lib/color.sh"

cas::log::install_errexit

source "${CAS_ROOT}/scripts/lib/version.sh"
source "${CAS_ROOT}/scripts/lib/golang.sh"
