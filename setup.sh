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
        # Add brew to zprofile if not already there
        if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "✅ Homebrew installed."
    else
        echo "✅ Homebrew already installed."
    fi
    echo "🔄 Updating Homebrew..."
    brew update
    brew upgrade
}

# -------------------------------
# 3. Install CLI tools
# -------------------------------
install_cli_tools() {
    local tools=(
        fzf
        gh
        git
        glab
        gnupg
        htop
        jq
        mas
        neovim
        nmap
        pinentry-mac
        tmux
        tree
        vim
        watch
        wget
        zsh-autosuggestions
        zsh-syntax-highlighting
    )

    echo "📦 Installing CLI tools: ${tools[*]}"
    for tool in "${tools[@]}"; do
        if ! brew list "$tool" &>/dev/null; then
            echo "🔧 Installing $tool..."
            brew install "$tool"
        else
            echo "✅ $tool is already installed, skipping."
        fi
    done
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
    else
        echo "⚠️ pinentry-mac not found in PATH. Skipping configuration."
    fi

    # Ensure proper permissions
    chmod 700 ~/.gnupg
    chmod 600 "$gpg_conf"

    # Restart gpg-agent to apply changes
    killall gpg-agent 2>/dev/null || true
    echo "✅ GPG agent configured and restarted."
}

# -------------------------------
# 7. asdf Installation & Shell Setup
# -------------------------------
install_asdf() {
    if ! brew list asdf &>/dev/null; then
        echo "🔧 Installing asdf version manager..."
        brew install asdf
    else
        echo "✅ asdf already installed."
    fi

    # Add to shell config if not already present
    if ! grep -q 'asdf.sh' ~/.zshrc 2>/dev/null; then
        echo "📄 Adding asdf to ~/.zshrc..."
        echo -e '\n. $(brew --prefix asdf)/libexec/asdf.sh' >> ~/.zshrc
    fi
}

# -------------------------------
# 8. Install macOS apps (Casks)
# -------------------------------
install_casks() {
    local casks=(
        font-meslo-lg-nerd-font
        stats
    )

    echo "📦 Installing macOS apps (casks): ${casks[*]}"
    for app in "${casks[@]}"; do
        if ! brew list --cask "$app" &>/dev/null; then
            echo "🔧 Installing $app..."
            brew install --cask "$app"
        else
            echo "✅ $app already installed, skipping."
        fi
    done
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
    install_xcode_cli
    install_homebrew
    install_cli_tools
    setup_fzf_integration
    setup_zsh_plugins
    setup_gpg
    install_asdf
    install_casks
    setup_macos_core_defaults
    echo "🚀 macOS setup complete!"
    echo "🔐 Reminder: Run 'gh auth login' to authenticate GitHub CLI."
    echo "🔐 Reminder: Run 'glab auth login' to authenticate GitLab CLI."
}

main "$@"
