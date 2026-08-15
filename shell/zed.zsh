# Open Zed with both `zed` and the familiar `code` command.
if [[ -x "/Applications/Zed.app/Contents/MacOS/cli" ]]; then
  alias zed="/Applications/Zed.app/Contents/MacOS/cli"
  alias code="zed"
fi

typeset -g ZED_DOTFILES_ROOT="${${(%):-%N}:A:h:h}"

zed-sync() {
  "${ZED_DOTFILES_ROOT}/scripts/publish.sh" "$@"
}
