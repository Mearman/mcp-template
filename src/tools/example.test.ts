import { describe, expect, it } from 'vitest';
import { ExampleToolSchema, exampleTool } from './example';

describe('Example Tool', () => {
	it('should process a simple message', async () => {
		const input = { message: 'Hello, world!' };
		const result = await exampleTool(input);

		expect(result.content).toHaveLength(1);
		expect(result.content[0].text).toBe('1: Hello, world!');
	});

	it('should repeat message multiple times', async () => {
		const input = { message: 'Test', count: 3 };
		const result = await exampleTool(input);

		expect(result.content[0].text).toBe('1: Test\n2: Test\n3: Test');
	});

	it('should validate input schema', () => {
		expect(() => ExampleToolSchema.parse({ message: 'valid' })).not.toThrow();
		expect(() => ExampleToolSchema.parse({ message: 123 })).toThrow();
		expect(() => ExampleToolSchema.parse({})).toThrow();
	});
});
