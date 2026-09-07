#!/bin/sh
# Bridge stdio <-> the hosted Fruit Stand Fund Returns MCP server.
# Adds the bearer token when FRUITSTAND_API_KEY is set; otherwise connects
# anonymously (discovery only).
set -eu

ENDPOINT="https://api.fruitstand.dev/mcp"

if [ -n "${FRUITSTAND_API_KEY:-}" ]; then
  exec mcp-remote "$ENDPOINT" --header "Authorization: Bearer ${FRUITSTAND_API_KEY}"
fi

exec mcp-remote "$ENDPOINT"
