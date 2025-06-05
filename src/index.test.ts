import { describe, expect, it } from 'vitest';

describe('MCP Server', () => {
	it('should export as ES module', async () => {
		// This test verifies the module can be imported
		const module = await import('./index.js');
		expect(module).toBeDefined();
	});
});
