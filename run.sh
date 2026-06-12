#!/usr/bin/env bash
set -euo pipefail

MISE_BIN="$HOME/.local/bin/mise"
MISE_TAG="v${MISE_VERSION}"
TARBALL_NAME="mise-${MISE_TAG}-linux-x64.tar.gz"
BASE_URL="https://github.com/jdx/mise/releases/download/${MISE_TAG}"

# Download, verify, and install mise binary (skip if fully cached)
if [ "${CACHE_HIT}" != "true" ] || [ ! -x "${MISE_BIN}" ]; then
  WORK_DIR=$(mktemp -d)
  trap 'rm -rf "$WORK_DIR"' EXIT

  echo "Downloading mise ${MISE_TAG}..."
  curl -fsSL --header "Authorization: Bearer ${INPUT_GITHUB_TOKEN}" \
    "${BASE_URL}/${TARBALL_NAME}" -o "${WORK_DIR}/${TARBALL_NAME}"
  curl -fsSL --header "Authorization: Bearer ${INPUT_GITHUB_TOKEN}" \
    "${BASE_URL}/SHASUMS256.txt" -o "${WORK_DIR}/SHASUMS256.txt"

  echo "Verifying checksum..."
  grep "${TARBALL_NAME}" "${WORK_DIR}/SHASUMS256.txt" \
    | (cd "${WORK_DIR}" && sha256sum --check)

  echo "Installing mise..."
  tar -xzf "${WORK_DIR}/${TARBALL_NAME}" -C "${WORK_DIR}"
  [ -f "${WORK_DIR}/mise/bin/mise" ] || { echo "Unexpected tarball structure"; exit 1; }
  mkdir -p "$HOME/.local/bin"
  install -m 0755 "${WORK_DIR}/mise/bin/mise" "${MISE_BIN}"
else
  echo "mise ${MISE_TAG} restored from cache"
fi

# Run mise install (skip on full cache hit — tools are already installed)
if [ "${INPUT_INSTALL}" = "true" ] && [ "${CACHE_HIT}" != "true" ]; then
  if [[ "${INPUT_CONFIG_FILE}" = /* ]]; then
    CONFIG_PATH="${INPUT_CONFIG_FILE}"
  else
    CONFIG_PATH=$(realpath -m "${GITHUB_WORKSPACE}/${INPUT_WORKING_DIRECTORY}/${INPUT_CONFIG_FILE}")
  fi

  echo "Running mise install (config: ${CONFIG_PATH})..."
  MISE_LOG_LEVEL="${INPUT_LOG_LEVEL}" \
  MISE_CONFIG_FILE="${CONFIG_PATH}" \
    "${MISE_BIN}" install
fi

# Always register paths for subsequent steps
echo "$HOME/.local/bin" >> "$GITHUB_PATH"
echo "$HOME/.local/share/mise/shims" >> "$GITHUB_PATH"
