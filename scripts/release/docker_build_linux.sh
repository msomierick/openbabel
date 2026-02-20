#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

IMAGE_NAME="${IMAGE_NAME:-openbabel-obabel-builder:local}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/dist}"
CONTAINER_BUILD_DIR="${CONTAINER_BUILD_DIR:-/tmp/build-obabel-standalone}"

mkdir -p "${OUT_DIR}"

docker build -f "${SCRIPT_DIR}/Dockerfile.linux" -t "${IMAGE_NAME}" "${ROOT_DIR}"
docker run --rm \
  -v "${ROOT_DIR}:/src" \
  -w /src \
  -e BUILD_DIR="${CONTAINER_BUILD_DIR}" \
  -e OUT_DIR="/src/dist" \
  "${IMAGE_NAME}" \
  bash scripts/release/build_obabel_standalone.sh
