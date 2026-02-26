# macos-setup

macOS bootstrap script that automates setting up a fresh Mac with developer tools, shell configuration, and system defaults.

## Project Structure

- `setup.sh` — Single executable script that runs all setup steps sequentially

## Conventions

- Shell scripts use `bash` with `set -e` (exit on error) and `set -u` (treat unset vars as errors)
- Each setup step is an isolated function called from `main()`
- Idempotent: every function checks if its work is already done before making changes
- Homebrew is the primary package manager for CLI tools and macOS apps (casks)

## Running

```sh
chmod +x setup.sh
./setup.sh
```
