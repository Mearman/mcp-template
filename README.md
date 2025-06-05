# MCP TypeScript Server Template

A template repository for building Model Context Protocol (MCP) servers with TypeScript.

## Features

- 🚀 Full TypeScript support with strict mode
- 🧪 Testing setup with Vitest and coverage reporting
- 📦 Automated releases with semantic-release
- 🔄 CI/CD pipelines with GitHub Actions
- 🏗️ Modular architecture for easy extension
- 📝 Comprehensive documentation and examples
- 🛠️ Development tools: Biome for linting/formatting, Husky for Git hooks
- 🎯 Pre-configured for MCP server development

## Quick Start

### Using GitHub Template

1. Click "Use this template" button on GitHub
2. Clone your new repository
3. Install dependencies: `yarn install`
4. Start development: `yarn dev`

### Manual Setup

```bash
# Clone the template
git clone https://github.com/Mearman/mcp-template.git my-mcp-server
cd my-mcp-server

# Install dependencies
yarn install

# Start development
yarn dev
```

## Project Structure

```
src/
├── index.ts          # MCP server entry point
├── tools/            # Tool implementations
│   └── example.ts    # Example tool
├── utils/            # Shared utilities
│   └── validation.ts # Input validation helpers
└── types.ts          # TypeScript type definitions
```

## Development

```bash
# Install dependencies
yarn install

# Development with hot reload
yarn dev

# Build TypeScript to JavaScript
yarn build

# Run production build
yarn start

# Run tests
yarn test

# Run tests in watch mode
yarn test:watch

# Run tests with coverage
yarn test:coverage

# Lint and format code
yarn lint
yarn format
```

## Creating Your MCP Server

### 1. Define Your Tools

Create tool implementations in `src/tools/`:

```typescript
// src/tools/my-tool.ts
import { z } from 'zod';

const MyToolSchema = z.object({
  input: z.string().describe('Tool input'),
});

export async function myTool(args: unknown) {
  const { input } = MyToolSchema.parse(args);
  
  // Tool implementation
  return {
    success: true,
    result: `Processed: ${input}`,
  };
}
```

### 2. Register Tools in Server

Update `src/index.ts` to register your tools:

```typescript
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: 'my_tool',
      description: 'Description of what my tool does',
      inputSchema: zodToJsonSchema(MyToolSchema),
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  switch (request.params.name) {
    case 'my_tool':
      return await myTool(request.params.arguments);
    default:
      throw new Error(`Unknown tool: ${request.params.name}`);
  }
});
```

### 3. Configure for Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-mcp-server": {
      "command": "node",
      "args": ["/path/to/my-mcp-server/dist/index.js"],
      "env": {}
    }
  }
}
```

## Testing

Write tests for your tools in `src/tools/*.test.ts`:

```typescript
import { describe, it, expect } from 'vitest';
import { myTool } from './my-tool';

describe('myTool', () => {
  it('should process input correctly', async () => {
    const result = await myTool({ input: 'test' });
    expect(result.success).toBe(true);
    expect(result.result).toBe('Processed: test');
  });
});
```

## Publishing

### NPM Package

1. Update `package.json` with your package details
2. Build: `yarn build`
3. Publish: `npm publish`

### Automated Releases

This template includes semantic-release for automated versioning and publishing:

1. Follow [conventional commits](https://www.conventionalcommits.org/)
2. Push to main branch
3. CI/CD will automatically:
   - Determine version bump
   - Update CHANGELOG.md
   - Create GitHub release
   - Publish to npm (if NPM_TOKEN secret is configured)

**Note**: NPM publishing is optional. If you don't want to publish to npm, simply don't add the `NPM_TOKEN` secret to your repository. The release process will still create GitHub releases.

## Best Practices

1. **Input Validation**: Always validate tool inputs using Zod schemas
2. **Error Handling**: Provide clear error messages for debugging
3. **Testing**: Write comprehensive tests for all tools
4. **Documentation**: Document each tool's purpose and usage
5. **Type Safety**: Leverage TypeScript's type system fully

## License

MIT

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Creating MCP Servers Guide](https://modelcontextprotocol.io/tutorials/building-servers)

## MCP Servers Built with This Template

Here are some MCP servers built using this template:

### Wayback Machine MCP
[![GitHub](https://img.shields.io/github/stars/Mearman/mcp-wayback-machine?style=social)](https://github.com/Mearman/mcp-wayback-machine)
[![npm version](https://img.shields.io/npm/v/mcp-wayback-machine.svg)](https://www.npmjs.com/package/mcp-wayback-machine)
[![npm downloads](https://img.shields.io/npm/dm/mcp-wayback-machine.svg)](https://www.npmjs.com/package/mcp-wayback-machine)

Archive and retrieve web pages using the Internet Archive's Wayback Machine. No API keys required.

### OpenAlex MCP
[![GitHub](https://img.shields.io/github/stars/Mearman/mcp-openalex?style=social)](https://github.com/Mearman/mcp-openalex)
[![npm version](https://img.shields.io/npm/v/mcp-openalex.svg)](https://www.npmjs.com/package/mcp-openalex)
[![npm downloads](https://img.shields.io/npm/dm/mcp-openalex.svg)](https://www.npmjs.com/package/mcp-openalex)

Access scholarly articles and research data from the OpenAlex database.

---

*Building an MCP server? [Use this template](https://github.com/Mearman/mcp-template/generate) and add your server to this list!*