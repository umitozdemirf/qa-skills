#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIST_DIR="${REPO_ROOT}/dist"

python3 "${REPO_ROOT}/scripts/export_agent_commands.py"

mkdir -p "${DIST_DIR}"
tar -czf "${DIST_DIR}/qa-skills-integrations.tar.gz" -C "${REPO_ROOT}" integrations AGENTS.md qa-skills-plugin/skills scripts/install_integrations.sh

echo "Created ${DIST_DIR}/qa-skills-integrations.tar.gz"
