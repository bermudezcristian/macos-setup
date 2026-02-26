#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.
set -u  # Treat unset variables as errors and exit immediately.

echo "🛠 Starting macOS setup..."

# -------------------------------
# 1. Check for Xcode CLI Tools
# -------------------------------
install_xcode_cli() {
    if ! xcode-select -p &>/dev/null; then
        echo "📦 Installing Xcode Command Line Tools..."
        xcode-select --install
        # Wait until the CLI tools are installed
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
        echo "✅ Xcode Command Line Tools installed."
    else
        echo "✅ Xcode Command Line Tools already installed."
    fi
}

# -------------------------------
# 2. Install Homebrew
# -------------------------------
install_homebrew() {
    if ! command -v brew &>/dev/null; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Determine brew path based on architecture
        local brew_prefix
        if [ "$(uname -m)" = "arm64" ]; then
            brew_prefix="/opt/homebrew"
        else
            brew_prefix="/usr/local"
        fi
        # Add brew to zprofile if not already there
        if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then
            echo "eval \"\$(${brew_prefix}/bin/brew shellenv)\"" >> ~/.zprofile
        fi
        eval "$(${brew_prefix}/bin/brew shellenv)"
        echo "✅ Homebrew installed."
    else
        echo "✅ Homebrew already installed."
    fi
    echo "🔄 Updating Homebrew..."
    brew update
    brew upgrade
}

# -------------------------------
# 3. Install packages from Brewfile
# -------------------------------
install_packages() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "📦 Installing packages from Brewfile..."
    brew bundle --file="$script_dir/Brewfile"
    echo "✅ Brewfile packages installed."
}

# -------------------------------
# 4. Optional: Set up fzf shell integration
# -------------------------------
setup_fzf_integration() {
    if [ -x "$(brew --prefix)/opt/fzf/install" ]; then
        echo "⚙️  Running fzf shell integration script..."
        yes | "$(brew --prefix)/opt/fzf/install"
        echo "✅ fzf shell integration complete."
    else
        echo "⚠️  fzf integration script not found. Skipping."
    fi
}

# -------------------------------
# 5. Configure Zsh plugins
# -------------------------------
setup_zsh_plugins() {
    echo "⚙️  Configuring Zsh plugins..."

    local zshrc="$HOME/.zshrc"
    local autosuggestions="source \$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    local syntax_highlighting="source \$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # Add zsh-autosuggestions if not present
    if ! grep -q "zsh-autosuggestions.zsh" "$zshrc" 2>/dev/null; then
        echo "🔧 Enabling zsh-autosuggestions..."
        echo -e "\n# Enable zsh-autosuggestions\n$autosuggestions" >> "$zshrc"
    fi

    # Add zsh-syntax-highlighting if not present
    if ! grep -q "zsh-syntax-highlighting.zsh" "$zshrc" 2>/dev/null; then
        echo "🔧 Enabling zsh-syntax-highlighting..."
        echo -e "\n# Enable zsh-syntax-highlighting (must be sourced last)\n$syntax_highlighting" >> "$zshrc"
    fi

    echo "✅ Zsh plugins configured. Restart your terminal or run 'source ~/.zshrc' to activate."
}

# -------------------------------
# 6. Configure GnuPG + pinentry-mac
# -------------------------------
setup_gpg() {
    echo "🔐 Configuring GnuPG and pinentry for macOS..."

    mkdir -p ~/.gnupg

    local gpg_conf="$HOME/.gnupg/gpg-agent.conf"
    local pinentry_path
    pinentry_path="$(command -v pinentry-mac || true)"

    if [ -n "$pinentry_path" ]; then
        if ! grep -q "pinentry-program" "$gpg_conf" 2>/dev/null; then
            echo "pinentry-program $pinentry_path" >> "$gpg_conf"
            echo "✅ Added pinentry-mac to gpg-agent.conf"
        fi
        chmod 600 "$gpg_conf"
    else
        echo "⚠️ pinentry-mac not found in PATH. Skipping configuration."
    fi

    # Ensure proper permissions
    chmod 700 ~/.gnupg

    # Restart gpg-agent to apply changes
    killall gpg-agent 2>/dev/null || true
    echo "✅ GPG agent configured and restarted."
}

# -------------------------------
# 7. asdf Shell Setup
# -------------------------------
setup_asdf() {
    # Add to shell config if not already present
    if ! grep -q 'asdf.sh' ~/.zshrc 2>/dev/null; then
        echo "📄 Adding asdf to ~/.zshrc..."
        echo -e '\n. $(brew --prefix asdf)/libexec/asdf.sh' >> ~/.zshrc
    fi
}

# -------------------------------
# 9. Core macOS defaults
# -------------------------------
setup_macos_core_defaults() {
    echo "⚙️  Applying core macOS defaults..."
    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    # Set default Finder view to list
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    # Restart Finder to apply changes
    killall Finder 2>/dev/null || true
    echo "✅ Core macOS defaults applied."
}

# -------------------------------
# Main execution function
# -------------------------------
main() {
    # Ensure ~/.zshrc exists before any function appends to it
    if [ ! -f "$HOME/.zshrc" ]; then
        echo "# ~/.zshrc - Created by macos-setup" > "$HOME/.zshrc"
    fi

    install_xcode_cli
    install_homebrew
    install_packages
    setup_fzf_integration
    setup_zsh_plugins
    setup_gpg
    setup_asdf
    setup_macos_core_defaults
    echo "🚀 macOS setup complete!"
    echo "🔐 Reminder: Run 'gh auth login' to authenticate GitHub CLI."
    echo "🔐 Reminder: Run 'glab auth login' to authenticate GitLab CLI."
}

main "$@"
