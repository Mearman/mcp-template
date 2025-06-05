import { beforeEach, describe, expect, it, vi } from 'vitest';
import { createCLI } from './cli.js';
import * as exampleModule from './tools/example.js';

vi.mock('./tools/example.js');

describe('CLI', () => {
	let consoleLogSpy: ReturnType<typeof vi.spyOn>;
	let consoleErrorSpy: ReturnType<typeof vi.spyOn>;

	beforeEach(() => {
		vi.clearAllMocks();
		consoleLogSpy = vi.spyOn(console, 'log').mockImplementation(() => {});
		consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
	});

	it('should create CLI program', () => {
		const program = createCLI();
		expect(program.name()).toBe('mcp-template');
		expect(program.description()).toContain('MCP template');
	});

	it('should handle example command', async () => {
		vi.spyOn(exampleModule, 'exampleTool').mockResolvedValue({
			content: [
				{
					type: 'text',
					text: 'Echo: Hello World',
				},
			],
		});

		const program = createCLI();
		await program.parseAsync(['node', 'cli', 'example', 'Hello World']);

		expect(exampleModule.exampleTool).toHaveBeenCalledWith({
			message: 'Hello World',
			uppercase: false,
		});
	});

	it('should handle example command with uppercase option', async () => {
		vi.spyOn(exampleModule, 'exampleTool').mockResolvedValue({
			content: [
				{
					type: 'text',
					text: 'Echo: HELLO WORLD',
				},
			],
		});

		const program = createCLI();
		await program.parseAsync(['node', 'cli', 'example', 'Hello World', '--uppercase']);

		expect(exampleModule.exampleTool).toHaveBeenCalledWith({
			message: 'Hello World',
			uppercase: true,
		});
	});

	it('should handle errors gracefully', async () => {
		const mockProcessExit = vi.spyOn(process, 'exit').mockImplementation(() => {
			throw new Error('Process exit called');
		});

		vi.spyOn(exampleModule, 'exampleTool').mockRejectedValue(new Error('Test error'));

		const program = createCLI();

		try {
			await program.parseAsync(['node', 'cli', 'example', 'Hello World']);
		} catch (error) {
			// Expected to throw due to process.exit mock
		}

		expect(mockProcessExit).toHaveBeenCalledWith(1);
		mockProcessExit.mockRestore();
	});
});
