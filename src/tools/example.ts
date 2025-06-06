import { z } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';

// Example tool input schema
export const ExampleToolSchema = z.object({
  message: z.string().describe('A message to process'),
  count: z.number().optional().default(1).describe('Number of times to repeat'),
});

export type ExampleToolInput = z.infer<typeof ExampleToolSchema>;

export const exampleToolSchema = {
  name: 'example_tool',
  description: 'An example tool that processes a message',
  inputSchema: zodToJsonSchema(ExampleToolSchema),
};

export async function exampleTool(input: unknown) {
  const validated = ExampleToolSchema.parse(input);
  
  const results = [];
  for (let i = 0; i < validated.count; i++) {
    results.push(`${i + 1}: ${validated.message}`);
  }
  
  return {
    content: [
      {
        type: 'text',
        text: results.join('\n'),
      },
    ],
  };
}