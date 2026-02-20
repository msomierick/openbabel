#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/build-obabel-standalone}"
OUT_DIR="${OUT_DIR:-${ROOT_DIR}/dist}"
CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
GENERATOR="${GENERATOR:-Ninja}"

case "$(uname -s)" in
  Linux*)
    PLATFORM="linux"
    EXTRA_FLAGS=(-DBUILD_MIXED=ON)
    ;;
  Darwin*)
    PLATFORM="macos"
    EXTRA_FLAGS=()
    ;;
  *)
    echo "Unsupported OS for this script: $(uname -s)" >&2
    exit 1
    ;;
esac

ARCH="$(uname -m)"
OUTPUT_BIN="${OUT_DIR}/obabel-${PLATFORM}-${ARCH}"

cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" -G "${GENERATOR}" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
  -DBUILD_SHARED=OFF \
  -DENABLE_TESTS=OFF \
  -DBUILD_GUI=OFF \
  -DRUN_SWIG=OFF \
  -DPYTHON_BINDINGS=OFF \
  -DWITH_COORDGEN=OFF \
  -DWITH_MAEPARSER=OFF \
  -DWITH_JSON=OFF \
  -DWITH_STATIC_INCHI=ON \
  -DOPENBABEL_USE_SYSTEM_INCHI=OFF \
  "${EXTRA_FLAGS[@]}"

cmake --build "${BUILD_DIR}" --config "${CMAKE_BUILD_TYPE}" --target obabel

mkdir -p "${OUT_DIR}"
if [[ ! -f "${BUILD_DIR}/bin/obabel" ]]; then
  echo "Build completed but obabel was not found at ${BUILD_DIR}/bin/obabel" >&2
  exit 1
fi

if command -v strip >/dev/null 2>&1; then
  strip "${BUILD_DIR}/bin/obabel" || true
fi

cp "${BUILD_DIR}/bin/obabel" "${OUTPUT_BIN}"
"${OUTPUT_BIN}" -V

echo "Wrote ${OUTPUT_BIN}"
