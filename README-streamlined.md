# MCP Template

[![CI](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)
[![Coverage](.github/badges/coverage.svg)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)

TypeScript template for building MCP (Model Context Protocol) servers with automated template synchronization.

## MCP Server Ecosystem

| Repository | CI | Release | NPM | Coverage |
|------------|:--:|:-------:|:---:|:-------:|
| **[mcp-template](https://github.com/Mearman/mcp-template)**<br/>Base template repository | ![CI](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml/badge.svg) | ![Release](https://img.shields.io/github/v/release/Mearman/mcp-template.svg) | *Template* | ![Coverage](.github/badges/coverage.svg) |
| **[mcp-wayback-machine](https://github.com/Mearman/mcp-wayback-machine)**<br/>Internet Archive integration | ![CI](https://github.com/Mearman/mcp-wayback-machine/actions/workflows/ci.yml/badge.svg) | ![Release](https://img.shields.io/github/v/release/Mearman/mcp-wayback-machine.svg) | ![npm](https://img.shields.io/npm/v/mcp-wayback-machine.svg) | ![Coverage](https://img.shields.io/badge/coverage-95%25-brightgreen) |
| **[mcp-openalex](https://github.com/Mearman/mcp-openalex)**<br/>Academic knowledge graph | ![CI](https://github.com/Mearman/mcp-openalex/actions/workflows/ci.yml/badge.svg) | ![Release](https://img.shields.io/github/v/release/Mearman/mcp-openalex.svg) | ![npm](https://img.shields.io/npm/v/mcp-openalex.svg) | ![Coverage](https://img.shields.io/badge/coverage-90%25-brightgreen) |
| **[mcp-mcp](https://github.com/Mearman/mcp-mcp)**<br/>Template with examples | ![CI](https://github.com/Mearman/mcp-mcp/actions/workflows/ci.yml/badge.svg) | ![Release](https://img.shields.io/github/v/release/Mearman/mcp-mcp.svg) | ![npm](https://img.shields.io/npm/v/mcp-mcp.svg) | ![Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen) |
| **[mcp-ollama](https://github.com/Mearman/mcp-ollama)**<br/>Ollama model integration | ![CI](https://github.com/Mearman/mcp-ollama/actions/workflows/ci.yml/badge.svg) | ![Release](https://img.shields.io/github/v/release/Mearman/mcp-ollama.svg) | ![npm](https://img.shields.io/npm/v/mcp-ollama.svg) | ![Coverage](https://img.shields.io/badge/coverage-80%25-brightgreen) |

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