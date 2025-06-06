# MCP Template

[![CI](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)
[![Coverage](.github/badges/coverage.svg)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)

TypeScript template for building MCP (Model Context Protocol) servers with automated template synchronization.

## MCP Server Ecosystem

<table width="100%">
<thead>
<tr>
<th width="30%">Repository</th>
<th width="17.5%">CI</th>
<th width="17.5%">Release</th>
<th width="17.5%">NPM</th>
<th width="17.5%">Coverage</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-template">mcp-template</a></strong><br/>Base template repository</td>
<td align="center"><img src="https://github.com/Mearman/mcp-template/actions/workflows/ci.yml/badge.svg" alt="CI"></td>
<td align="center"><img src="https://img.shields.io/github/v/release/Mearman/mcp-template.svg" alt="Release"></td>
<td align="center"><em>Template</em></td>
<td align="center"><img src=".github/badges/coverage.svg" alt="Coverage"></td>
</tr>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-wayback-machine">mcp-wayback-machine</a></strong><br/>Internet Archive integration</td>
<td align="center"><img src="https://github.com/Mearman/mcp-wayback-machine/actions/workflows/ci.yml/badge.svg" alt="CI"></td>
<td align="center"><img src="https://img.shields.io/github/v/release/Mearman/mcp-wayback-machine.svg" alt="Release"></td>
<td align="center"><img src="https://img.shields.io/npm/v/mcp-wayback-machine.svg" alt="npm"></td>
<td align="center"><img src="https://img.shields.io/badge/coverage-95%25-brightgreen" alt="Coverage"></td>
</tr>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-openalex">mcp-openalex</a></strong><br/>Academic knowledge graph</td>
<td align="center"><img src="https://github.com/Mearman/mcp-openalex/actions/workflows/ci.yml/badge.svg" alt="CI"></td>
<td align="center"><img src="https://img.shields.io/github/v/release/Mearman/mcp-openalex.svg" alt="Release"></td>
<td align="center"><img src="https://img.shields.io/npm/v/mcp-openalex.svg" alt="npm"></td>
<td align="center"><img src="https://img.shields.io/badge/coverage-90%25-brightgreen" alt="Coverage"></td>
</tr>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-mcp">mcp-mcp</a></strong><br/>Template with examples</td>
<td align="center"><img src="https://github.com/Mearman/mcp-mcp/actions/workflows/ci.yml/badge.svg" alt="CI"></td>
<td align="center"><img src="https://img.shields.io/github/v/release/Mearman/mcp-mcp.svg" alt="Release"></td>
<td align="center"><img src="https://img.shields.io/npm/v/mcp-mcp.svg" alt="npm"></td>
<td align="center"><img src="https://img.shields.io/badge/coverage-85%25-brightgreen" alt="Coverage"></td>
</tr>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-ollama">mcp-ollama</a></strong><br/>Ollama model integration</td>
<td align="center"><img src="https://github.com/Mearman/mcp-ollama/actions/workflows/ci.yml/badge.svg" alt="CI"></td>
<td align="center"><img src="https://img.shields.io/github/v/release/Mearman/mcp-ollama.svg" alt="Release"></td>
<td align="center"><img src="https://img.shields.io/npm/v/mcp-ollama.svg" alt="npm"></td>
<td align="center"><img src="https://img.shields.io/badge/coverage-80%25-brightgreen" alt="Coverage"></td>
</tr>
</tbody>
</table>

## Quick Start

```bash
# Use this template on GitHub, then:
git clone https://github.com/yourusername/your-mcp-server.git
cd your-mcp-server
yarn install
yarn dev
```

## Core Features

- **TypeScript + ES Modules** - Modern development with full type safety
- **Automated Testing** - Vitest with coverage reporting and CI integration
- **Code Quality** - Biome linting/formatting with pre-commit hooks
- **Template Sync** - Automatic updates to all derived repositories
- **Semantic Releases** - Automated versioning and NPM publishing
- **Repository Management** - Scripts for managing the entire ecosystem

## Development Commands

```bash
yarn dev          # Hot reload development server
yarn test         # Run tests with coverage
yarn test:watch   # Watch mode for development
yarn build        # Compile TypeScript
yarn lint         # Check code quality
yarn lint:fix     # Auto-fix linting issues
```

## Creating MCP Tools

```typescript
import { z } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';

// Define tool schema
export const MyToolSchema = z.object({
  input: z.string().describe('Input parameter'),
});

// Create tool definition
export const myToolSchema = {
  name: 'my_tool',
  description: 'Tool description',
  inputSchema: zodToJsonSchema(MyToolSchema),
};

// Implement tool
export async function myTool(input: unknown) {
  const { input: userInput } = MyToolSchema.parse(input);
  return {
    content: [{ type: 'text', text: `Processed: ${userInput}` }],
  };
}
```

Register in `src/index.ts`:

```typescript
// List tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [myToolSchema],
}));

// Handle execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  switch (request.params.name) {
    case 'my_tool': return await myTool(request.params.arguments);
    default: throw new Error(`Unknown tool: ${request.params.name}`);
  }
});
```

## Template Synchronization

Automatically syncs template updates to all derived repositories:

- **Auto-discovery** of repositories created from this template
- **Selective sync** of configuration files and shared utilities
- **Pull request workflow** for reviewing changes
- **Version tracking** across the ecosystem

Configure in `.github/template-sync-config.yml`:

```yaml
sync_patterns:
  - "tsconfig.json"
  - ".github/workflows/**"
  - "src/utils/**"

ignore_patterns:
  - "src/tools/**"
  - "README.md"
```

## Repository Management

```bash
./mcp-manager.sh                      # Interactive management menu
./scripts/check-ci-status.sh          # Check CI across all repos
./scripts/trigger-template-sync.sh    # Force template sync
./scripts/run-all-tests.sh           # Test all repositories
```

## CI/CD

- **Quality Gates**: Linting, type checking, testing on multiple Node.js versions
- **Semantic Releases**: Automatic versioning from conventional commits
- **NPM Publishing**: Automated package publishing with provenance
- **GitHub Releases**: Generated releases with changelogs

## Project Structure

```
mcp-template/
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── tools/                # Tool implementations
│   └── utils/                # Shared utilities
├── .github/workflows/        # CI/CD pipelines
├── scripts/                  # Management tools
└── .template-marker          # Template identification
```

## License

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

## Resources

- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [MCP Servers](https://github.com/modelcontextprotocol/servers)