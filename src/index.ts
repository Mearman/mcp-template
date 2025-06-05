#!/usr/bin/env node
/**
 * @fileoverview MCP server entry point that sets up and starts the server
 * @module index
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import { z } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';
import { ExampleToolSchema, exampleTool } from './tools/example.js';

/**
 * Create the MCP server instance with configured capabilities
 */
const server = new Server(
	{
		name: 'mcp-template',
		version: '0.1.0',
	},
	{
		capabilities: {
			tools: {},
		},
	},
);

/**
 * Register handler for listing available tools
 * @returns List of available tools with their schemas
 */
server.setRequestHandler(ListToolsRequestSchema, async () => {
	return {
		tools: [
			{
				name: 'example_tool',
				description: 'An example tool that echoes back the input',
				inputSchema: zodToJsonSchema(ExampleToolSchema),
			},
		],
	};
});

/**
 * Register handler for executing tool calls
 * @param request - The tool call request containing tool name and arguments
 * @returns Tool execution result
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
	const { name, arguments: args } = request.params;

	switch (name) {
		case 'example_tool':
			return await exampleTool(args);
		default:
			throw new Error(`Unknown tool: ${name}`);
	}
});

/**
 * Start the MCP server using stdio transport
 */
const transport = new StdioServerTransport();
await server.connect(transport);

/**
 * Handle graceful shutdown on SIGINT (Ctrl+C)
 */
process.on('SIGINT', async () => {
	await server.close();
	process.exit(0);
});
