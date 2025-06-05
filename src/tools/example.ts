import { z } from 'zod';

export const ExampleToolSchema = z.object({
  message: z.string().describe('The message to echo back'),
  uppercase: z.boolean().optional().default(false).describe('Whether to return the message in uppercase'),
});

export type ExampleToolInput = z.infer<typeof ExampleToolSchema>;

export async function exampleTool(args: unknown) {
  const input = ExampleToolSchema.parse(args);
  
  let result = input.message;
  if (input.uppercase) {
    result = result.toUpperCase();
  }
  
  return {
    content: [
      {
        type: 'text',
        text: `Echo: ${result}`,
      },
    ],
  };
}