# Thin local stdio bridge to the hosted Fruit Stand Fund Returns MCP server.
#
# The data and tools live at https://api.fruitstand.dev/mcp — this image just
# lets MCP clients that only speak stdio (e.g. Claude Desktop) reach the remote
# server. It is a wrapper around `mcp-remote`, nothing more.
#
# Pass your API key as FRUITSTAND_API_KEY (get one free at
# https://app.fruitstand.dev/pricing). Without a key, only the unauthenticated
# discovery methods work (initialize, tools/list); tool calls return 401.
FROM node:22-alpine

RUN npm install -g mcp-remote@0.8.3

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# stdio transport — no ports. The MCP endpoint is the command argument;
# override it to point the bridge at a different Fruit Stand deployment.
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["https://api.fruitstand.dev/mcp"]
