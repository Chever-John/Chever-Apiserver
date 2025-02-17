#!/usr/bin/env bash

# Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
# Use of this source code is governed by a MIT style
# license that can be found in the LICENSE file.


PROJECT_NAME="cas"
GEN_CFG_ENV=${GEN_CFG_ENV:-'Linux'}
# Chever-ApiServer 项目源码根目录，项目简称为 CAS（Chever ApiServer）。
CAS_ROOT=$(dirname "${BASH_SOURCE[0]}")/../..
#${BASH_SOURCE[0]}：这个表达式表示当前脚本文件的路径
#dirname：获取当前脚本文件的父目录

# Generate output store directory
LOCAL_OUTPUT_ROOT="${CAS_ROOT}/${OUT_DIR:-_output}"

# Set a unified password for easy memory
readonly PASSWORD=${PASSWORD:-'chever_is_an_awesome_guy'}

# Set Installation Directory
readonly INSTALL_DIR=${INSTALL_DIR:-/tmp/installation}
mkdir -p "${INSTALL_DIR}"

# main system configuration
# if os is darwin/arm64, CAS_DATA_DIR="${CAS_DATA_DIR:-/Users/${USER}/data/${PROJECT_NAME}}"
if [[ "$(uname)" == "Darwin" && $GEN_CFG_ENV != "Linux" ]]; then
  readonly CAS_DATA_DIR="${CAS_DATA_DIR:-/Users/${USER}/data/${PROJECT_NAME}}" # CAS data directory
  readonly CAS_INSTALL_DIR="${CAS_INSTALL_DIR:-/Users/${USER}/opt/${PROJECT_NAME}}" # CAS installation directory
  readonly CAS_CONFIG_DIR="${CAS_CONFIG_DIR:-/Users/${USER}/etc/${PROJECT_NAME}}" # CAS configuration directory
  readonly CAS_LOG_DIR="${CAS_LOG_DIR:-/Users/${USER}/var/log/${PROJECT_NAME}}" # CAS log directory
else
  readonly CAS_DATA_DIR="${CAS_DATA_DIR:-/data/${PROJECT_NAME}}" # CAS data directory
  readonly CAS_INSTALL_DIR="${CAS_INSTALL_DIR:-/opt/${PROJECT_NAME}}" # CAS installation directory
  readonly CAS_CONFIG_DIR="${CAS_CONFIG_DIR:-/etc/${PROJECT_NAME}}" # CAS configuration directory
  readonly CAS_LOG_DIR="${CAS_LOG_DIR:-/var/log/${PROJECT_NAME}}" # CAS log directory
fi

readonly CA_FILE="${CA_FILE:-${CAS_CONFIG_DIR}/cert/ca.pem}" # CA certificate file

# cas-apiserver configuration
readonly CAS_APISERVER_HOST="${CAS_APISERVER_HOST:-127.0.0.1}" # cas-apiserver host

readonly CAS_APISERVER_GRPC_BIND_ADDRESS="${CAS_APISERVER_GRPC_BIND_ADDRESS:-0.0.0.0}" # cas-apiserver grpc bind address
readonly CAS_APISERVER_GRPC_BIND_PORT="${CAS_APISERVER_GRPC_BIND_PORT:-8081}" # cas-apiserver grpc bind port

readonly CAS_APISERVER_INSECURE_BIND_ADDRESS="${CAS_APISERVER_INSECURE_BIND_ADDRESS:-127.0.0.1}" # cas-apiserver insecure bind address
readonly CAS_APISERVER_INSECURE_BIND_PORT="${CAS_APISERVER_INSECURE_BIND_PORT:-8080}" # cas-apiserver insecure bind port

readonly CAS_APISERVER_SECURE_BIND_ADDRESS="${CAS_APISERVER_SECURE_BIND_ADDRESS:-0.0.0.0}" # cas-apiserver secure bind address
readonly CAS_APISERVER_SECURE_BIND_PORT="${CAS_APISERVER_SECURE_BIND_PORT:-8443}" # cas-apiserver secure bind port

readonly CAS_APISERVER_SECURE_TLS_CERT_KEY_CERT_FILE=${CAS_APISERVER_SECURE_TLS_CERT_KEY_CERT_FILE:-${CAS_CONFIG_DIR}/cert/${PROJECT_NAME}-apiserver.pem}
readonly CAS_APISERVER_SECURE_TLS_CERT_KEY_PRIVATE_KEY_FILE=${CAS_APISERVER_SECURE_TLS_CERT_KEY_PRIVATE_KEY_FILE:-${CAS_CONFIG_DIR}/cert/${PROJECT_NAME}-apiserver-key.pem}
