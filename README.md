# MCP Template

[![npm version](https://img.shields.io/npm/v/mcp-template.svg)](https://www.npmjs.com/package/mcp-template)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

## Build Status
[![CI Build](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen)](https://github.com/Mearman/mcp-template/actions/workflows/ci.yml)

## Release Status
[![Release](https://github.com/Mearman/mcp-template/actions/workflows/semantic-release.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/semantic-release.yml)
[![Template Sync](https://github.com/Mearman/mcp-template/actions/workflows/template-sync-dispatch.yml/badge.svg)](https://github.com/Mearman/mcp-template/actions/workflows/template-sync-dispatch.yml)

A TypeScript template for building MCP (Model Context Protocol) servers with automated template synchronization to downstream repositories.

## Features

- 🚀 **TypeScript with ES Modules** - Modern JavaScript with full type safety
- 🧪 **Comprehensive Testing** - Vitest with coverage reporting
- 🔧 **Code Quality** - Biome for linting and formatting
- 📦 **Automated Publishing** - Semantic versioning and NPM publishing
- 🔄 **Template Synchronization** - Automatic updates to derived repositories
- 🛠️ **Development Tools** - Hot reload, watch mode, and CLI support
- 📋 **Git Hooks** - Automated linting and commit message validation

## Quick Start

### Using as Template

1. **Use this template** on GitHub to create your new MCP server repository
2. **Clone your new repository**:
   ```bash
   git clone https://github.com/yourusername/your-mcp-server.git
   cd your-mcp-server
   ```
3. **Install dependencies**:
   ```bash
   yarn install
   ```
4. **Update configuration**:
   - Edit `package.json` with your server name and details
   - Update `src/index.ts` server name and version
   - Replace example tools in `src/tools/` with your implementations

### Development

```bash
# Start development server with hot reload
yarn dev

# Run tests
yarn test

# Run tests in watch mode
yarn test:watch

# Build the project
yarn build

# Run linting
yarn lint

# Auto-fix linting issues
yarn lint:fix
```

## Template Structure

```
mcp-template/
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── tools/
│   │   ├── example.ts        # Example tool implementation
│   │   └── example.test.ts   # Example tool tests
│   └── utils/
│       ├── validation.ts     # Common validation schemas
│       └── fetch.ts          # HTTP utilities with caching
├── .github/
│   └── workflows/
│       ├── ci.yml            # Continuous Integration
│       ├── semantic-release.yml  # Automated versioning
│       └── template-sync-*.yml   # Template synchronization
├── .template-marker          # Template tracking file
├── .template-version         # Template version tracking
└── shared/                   # Shared utilities for template sync
```

## Writing MCP Tools

### Basic Tool Example

```typescript
import { z } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';

// Define input schema
export const MyToolSchema = z.object({
  input: z.string().describe('Input parameter'),
  count: z.number().optional().default(1).describe('Number of iterations'),
});

export type MyToolInput = z.infer<typeof MyToolSchema>;

// Export tool schema for MCP registration
export const myToolSchema = {
  name: 'my_tool',
  description: 'Description of what this tool does',
  inputSchema: zodToJsonSchema(MyToolSchema),
};

// Tool implementation
export async function myTool(input: unknown) {
  const validated = MyToolSchema.parse(input);
  
  // Your tool logic here
  const result = `Processed: ${validated.input}`;
  
  return {
    content: [
      {
        type: 'text',
        text: result,
      },
    ],
  };
}
```

### Register Tools in MCP Server

```typescript
// In src/index.ts
import { myToolSchema, myTool } from './tools/my-tool.js';

// Register in ListToolsRequestSchema handler
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    myToolSchema,
    // ... other tools
  ],
}));

// Register in CallToolRequestSchema handler
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  switch (name) {
    case 'my_tool':
      return await myTool(args);
    // ... other tools
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});
```

## Template Synchronization

This template includes an automated synchronization system that keeps derived repositories up to date:

### How It Works

1. **Template Changes**: When you update the template repository
2. **Automatic Discovery**: GitHub Actions discovers all repositories created from this template
3. **Sync Dispatch**: Template changes are automatically synchronized to derived repos
4. **Pull Request Creation**: Changes are proposed via pull requests for review

### Template Marker

The `.template-marker` file identifies repositories created from this template:

```yaml
template_repository: mcp-template
template_version: 1.0.0
created_from_template: true
sync_enabled: true
```

### Customizing Sync Behavior

Edit `.github/template-sync-config.yml` to control what gets synchronized:

```yaml
sync_patterns:
  - "tsconfig.json"
  - "biome.json" 
  - "vitest.config.ts"
  - ".github/workflows/**"
  - "src/utils/validation*"
  # Add patterns for files to sync

ignore_patterns:
  - "src/tools/**"  # Don't sync tool implementations
  - "README.md"     # Keep custom README
  # Add patterns for files to ignore
```

## CI/CD Pipeline

### Continuous Integration

- **Code Quality**: Linting, formatting, and type checking
- **Testing**: Unit tests with coverage reporting
- **Build Verification**: Ensures TypeScript compiles successfully
- **Multi-Node Testing**: Tests on Node.js 18, 20, and 22

### Automated Release

- **Semantic Versioning**: Automatic version bumping based on commit messages
- **Changelog Generation**: Automatically generated from commit history
- **NPM Publishing**: Automatic package publishing on release
- **GitHub Releases**: Automatic GitHub release creation

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new tool for data processing
fix: resolve validation error in example tool
docs: update README with usage examples
chore: update dependencies
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'feat: add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

This project is licensed under the [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.

## Related Projects

- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [MCP Servers](https://github.com/modelcontextprotocol/servers)