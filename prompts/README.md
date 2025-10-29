# AI Assistant Prompts for EBWiki

This directory contains AI assistant prompt configurations for different platforms.

## Directory Structure

- **`cursor/`** - Configuration files for Cursor IDE
  - `.cursorrules` - Main rules file for Cursor
  - `.cursorroles` - Role-specific configuration

- **`gemini/`** - Configuration for Google Gemini CLI
  - `.cursorrules` - Rules formatted for Gemini CLI

- **`perplexity/`** - Configuration for Perplexity Labs
  - `.cursorrules` - Rules formatted for Perplexity Labs

## Usage

### Cursor IDE
Copy the contents of `cursor/.cursorrules` to your project root as `.cursorrules` or reference it directly if Cursor supports custom paths.

### Gemini CLI
Use the rules from `gemini/.cursorrules` when initializing Gemini CLI sessions for this project.

### Perplexity Labs
Use the rules from `perplexity/.cursorrules` when setting up Perplexity Labs for this project.

## Note
These prompt files are stored in the repository for reference but should be copied to the appropriate locations for each AI tool to take effect.

