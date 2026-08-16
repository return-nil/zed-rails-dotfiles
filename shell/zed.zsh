# Open Zed with both `zed` and the familiar `code` command.
if [[ -x "/Applications/Zed.app/Contents/MacOS/cli" ]]; then
  alias zed="/Applications/Zed.app/Contents/MacOS/cli"
  alias code="zed"
fi

typeset -g RAILS_DEV_DOTFILES_ROOT="${${(%):-%N}:A:h:h}"

dev-sync() {
  "${RAILS_DEV_DOTFILES_ROOT}/scripts/publish.sh" "$@"
}

zed-sync() {
  dev-sync "$@"
}
