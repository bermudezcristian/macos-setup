# macos-setup

macOS bootstrap script that automates setting up a fresh Mac with developer tools, shell configuration, and system defaults.

## Project Structure

- `setup.sh` — Main executable script that runs all setup steps sequentially
- `Brewfile` — Declarative list of Homebrew packages and casks, installed via `brew bundle`
- `README.md` — User-facing documentation
- `CLAUDE.md` — Developer/AI-facing project conventions

## Conventions

- Shell scripts use `bash` with `set -e` (exit on error) and `set -u` (treat unset vars as errors)
- Each setup step is an isolated function called from `main()`
- Idempotent: every function checks if its work is already done before making changes
- Packages are managed via `Brewfile` and installed with `brew bundle`
- Keep README.md and CLAUDE.md in sync when the project changes

## Running

```sh
chmod +x setup.sh
./setup.sh
```
