#!/usr/bin/env bash
set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
failed=0

check_command() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null 2>&1; then
    printf 'OK   %-10s %s\n' "${command_name}" "$(command -v "${command_name}")"
  else
    printf 'MISS %-10s not found\n' "${command_name}"
    failed=1
  fi
}

check_zed() {
  if command -v zed >/dev/null 2>&1; then
    printf 'OK   %-10s %s\n' "zed" "$(command -v zed)"
  elif [[ -x "/Applications/Zed.app/Contents/MacOS/cli" ]]; then
    printf 'OK   %-10s %s\n' "zed" "/Applications/Zed.app/Contents/MacOS/cli"
  else
    printf 'MISS %-10s not found\n' "zed"
    failed=1
  fi
}

echo "Commands"
check_zed
check_command ruby
check_command bundle
check_command rbenv
check_command cargo
check_command rustc

echo
echo "Zed files"
for config_file in settings.json keymap.json; do
  config_path="${XDG_CONFIG_HOME:-${HOME:?}/.config}/zed/${config_file}"
  if [[ -e "${config_path}" ]]; then
    printf 'OK   %s\n' "${config_path}"
  else
    printf 'MISS %s\n' "${config_path}"
    failed=1
  fi
done

echo
echo "Dotfiles commands"
if [[ -x "${repo_root}/scripts/publish.sh" ]]; then
  echo "OK   zed-sync publisher is executable"
else
  echo "MISS scripts/publish.sh is not executable"
  failed=1
fi

echo
echo "macOS settings"
if [[ "$(uname -s)" == "Darwin" ]] && command -v defaults >/dev/null 2>&1; then
  press_and_hold="$(defaults read dev.zed.Zed ApplePressAndHoldEnabled 2>/dev/null || true)"
  if [[ "${press_and_hold}" == "0" ]]; then
    echo "OK   Zed key repeat enabled"
  else
    echo "MISS Zed key repeat is not enabled"
    failed=1
  fi
else
  echo "SKIP ApplePressAndHoldEnabled is macOS-only"
fi

echo
if [[ "${failed}" -eq 0 ]]; then
  echo "Environment looks ready."
else
  echo "Some optional or required tools are missing. See README.md."
fi

exit "${failed}"
