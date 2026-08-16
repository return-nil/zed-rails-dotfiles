#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
zed_config_dir="${XDG_CONFIG_HOME:-${HOME:?}/.config}/zed"
ghostty_config_dir="${XDG_CONFIG_HOME:-${HOME:?}/.config}/ghostty"
stamp="$(date +%Y%m%d-%H%M%S)-$$"

if [[ -z "${repo_root}" || ! -d "${repo_root}/zed" ]]; then
  echo "Could not resolve the repository root." >&2
  exit 1
fi

mkdir -p "${zed_config_dir}" "${ghostty_config_dir}"

install_link() {
  local source_path="$1"
  local target_path="$2"
  local backup_path

  if [[ ! -f "${source_path}" ]]; then
    echo "Missing source file: ${source_path}" >&2
    exit 1
  fi

  if [[ -L "${target_path}" && "$(readlink "${target_path}")" == "${source_path}" ]]; then
    echo "Already linked: ${target_path}"
    return
  fi

  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    backup_path="${target_path}.backup.${stamp}"
    if [[ -e "${backup_path}" || -L "${backup_path}" ]]; then
      echo "Backup target already exists: ${backup_path}" >&2
      exit 1
    fi
    mv "${target_path}" "${backup_path}"
    echo "Backed up: ${target_path} -> ${backup_path}"
  fi

  ln -s "${source_path}" "${target_path}"
  echo "Linked: ${target_path} -> ${source_path}"
}

install_link "${repo_root}/zed/settings.json" "${zed_config_dir}/settings.json"
install_link "${repo_root}/zed/keymap.json" "${zed_config_dir}/keymap.json"
install_link "${repo_root}/zed/tasks.json" "${zed_config_dir}/tasks.json"
install_link "${repo_root}/scripts/open-line-pr.sh" "${zed_config_dir}/open-line-pr.sh"
install_link "${repo_root}/ghostty/config.ghostty" "${ghostty_config_dir}/config.ghostty"

if [[ "$(uname -s)" == "Darwin" ]] && command -v defaults >/dev/null 2>&1; then
  defaults write dev.zed.Zed ApplePressAndHoldEnabled -bool false
  echo "Configured Zed key repeat: ApplePressAndHoldEnabled=false"
fi

zshrc_path="${HOME:?}/.zshrc"
source_line="source \"${repo_root}/shell/zed.zsh\""

touch "${zshrc_path}"
if ! grep -Fqx "${source_line}" "${zshrc_path}"; then
  cp "${zshrc_path}" "${zshrc_path}.backup.${stamp}"
  printf '\n%s\n' "${source_line}" >> "${zshrc_path}"
  echo "Updated: ${zshrc_path}"
else
  echo "Already configured: ${zshrc_path}"
fi

echo
echo "Done. Restart the terminal, Zed, and Ghostty, then run scripts/doctor.sh."
