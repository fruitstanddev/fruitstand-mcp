#!/bin/sh
# Bridge stdio <-> a Fruit Stand Fund Returns MCP endpoint.
#
# The endpoint URL is the command argument (defaults via the Dockerfile CMD to
# the hosted server). The bearer token is added when FRUITSTAND_API_KEY is set;
# without it, only the unauthenticated discovery methods work. Any extra args
# are passed through to mcp-remote.
set -eu

ENDPOINT="${1:-https://api.fruitstand.dev/mcp}"
if [ "$#" -gt 0 ]; then
  shift
fi

if [ -n "${FRUITSTAND_API_KEY:-}" ]; then
  exec mcp-remote "$ENDPOINT" --header "Authorization: Bearer ${FRUITSTAND_API_KEY}" "$@"
fi

exec mcp-remote "$ENDPOINT" "$@"
