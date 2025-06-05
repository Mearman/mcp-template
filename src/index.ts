#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { z } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';
import { exampleTool, ExampleToolSchema } from './tools/example.js';

const server = new Server(
  {
    name: 'mcp-template',
    version: '0.1.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
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

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'example_tool':
      return await exampleTool(args);
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

// Start the server
const transport = new StdioServerTransport();
await server.connect(transport);

// Handle shutdown gracefully
process.on('SIGINT', async () => {
  await server.close();
  process.exit(0);
});