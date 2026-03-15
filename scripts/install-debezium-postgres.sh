#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGINS_DIR="${ROOT_DIR}/plugins"
DEBEZIUM_VERSION="${DEBEZIUM_VERSION:-3.4.2.Final}"
ARCHIVE_NAME="debezium-connector-postgres-${DEBEZIUM_VERSION}-plugin.tar.gz"
DOWNLOAD_URL="${DOWNLOAD_URL:-https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_VERSION}/${ARCHIVE_NAME}}"
TARGET_DIR="${PLUGINS_DIR}/debezium-connector-postgres"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}

trap cleanup EXIT

mkdir -p "${PLUGINS_DIR}"
rm -rf "${TARGET_DIR}"

curl -fL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${ARCHIVE_NAME}"
tar -xzf "${TMP_DIR}/${ARCHIVE_NAME}" -C "${PLUGINS_DIR}"

if [[ -d "${TARGET_DIR}/lib" ]]; then
  # Some plugin archives place jars under lib/.
  find "${TARGET_DIR}" -mindepth 1 -maxdepth 1 ! -name lib -exec rm -rf {} +
elif find "${TARGET_DIR}" -maxdepth 1 -type f -name '*.jar' | grep -q .; then
  # Debezium 3.4.2.Final ships jars at the top level of the plugin directory.
  find "${TARGET_DIR}" -maxdepth 1 -mindepth 1 \( -type d -o \( -type f ! -name '*.jar' \) \) -exec rm -rf {} +
else
  echo "Expected runtime jars in ${TARGET_DIR} after extracting ${ARCHIVE_NAME}" >&2
  exit 1
fi
