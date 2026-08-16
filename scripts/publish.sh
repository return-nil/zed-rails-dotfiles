#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
config_files=("zed/settings.json" "zed/keymap.json" "ghostty/config.ghostty")
commit_message="${1:-エディタ・ターミナル設定を更新 $(date '+%Y-%m-%d %H:%M')}"

if [[ -z "${repo_root}" || ! -d "${repo_root}/.git" ]]; then
  echo "Could not resolve the dotfiles repository." >&2
  exit 1
fi

cd "${repo_root}"

current_branch="$(git branch --show-current)"
if [[ "${current_branch}" != "main" ]]; then
  echo "dev-sync only publishes from main. Current branch: ${current_branch}" >&2
  exit 1
fi

if ! git diff --cached --quiet; then
  echo "Staged changes already exist. Commit or unstage them before dev-sync." >&2
  exit 1
fi

if ! git diff --quiet -- . ':(exclude)zed/settings.json' ':(exclude)zed/keymap.json' ':(exclude)ghostty/config.ghostty'; then
  echo "Changes outside synchronized settings exist. Handle them separately before dev-sync." >&2
  exit 1
fi

if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
  echo "Untracked files exist. Handle them separately before dev-sync." >&2
  exit 1
fi

git pull --ff-only origin main

if git diff --quiet -- "${config_files[@]}"; then
  echo "Settings are already synchronized."
  exit 0
fi

secret_pattern='(gh[opsu]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|"(api_key|token|password|secret)"[[:space:]]*:[[:space:]]*"[^"]+")'
if command -v rg >/dev/null 2>&1; then
  if rg -n -i "${secret_pattern}" "${config_files[@]}"; then
    echo "Possible secret detected. Nothing was committed." >&2
    exit 1
  fi
elif grep -Eni "${secret_pattern}" "${config_files[@]}"; then
  echo "Possible secret detected. Nothing was committed." >&2
  exit 1
fi

validate_jsonc() {
  ruby -rjson -e '
    path = ARGV.fetch(0)
    jsonc = File.readlines(path).reject { |line| line.match?(/^\s*\/\//) }.join
    jsonc = jsonc.gsub(/,\s*([}\]])/, "\\1")
    JSON.parse(jsonc)
  ' "$1"
}

for config_file in zed/settings.json zed/keymap.json; do
  validate_jsonc "${config_file}"
done

git diff --check -- "${config_files[@]}"
git add -- "${config_files[@]}"

if git diff --cached --quiet; then
  echo "No publishable settings changes found."
  exit 0
fi

git commit -m "${commit_message}"
git push origin main

echo "Published Zed and Ghostty settings to GitHub."
