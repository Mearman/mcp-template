import { describe, it, expect } from 'vitest';
import { exampleTool } from './example.js';

describe('exampleTool', () => {
  it('should echo the message', async () => {
    const result = await exampleTool({ message: 'Hello, world!' });
    expect(result.content[0]).toEqual({
      type: 'text',
      text: 'Echo: Hello, world!',
    });
  });

  it('should convert to uppercase when requested', async () => {
    const result = await exampleTool({ 
      message: 'Hello, world!',
      uppercase: true,
    });
    expect(result.content[0]).toEqual({
      type: 'text',
      text: 'Echo: HELLO, WORLD!',
    });
  });

  it('should validate input', async () => {
    await expect(exampleTool({})).rejects.toThrow();
    await expect(exampleTool({ message: 123 })).rejects.toThrow();
  });
});