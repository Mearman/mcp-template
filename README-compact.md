# MCP Template

[![CI](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)
[![Release](https://github.com/Mearman/mcp-template/actions/workflows/semantic-release.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/semantic-release.yml)
[![Coverage](.github/badges/coverage.svg)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)

A TypeScript template for building MCP (Model Context Protocol) servers with automated template synchronization to downstream repositories.

## 🚀 Quick Start

```bash
# Use this template to create your MCP server
git clone https://github.com/yourusername/your-mcp-server.git
cd your-mcp-server
yarn install

# Start developing
yarn dev
```

## 📊 Ecosystem Status

**Template Repository**: [![GitHub release](https://img.shields.io/github/v/release/Mearman/mcp-template.svg)](https://github.com/Mearman/mcp-template/releases) (Not published to NPM)

**Derived MCP Servers**:

- **[mcp-wayback-machine](https://github.com/Mearman/mcp-wayback-machine)** - Internet Archive integration  
  [![CI](https://github.com/Mearman/mcp-wayback-machine/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/mcp-wayback-machine/actions/workflows/ci.yml) [![npm](https://img.shields.io/npm/v/mcp-wayback-machine.svg)](https://www.npmjs.com/package/mcp-wayback-machine)

- **[mcp-openalex](https://github.com/Mearman/mcp-openalex)** - Academic knowledge graph  
  [![CI](https://github.com/Mearman/mcp-openalex/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/mcp-openalex/actions/workflows/ci.yml) [![npm](https://img.shields.io/npm/v/mcp-openalex.svg)](https://www.npmjs.com/package/mcp-openalex)

- **[mcp-mcp](https://github.com/Mearman/mcp-mcp)** - Template with examples  
  [![CI](https://github.com/Mearman/mcp-mcp/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/mcp-mcp/actions/workflows/ci.yml) [![npm](https://img.shields.io/npm/v/mcp-mcp.svg)](https://www.npmjs.com/package/mcp-mcp)

- **[mcp-ollama](https://github.com/Mearman/mcp-ollama)** - Ollama model integration  
  [![CI](https://github.com/Mearman/mcp-ollama/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/mcp-ollama/actions/workflows/ci.yml) [![npm](https://img.shields.io/npm/v/mcp-ollama.svg)](https://www.npmjs.com/package/mcp-ollama)

## ✨ Features

**Development Experience**
- 🔷 TypeScript with ES Modules & strict typing
- 🔥 Hot reload development with `tsx`
- 🧪 Vitest testing with coverage reporting
- 🎯 Biome for linting and formatting

**Automation & CI/CD**
- 📦 Semantic versioning & automated NPM publishing
- 🔄 Template synchronization to derived repositories
- 🛡️ GitHub Actions CI with multi-Node testing
- 📋 Git hooks for quality enforcement

**Template System**
- 🎨 Automatic discovery of derived repositories
- 🔀 Configurable file sync patterns
- 📝 Pull request workflow for updates
- 🏷️ Version tracking across ecosystem

## 🛠️ Development

```bash
yarn dev          # Hot reload development
yarn test         # Run tests with coverage
yarn test:watch   # Watch mode for TDD
yarn build        # TypeScript compilation
yarn lint         # Check code quality
yarn lint:fix     # Auto-fix issues
```

## 📝 Creating MCP Tools

```typescript
import { z } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';

// Define schema
export const MyToolSchema = z.object({
  input: z.string().describe('Input parameter'),
  count: z.number().optional().default(1),
});

// Create tool definition
export const myToolSchema = {
  name: 'my_tool',
  description: 'What this tool does',
  inputSchema: zodToJsonSchema(MyToolSchema),
};

// Implement tool logic
export async function myTool(input: unknown) {
  const validated = MyToolSchema.parse(input);
  return {
    content: [{ type: 'text', text: `Result: ${validated.input}` }],
  };
}
```

Register in `src/index.ts`:

```typescript
// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [myToolSchema],
}));

// Handle tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  switch (request.params.name) {
    case 'my_tool': return await myTool(request.params.arguments);
    default: throw new Error(`Unknown tool: ${request.params.name}`);
  }
});
```

## 🔄 Template Synchronization

The template automatically synchronizes updates to all derived repositories:

1. **Change Detection**: Updates trigger GitHub Actions
2. **Repository Discovery**: Finds all template-derived repos
3. **Selective Sync**: Only syncs configured files (workflows, configs, utilities)
4. **PR Creation**: Proposes changes via pull requests for review

**Configuration** (`.github/template-sync-config.yml`):
```yaml
sync_patterns:
  - "tsconfig.json"
  - ".github/workflows/**"
  - "src/utils/validation*"

ignore_patterns:
  - "src/tools/**"  # Keep custom implementations
  - "README.md"     # Preserve documentation
```

## 🚦 CI/CD Pipeline

**Continuous Integration**
- Code quality checks (lint, format, type-check)
- Multi-version Node.js testing (18, 20, 22)
- Test coverage reporting and PR comments
- Build verification

**Automated Releases**
- Semantic versioning from commit messages
- Automatic changelog generation
- GitHub releases with generated notes
- NPM publishing (when configured)

**Commit Message Format** ([Conventional Commits](https://www.conventionalcommits.org/)):
```bash
feat: add new tool     # Minor version bump
fix: resolve bug       # Patch version bump
feat!: breaking change # Major version bump
docs: update README    # No version bump
```

## 🔧 Repository Management

Interactive management tools for the MCP ecosystem:

```bash
./mcp-manager.sh                      # Interactive menu
./scripts/check-ci-status.sh          # CI status across repos
./scripts/trigger-template-sync.sh    # Force template sync
./scripts/run-all-tests.sh           # Test all repositories
```

## 📚 Project Structure

```
mcp-template/
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── tools/                # Tool implementations
│   └── utils/                # Shared utilities
├── .github/workflows/        # CI/CD pipelines
├── scripts/                  # Management tools
├── shared/                   # Template sync utilities
└── .template-marker          # Template identification
```

## 🤝 Contributing

1. Fork repository
2. Create feature branch: `git checkout -b feature/name`
3. Follow conventional commits: `git commit -m 'feat: description'`
4. Push and create Pull Request

## 📄 License

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

## 🔗 Related

- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [MCP Servers](https://github.com/modelcontextprotocol/servers)