#!/usr/bin/env bash
# Read-only live query for this WSL machine.
# Usage: query.sh [shell|python|node|tools|network|docker|browser|wsl|summary]
# Does not install tools, write config, or print credentials.
set +e
umask 022

_src="${BASH_SOURCE[0]}"
case "$_src" in
  /*) ;;
  *) _src="$PWD/$_src" ;;
esac
SCRIPT_DIR="${_src%/*}"
unset _src
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/query-lib.sh"

TOPIC="${1:-summary}"
case "$TOPIC" in
  -h|--help|help)
    printf '%s\n' "usage: $0 [shell|python|node|tools|network|docker|browser|wsl|summary]"
    exit 0
    ;;
  shell) wsl_topic_shell ;;
  python) wsl_topic_python ;;
  node) wsl_topic_node ;;
  tools) wsl_topic_tools ;;
  network) wsl_topic_network ;;
  docker) wsl_topic_docker ;;
  browser) wsl_topic_browser ;;
  wsl) wsl_topic_wsl ;;
  summary|all) wsl_topic_summary ;;
  *)
    printf '%s\n' "unknown topic: $TOPIC" >&2
    printf '%s\n' "usage: $0 [shell|python|node|tools|network|docker|browser|wsl|summary]" >&2
    exit 2
    ;;
esac
exit 0
