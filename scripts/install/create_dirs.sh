#!/usr/bin/env bash

# Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
# Use of this source code is governed by a MIT style
# license that can be found in the LICENSE file.


# shellcheck disable=SC2164
cd "$CAS_ROOT"
source scripts/install/environment.sh
sudo mkdir -p "${CAS_DATA_DIR}"/chever-apiserver
sudo mkdir -p "${CAS_INSTALL_DIR}"/bin
sudo mkdir -p "${CAS_CONFIG_DIR}"/cert
sudo mkdir -p "${CAS_LOG_DIR}"