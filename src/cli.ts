/**
 * @fileoverview Command-line interface for MCP template operations
 * @module cli
 */

import chalk from 'chalk';
import { Command } from 'commander';
import ora from 'ora';
import { exampleTool } from './tools/example.js';

/**
 * Create and configure the CLI command structure
 * @returns Configured Commander program instance
 * @description Sets up CLI commands for MCP template operations. This provides
 * command-line access to the same tools available via the MCP server interface.
 * @example
 * ```typescript
 * const program = createCLI();
 * await program.parseAsync(process.argv);
 * ```
 */
export function createCLI() {
	const program = new Command();

	program
		.name('mcp-template')
		.description('CLI tool for MCP template operations')
		.version('1.0.0');

	// Example tool command
	program
		.command('example <message>')
		.description('Run the example tool that echoes back the input')
		.option('-u, --uppercase', 'Convert the message to uppercase')
		.action(async (message: string, options: { uppercase?: boolean }) => {
			const spinner = ora('Running example tool...').start();
			try {
				const result = await exampleTool({
					message,
					uppercase: options.uppercase || false,
				});

				spinner.succeed(chalk.green('Example tool completed!'));
				console.log(chalk.blue('Result:'), result.content[0].text);
			} catch (error) {
				spinner.fail(chalk.red('Error running example tool'));
				console.error(error);
				process.exit(1);
			}
		});

	return program;
}
