# macos-setup

Automates setting up a fresh Mac with developer tools, shell configuration, and system defaults.

## What It Does

1. Installs Xcode Command Line Tools
2. Installs and configures Homebrew (Apple Silicon + Intel)
3. Installs CLI tools and casks from `Brewfile`
4. Sets up fzf shell integration
5. Configures Zsh plugins (autosuggestions, syntax highlighting)
6. Configures GnuPG with pinentry-mac
7. Adds asdf version manager to shell
8. Applies macOS Finder defaults (show extensions, hidden files, list view)

## Usage

```sh
git clone https://github.com/bermudezcristian/macos-setup.git
cd macos-setup
chmod +x setup.sh
./setup.sh
```

## Customizing Packages

Edit the `Brewfile` to add or remove CLI tools and casks:

```
brew "tool-name"
cask "app-name"
```

## Post-Setup

- Run `gh auth login` to authenticate GitHub CLI
- Run `glab auth login` to authenticate GitLab CLI
