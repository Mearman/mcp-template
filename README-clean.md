# MCP Template

A TypeScript template for building MCP (Model Context Protocol) servers with automated template synchronization.

## Status

[![CI](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)
[![Release](https://github.com/Mearman/mcp-template/actions/workflows/semantic-release.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/semantic-release.yml)
[![Coverage](.github/badges/coverage.svg)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)
[![Template Sync](https://github.com/Mearman/mcp-template/actions/workflows/template-sync-dispatch.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/template-sync-dispatch.yml)

## Derived MCP Servers

This template has been used to create the following MCP servers:

<table>
<thead>
<tr>
<th>Server</th>
<th>Description</th>
<th>Status</th>
<th>Version</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-wayback-machine">wayback-machine</a></strong></td>
<td>Internet Archive Wayback Machine integration</td>
<td><a href="https://github.com/Mearman/mcp-wayback-machine/actions/workflows/ci.yml"><img src="https://github.com/Mearman/mcp-wayback-machine/actions/workflows/ci.yml/badge.svg" alt="CI"></a></td>
<td><a href="https://www.npmjs.com/package/mcp-wayback-machine"><img src="https://img.shields.io/npm/v/mcp-wayback-machine.svg" alt="npm"></a></td>
</tr>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-openalex">openalex</a></strong></td>
<td>OpenAlex academic knowledge graph access</td>
<td><a href="https://github.com/Mearman/mcp-openalex/actions/workflows/ci.yml"><img src="https://github.com/Mearman/mcp-openalex/actions/workflows/ci.yml/badge.svg" alt="CI"></a></td>
<td><a href="https://www.npmjs.com/package/mcp-openalex"><img src="https://img.shields.io/npm/v/mcp-openalex.svg" alt="npm"></a></td>
</tr>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-mcp">mcp</a></strong></td>
<td>Template-based server with examples</td>
<td><a href="https://github.com/Mearman/mcp-mcp/actions/workflows/ci.yml"><img src="https://github.com/Mearman/mcp-mcp/actions/workflows/ci.yml/badge.svg" alt="CI"></a></td>
<td><a href="https://www.npmjs.com/package/mcp-mcp"><img src="https://img.shields.io/npm/v/mcp-mcp.svg" alt="npm"></a></td>
</tr>
<tr>
<td><strong><a href="https://github.com/Mearman/mcp-ollama">ollama</a></strong></td>
<td>Ollama model integration server</td>
<td><a href="https://github.com/Mearman/mcp-ollama/actions/workflows/ci.yml"><img src="https://github.com/Mearman/mcp-ollama/actions/workflows/ci.yml/badge.svg" alt="CI"></a></td>
<td><a href="https://www.npmjs.com/package/mcp-ollama"><img src="https://img.shields.io/npm/v/mcp-ollama.svg" alt="npm"></a></td>
</tr>
</tbody>
</table>

## Features

- **TypeScript with ES Modules** - Modern JavaScript with full type safety
- **Comprehensive Testing** - Vitest with coverage reporting
- **Code Quality** - Biome for linting and formatting
- **Automated Publishing** - Semantic versioning and NPM publishing
- **Template Synchronization** - Automatic updates to derived repositories
- **Development Tools** - Hot reload, watch mode, and CLI support
- **Git Hooks** - Automated linting and commit message validation

## Quick Start

### 1. Create from Template

Click **"Use this template"** on GitHub to create your new MCP server repository.

### 2. Setup Project

```bash
git clone https://github.com/yourusername/your-mcp-server.git
cd your-mcp-server
yarn install
```

### 3. Configure

- Update `package.json` with your server details
- Edit `src/index.ts` server name and version
- Replace `src/tools/example.ts` with your tool implementations

### 4. Develop

```bash
yarn dev        # Start development with hot reload
yarn test       # Run tests with coverage
yarn build      # Compile TypeScript
yarn lint       # Check code quality
```

## Writing MCP Tools

### Tool Definition

```typescript
import { z } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';

// Define input validation schema
export const SearchSchema = z.object({
  query: z.string().describe('Search query'),
  limit: z.number().optional().default(10).describe('Maximum results'),
});

// Export tool schema for MCP
export const searchToolSchema = {
  name: 'search',
  description: 'Search for items',
  inputSchema: zodToJsonSchema(SearchSchema),
};

// Implement tool logic
export async function searchTool(input: unknown) {
  const { query, limit } = SearchSchema.parse(input);
  
  // Your implementation here
  const results = await performSearch(query, limit);
  
  return {
    content: [
      {
        type: 'text',
        text: JSON.stringify(results, null, 2),
      },
    ],
  };
}
```

### Server Registration

Register tools in `src/index.ts`:

```typescript
import { searchToolSchema, searchTool } from './tools/search.js';

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [searchToolSchema],
}));

// Handle tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  switch (name) {
    case 'search':
      return await searchTool(args);
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});
```

## Template Synchronization

This template automatically keeps derived repositories up to date:

### How It Works

1. **Change Detection** - Template updates trigger GitHub Actions
2. **Repository Discovery** - Automatically finds all derived repositories
3. **Selective Sync** - Only synchronizes configured files and patterns
4. **Pull Request Workflow** - Proposes changes for review before merging

### Configuration

Control synchronization behavior in `.github/template-sync-config.yml`:

```yaml
sync_patterns:
  - "tsconfig.json"
  - "biome.json"
  - "vitest.config.ts"
  - ".github/workflows/**"
  - "src/utils/**"

ignore_patterns:
  - "src/tools/**"     # Preserve custom tool implementations
  - "README.md"        # Keep repository-specific documentation
  - "package.json"     # Maintain individual package configurations
```

### Template Marker

Repositories created from this template include a `.template-marker` file:

```yaml
template_repository: mcp-template
template_version: 1.0.0
created_from_template: true
sync_enabled: true
```

## CI/CD Pipeline

### Automated Quality Checks

- **Linting and Formatting** - Biome ensures consistent code style
- **Type Checking** - TypeScript strict mode catches errors early
- **Testing** - Vitest runs unit tests with coverage reporting
- **Multi-Node Testing** - Validates compatibility with Node.js 18, 20, and 22

### Semantic Releases

Automated versioning based on commit message conventions:

```bash
feat: add new feature      # Minor version (1.0.0 → 1.1.0)
fix: resolve bug          # Patch version (1.0.0 → 1.0.1)
feat!: breaking change    # Major version (1.0.0 → 2.0.0)
docs: update README       # No version change
```

### Publishing

- **Automatic NPM Publishing** - Releases are published automatically
- **GitHub Releases** - Generated with changelog and release notes
- **Build Artifacts** - Compiled TypeScript with source maps and declarations

## Repository Management

### Management Scripts

```bash
# Interactive management interface
./mcp-manager.sh

# Individual operations
./scripts/check-ci-status.sh          # Check CI status across all repos
./scripts/trigger-template-sync.sh    # Force template synchronization
./scripts/check-template-sync-prs.sh  # Monitor sync pull requests
./scripts/run-all-tests.sh           # Run tests across all repositories
```

### Project Structure

```
mcp-template/
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── tools/                # Tool implementations
│   │   ├── example.ts        # Example tool
│   │   └── example.test.ts   # Tool tests
│   └── utils/                # Shared utilities
│       ├── fetch.ts          # HTTP client with caching
│       └── validation.ts     # Common validation schemas
├── .github/
│   └── workflows/            # CI/CD pipelines
├── scripts/                  # Repository management tools
├── shared/                   # Template synchronization utilities
└── .template-marker          # Template identification
```

## Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** using conventional format: `git commit -m 'feat: add amazing feature'`
4. **Push** to your branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

## License

This project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

## Resources

- **[MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)** - Official SDK
- **[MCP Specification](https://spec.modelcontextprotocol.io/)** - Protocol documentation
- **[MCP Servers](https://github.com/modelcontextprotocol/servers)** - Official server implementations