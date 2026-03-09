#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/install_integrations.sh <target> [--project DIR | --home]

Targets:
  claude     Install Claude Code slash commands
  codex      Install AGENTS.md and skills for Codex-style agents
  gemini     Install Gemini CLI command wrappers
  opencode   Install OpenCode command wrappers
  all        Install all supported integrations

Options:
  --project DIR   Install into a specific project directory
  --home          Install into the current user's home directory

Examples:
  scripts/install_integrations.sh claude --project /path/to/project
  scripts/install_integrations.sh codex --project "$(pwd)"
  scripts/install_integrations.sh gemini --home
  scripts/install_integrations.sh all --project "$(pwd)"
EOF
}

TARGET="${1:-}"
if [[ -z "${TARGET}" ]]; then
  usage
  exit 1
fi
shift

MODE=""
DEST_ROOT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      MODE="project"
      DEST_ROOT="${2:-}"
      shift 2
      ;;
    --home)
      MODE="home"
      DEST_ROOT="${HOME}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${MODE}" || -z "${DEST_ROOT}" ]]; then
  echo "You must provide either --project DIR or --home." >&2
  usage
  exit 1
fi

if [[ ! -d "${DEST_ROOT}" ]]; then
  echo "Destination does not exist: ${DEST_ROOT}" >&2
  exit 1
fi

python3 "${REPO_ROOT}/scripts/export_agent_commands.py" >/dev/null

copy_dir_contents() {
  local src="$1"
  local dst="$2"
  mkdir -p "${dst}"
  cp -R "${src}/." "${dst}/"
}

install_claude() {
  local base="${DEST_ROOT}/.claude/commands/qa"
  copy_dir_contents "${REPO_ROOT}/integrations/claude/.claude/commands/qa" "${base}"
  echo "Installed Claude commands into ${base}"
}

install_gemini() {
  local base="${DEST_ROOT}/.gemini/commands/qa"
  copy_dir_contents "${REPO_ROOT}/integrations/gemini/.gemini/commands/qa" "${base}"
  echo "Installed Gemini commands into ${base}"
}

install_opencode() {
  local base="${DEST_ROOT}/.opencode/commands/qa"
  copy_dir_contents "${REPO_ROOT}/integrations/opencode/.opencode/commands/qa" "${base}"
  echo "Installed OpenCode commands into ${base}"
}

install_codex() {
  local tools_root
  if [[ "${MODE}" == "project" ]]; then
    tools_root="${DEST_ROOT}/tools/qa-skills"
  else
    tools_root="${DEST_ROOT}/.codex/qa-skills"
  fi

  mkdir -p "${tools_root}"
  cp "${REPO_ROOT}/AGENTS.md" "${tools_root}/AGENTS.md"
  copy_dir_contents "${REPO_ROOT}/qa-skills-plugin/skills" "${tools_root}/qa-skills-plugin/skills"

  if [[ "${MODE}" == "project" ]]; then
    local root_agents="${DEST_ROOT}/AGENTS.md"
    if [[ ! -f "${root_agents}" ]]; then
      cat >"${root_agents}" <<'EOF'
# Project Instructions

This project uses the QA skill pack at `tools/qa-skills/`.

- Open `tools/qa-skills/AGENTS.md` for the skill catalog.
- Open the relevant `tools/qa-skills/qa-skills-plugin/skills/<skill-name>/SKILL.md` when a QA task matches a named skill.
- Follow the selected skill's deterministic execution flow exactly.
EOF
      echo "Created ${root_agents}"
    else
      echo "Skipped ${root_agents}; file already exists."
    fi
  fi

  echo "Installed Codex skill pack into ${tools_root}"
}

case "${TARGET}" in
  claude)
    install_claude
    ;;
  codex)
    install_codex
    ;;
  gemini)
    install_gemini
    ;;
  opencode)
    install_opencode
    ;;
  all)
    install_claude
    install_codex
    install_gemini
    install_opencode
    ;;
  *)
    echo "Unknown target: ${TARGET}" >&2
    usage
    exit 1
    ;;
esac
