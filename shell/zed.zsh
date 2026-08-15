# Open Zed with both `zed` and the familiar `code` command.
if [[ -x "/Applications/Zed.app/Contents/MacOS/cli" ]]; then
  alias zed="/Applications/Zed.app/Contents/MacOS/cli"
  alias code="zed"
fi
