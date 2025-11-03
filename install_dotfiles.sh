#!/usr/bin/env bash
# =============================================================================
# install_dotfiles.sh - Automated Dotfiles Installation for Ubuntu
# 
# This script installs and configures zsh, starship, and alacritty on Ubuntu
# systems using GNU Stow for symlink management.
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
	echo -e "\n${BLUE}===================================================${NC}"
	echo -e "${BLUE}$1${NC}"
	echo -e "${BLUE}===================================================${NC}\n"
}

print_success() {
	echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
	echo -e "${RED}✗ $1${NC}"
}

print_warning() {
	echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
	echo -e "${BLUE}ℹ $1${NC}"
}

command_exists() {
	command -v "$1" &> /dev/null
}

# =============================================================================
# Installation Functions
# =============================================================================

install_zsh() {
	print_header "Installing ZSH"
	
	if command_exists zsh; then
		print_warning "ZSH is already installed"
		zsh --version
	else
		print_info "Installing ZSH..."
		sudo apt update
		sudo apt install -y zsh
		print_success "ZSH installed successfully"
	fi
}

install_starship() {
	print_header "Installing Starship Prompt"
	
	if command_exists starship; then
		print_warning "Starship is already installed"
		starship --version
	else
		print_info "Installing Starship..."
		curl -sS https://starship.rs/install.sh | sh -s -- -y
		print_success "Starship installed successfully"
	fi
}

install_alacritty() {
	print_header "Installing Alacritty Terminal"
	
	if command_exists alacritty; then
		print_warning "Alacritty is already installed"
		alacritty --version
	else
		print_info "Installing Alacritty..."
		sudo apt update
		sudo apt install -y alacritty
		print_success "Alacritty installed successfully"
	fi
}

install_jetbrains_mono() {
	print_header "Installing JetBrains Mono Font"
	
	if fc-list | grep -qi "JetBrains Mono"; then
		print_warning "JetBrains Mono font is already installed"
	else
		print_info "Installing JetBrains Mono font..."
		
		# Create fonts directory
		mkdir -p ~/.local/share/fonts
		
		# Download and install JetBrains Mono
		cd /tmp
		wget -q https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
		unzip -q JetBrainsMono-2.304.zip -d JetBrainsMono
		cp JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts/
		
		# Update font cache
		fc-cache -f -v > /dev/null 2>&1
		
		# Clean up
		rm -rf JetBrainsMono JetBrainsMono-2.304.zip
		
		print_success "JetBrains Mono font installed successfully"
	fi
}

install_stow() {
	print_header "Installing GNU Stow"
	
	if command_exists stow; then
		print_warning "GNU Stow is already installed"
		stow --version | head -n 1
	else
		print_info "Installing GNU Stow..."
		sudo apt update
		sudo apt install -y stow
		print_success "GNU Stow installed successfully"
	fi
}

install_optional_tools() {
	print_header "Installing Optional Tools"
	
	print_info "The following tools enhance your terminal experience:"
	echo "  - eza: Modern replacement for ls"
	echo "  - fzf: Fuzzy finder"
	echo "  - bat: Better cat with syntax highlighting"
	echo "  - zoxide: Smarter cd command"
	echo "  - ripgrep: Fast grep alternative"
	echo ""
	
	read -p "Do you want to install these optional tools? (y/N): " -n 1 -r
	echo
	
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		print_info "Installing optional tools..."
		
		sudo apt update
		
		# eza (modern ls replacement)
		if ! command_exists eza; then
			print_info "Installing eza..."
			sudo apt install -y gpg
			sudo mkdir -p /etc/apt/keyrings
			wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
			echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
			sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
			sudo apt update
			sudo apt install -y eza
		fi
		
		# fzf
		if ! command_exists fzf; then
			print_info "Installing fzf..."
			sudo apt install -y fzf
		fi
		
		# bat
		if ! command_exists bat; then
			print_info "Installing bat..."
			sudo apt install -y bat
			# Create symlink (Ubuntu installs it as batcat)
			mkdir -p ~/.local/bin
			ln -sf /usr/bin/batcat ~/.local/bin/bat
		fi
		
		# ripgrep
		if ! command_exists rg; then
			print_info "Installing ripgrep..."
			sudo apt install -y ripgrep
		fi
		
		# zoxide
		if ! command_exists zoxide; then
			print_info "Installing zoxide..."
			curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
		fi
		
		print_success "Optional tools installed successfully"
	else
		print_info "Skipping optional tools installation"
	fi
}

setup_directories() {
	print_header "Setting Up Directories"
	
	print_info "Creating necessary directories..."
	mkdir -p ~/.config
	mkdir -p ~/.config/alacritty
	print_success "Directories created successfully"
}

backup_existing_configs() {
	print_header "Backing Up Existing Configurations"
	
	local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
	local files_backed_up=false
	
	if [ -f ~/.zshrc ]; then
		mkdir -p "$backup_dir"
		print_info "Backing up existing .zshrc..."
		cp ~/.zshrc "$backup_dir/"
		files_backed_up=true
	fi
	
	if [ -f ~/.config/starship.toml ]; then
		mkdir -p "$backup_dir/.config"
		print_info "Backing up existing starship.toml..."
		cp ~/.config/starship.toml "$backup_dir/.config/"
		files_backed_up=true
	fi
	
	if [ -f ~/.config/alacritty/alacritty.yml ]; then
		mkdir -p "$backup_dir/.config/alacritty"
		print_info "Backing up existing alacritty.yml..."
		cp ~/.config/alacritty/alacritty.yml "$backup_dir/.config/alacritty/"
		files_backed_up=true
	fi
	
	if [ "$files_backed_up" = true ]; then
		print_success "Backup created at: $backup_dir"
	else
		print_info "No existing configurations found to backup"
	fi
}

apply_dotfiles() {
	print_header "Applying Dotfiles with GNU Stow"
	
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local ubuntu_dir="$script_dir"
	
	print_info "Dotfiles directory: $ubuntu_dir"
	
	# Remove existing symlinks or files
	if [ -L ~/.zshrc ] || [ -f ~/.zshrc ]; then
		print_info "Removing existing .zshrc..."
		rm -f ~/.zshrc
	fi
	
	if [ -L ~/.config/starship.toml ] || [ -f ~/.config/starship.toml ]; then
		print_info "Removing existing starship.toml..."
		rm -f ~/.config/starship.toml
	fi
	
	if [ -L ~/.config/alacritty/alacritty.yml ] || [ -f ~/.config/alacritty/alacritty.yml ]; then
		print_info "Removing existing alacritty.yml..."
		rm -f ~/.config/alacritty/alacritty.yml
	fi
	
	# Apply stow
	cd "$ubuntu_dir"
	
	print_info "Stowing zsh configuration..."
	stow -v -t ~ zsh
	
	print_info "Stowing starship configuration..."
	stow -v -t ~ starship
	
	print_info "Stowing alacritty configuration..."
	stow -v -t ~ alacritty
	
	cd - > /dev/null
	print_success "Dotfiles applied successfully"
}

set_zsh_default() {
	print_header "Setting ZSH as Default Shell"
	
	if [ "$SHELL" = "$(which zsh)" ]; then
		print_warning "ZSH is already your default shell"
	else
		print_info "Changing default shell to ZSH..."
		chsh -s "$(which zsh)"
		print_success "Default shell changed to ZSH"
		print_warning "Please log out and log back in for the change to take effect"
	fi
}

# =============================================================================
# Main Installation Process
# =============================================================================

main() {
	print_header "Ubuntu Dotfiles Installation"
	echo "This script will install and configure:"
	echo "  • ZSH (Z Shell)"
	echo "  • Starship (Cross-shell prompt)"
	echo "  • Alacritty (GPU-accelerated terminal emulator)"
	echo "  • JetBrains Mono (Font)"
	echo "  • GNU Stow (Symlink manager)"
	echo "  • Optional: eza, fzf, bat, zoxide, ripgrep"
	echo ""
	
	read -p "Do you want to continue? (Y/n): " -n 1 -r
	echo
	
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
		# Check if running on Ubuntu
		if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
			print_warning "This script is designed for Ubuntu. Continuing anyway..."
		fi
		
		# Installation steps
		install_zsh
		install_starship
		install_alacritty
		install_jetbrains_mono
		install_stow
		install_optional_tools
		setup_directories
		backup_existing_configs
		apply_dotfiles
		set_zsh_default
		
		# Final message
		print_header "Installation Complete!"
		echo -e "${GREEN}Your dotfiles have been installed successfully!${NC}\n"
		echo "Next steps:"
		echo "  1. Log out and log back in (or restart your terminal)"
		echo "  2. ZSH will be your default shell"
		echo "  3. Launch Alacritty from your applications menu"
		echo "  4. Starship prompt will be automatically loaded in ZSH"
		echo ""
		echo "Useful commands:"
		echo "  • 'dotfiles' - Navigate to dotfiles directory"
		echo "  • 'ls' or 'l' - List files (with eza if installed)"
		echo "  • Edit ~/.zshrc to customize your shell"
		echo "  • Edit ~/.config/alacritty/alacritty.yml to customize Alacritty"
		echo ""
		print_success "Enjoy your new terminal setup! 🚀"
	else
		print_info "Installation cancelled"
		exit 0
	fi
}

# Run main function
main
