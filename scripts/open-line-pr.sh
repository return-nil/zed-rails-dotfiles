#!/usr/bin/env bash
set -euo pipefail

worktree_root="${1:-}"
relative_file="${2:-}"
line_number="${3:-}"

fail() {
  echo "Open PR: $*" >&2
  exit 1
}

[[ -n "${worktree_root}" && -d "${worktree_root}" ]] || fail "Git worktreeが見つかりません。"
[[ -n "${relative_file}" ]] || fail "対象ファイルが見つかりません。"
[[ "${line_number}" =~ ^[1-9][0-9]*$ ]] || fail "対象行を特定できませんでした。"

command -v git >/dev/null 2>&1 || fail "gitコマンドが見つかりません。"
command -v gh >/dev/null 2>&1 || fail "GitHub CLIが見つかりません。brew bundleを実行してください。"

cd "${worktree_root}"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Gitリポジトリではありません。"
git ls-files --error-unmatch -- "${relative_file}" >/dev/null 2>&1 || fail "Gitで管理されていないファイルです。"

commit_sha="$(git blame --porcelain -L "${line_number},${line_number}" -- "${relative_file}" | sed -n '1s/ .*//p')"
[[ -n "${commit_sha}" ]] || fail "この行のコミットを特定できませんでした。"
[[ ! "${commit_sha}" =~ ^0+$ ]] || fail "この行はまだコミットされていません。"

repository="$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)" || fail "GitHubリポジトリを特定できません。gh auth loginも確認してください。"
[[ -n "${repository}" ]] || fail "GitHubリポジトリを特定できません。"

pr_url="$(gh api \
  -H "Accept: application/vnd.github+json" \
  "repos/${repository}/commits/${commit_sha}/pulls" \
  --jq 'sort_by([(.state == "open"), (.merged_at // .updated_at)]) | reverse | .[0].html_url // empty' \
  2>/dev/null)" || fail "GitHubからPRを取得できませんでした。"

[[ -n "${pr_url}" ]] || fail "この行のコミットに関連するPRはありません。"

if [[ "${ZED_OPEN_LINE_PR_DRY_RUN:-0}" == "1" ]]; then
  echo "${pr_url}"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  open "${pr_url}"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "${pr_url}"
else
  echo "${pr_url}"
fi
