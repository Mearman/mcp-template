/**
 * @fileoverview Basic tests for the MCP server entry point
 * @module index.test
 */

import { describe, expect, it } from 'vitest';

/**
 * Test suite for the MCP server module
 */
describe('MCP Server', () => {
	/**
	 * Test that the server module can be imported as an ES module
	 */
	it('should export as ES module', async () => {
		const module = await import('./index.js');
		expect(module).toBeDefined();
	});
});
