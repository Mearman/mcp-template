import { z } from 'zod';

/**
 * Common validation schemas for reuse across tools
 */

// URL validation
export const urlSchema = z.string().url('Invalid URL format');

// Date validation
export const dateSchema = z.string().regex(
  /^\d{4}-\d{2}-\d{2}$/,
  'Date must be in YYYY-MM-DD format'
);

// Timestamp validation (YYYYMMDDHHmmss)
export const timestampSchema = z.string().regex(
  /^\d{14}$/,
  'Timestamp must be in YYYYMMDDHHmmss format'
);

/**
 * Validate and parse input with helpful error messages
 */
export function validateInput<T>(schema: z.ZodSchema<T>, input: unknown): T {
  try {
    return schema.parse(input);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const issues = error.issues.map(issue => `${issue.path.join('.')}: ${issue.message}`);
      throw new Error(`Validation failed:\n${issues.join('\n')}`);
    }
    throw error;
  }
}