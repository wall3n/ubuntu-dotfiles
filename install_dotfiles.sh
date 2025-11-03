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

check_os_compatibility() {
	if [ ! -f /etc/os-release ]; then
		print_error "Cannot determine OS. /etc/os-release not found."
		return 1
	fi
	
	if ! grep -q "Ubuntu" /etc/os-release && ! grep -q "Debian" /etc/os-release; then
		print_warning "This script is designed for Ubuntu/Debian-based systems."
		read -p "Do you want to continue anyway? (y/N): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			return 1
		fi
	fi
	return 0
}

detect_conflicting_files() {
	print_header "Detecting Conflicting Files"
	
	local conflicts=()
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	
	# Check for conflicting zsh files
	if [ -e ~/.zshrc ] && [ ! -L ~/.zshrc ]; then
		conflicts+=("~/.zshrc (regular file)")
	fi
	
	if [ -L ~/.zshrc ]; then
		local link_target=$(readlink ~/.zshrc)
		if [[ ! "$link_target" =~ "$script_dir" ]]; then
			conflicts+=("~/.zshrc (symlink to: $link_target)")
		fi
	fi
	
	if [ -e ~/.zshenv ] && [ ! -L ~/.zshenv ]; then
		conflicts+=("~/.zshenv (regular file)")
	fi
	
	if [ -e ~/.zprofile ] && [ ! -L ~/.zprofile ]; then
		conflicts+=("~/.zprofile (regular file)")
	fi
	
	# Check for conflicting starship files
	if [ -e ~/.config/starship.toml ] && [ ! -L ~/.config/starship.toml ]; then
		conflicts+=("~/.config/starship.toml (regular file)")
	fi
	
	if [ -L ~/.config/starship.toml ]; then
		local link_target=$(readlink ~/.config/starship.toml)
		if [[ ! "$link_target" =~ "$script_dir" ]]; then
			conflicts+=("~/.config/starship.toml (symlink to: $link_target)")
		fi
	fi
	
	# Check for conflicting alacritty files
	if [ -e ~/.config/alacritty/alacritty.yml ] && [ ! -L ~/.config/alacritty/alacritty.yml ]; then
		conflicts+=("~/.config/alacritty/alacritty.yml (regular file)")
	fi
	
	if [ -e ~/.config/alacritty/alacritty.toml ] && [ ! -L ~/.config/alacritty/alacritty.toml ]; then
		conflicts+=("~/.config/alacritty/alacritty.toml (regular file)")
	fi
	
	if [ -L ~/.config/alacritty/alacritty.yml ]; then
		local link_target=$(readlink ~/.config/alacritty/alacritty.yml)
		if [[ ! "$link_target" =~ "$script_dir" ]]; then
			conflicts+=("~/.config/alacritty/alacritty.yml (symlink to: $link_target)")
		fi
	fi
	
	# Check for conflicting alacritty directory symlink
	if [ -L ~/.config/alacritty ] && [ ! -d ~/.config/alacritty ]; then
		local link_target=$(readlink ~/.config/alacritty)
		conflicts+=("~/.config/alacritty (symlink to: $link_target)")
	fi
	
	if [ ${#conflicts[@]} -gt 0 ]; then
		print_warning "Found ${#conflicts[@]} conflicting file(s):"
		for conflict in "${conflicts[@]}"; do
			echo "  - $conflict"
		done
		echo ""
		return 0
	else
		print_success "No conflicting files detected"
		return 1
	fi
}

remove_conflicting_files() {
	print_header "Removing Conflicting Files"
	
	local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
	mkdir -p "$backup_dir"
	mkdir -p "$backup_dir/.config/alacritty"
	
	# Backup and remove zsh files
	if [ -e ~/.zshrc ]; then
		if [ ! -L ~/.zshrc ] || [[ ! "$(readlink ~/.zshrc)" =~ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" ]]; then
			print_info "Backing up and removing ~/.zshrc..."
			cp -L ~/.zshrc "$backup_dir/.zshrc" 2>/dev/null || true
			rm -f ~/.zshrc
		fi
	fi
	
	if [ -e ~/.zshenv ]; then
		print_info "Backing up and removing ~/.zshenv..."
		cp -L ~/.zshenv "$backup_dir/.zshenv" 2>/dev/null || true
		rm -f ~/.zshenv
	fi
	
	if [ -e ~/.zprofile ]; then
		print_info "Backing up and removing ~/.zprofile..."
		cp -L ~/.zprofile "$backup_dir/.zprofile" 2>/dev/null || true
		rm -f ~/.zprofile
	fi
	
	# Backup and remove starship files
	if [ -e ~/.config/starship.toml ]; then
		if [ ! -L ~/.config/starship.toml ] || [[ ! "$(readlink ~/.config/starship.toml)" =~ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" ]]; then
			print_info "Backing up and removing ~/.config/starship.toml..."
			cp -L ~/.config/starship.toml "$backup_dir/.config/starship.toml" 2>/dev/null || true
			rm -f ~/.config/starship.toml
		fi
	fi
	
	# Backup and remove alacritty files
	if [ -e ~/.config/alacritty/alacritty.yml ]; then
		if [ ! -L ~/.config/alacritty/alacritty.yml ] || [[ ! "$(readlink ~/.config/alacritty/alacritty.yml)" =~ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" ]]; then
			print_info "Backing up and removing ~/.config/alacritty/alacritty.yml..."
			cp -L ~/.config/alacritty/alacritty.yml "$backup_dir/.config/alacritty/alacritty.yml" 2>/dev/null || true
			rm -f ~/.config/alacritty/alacritty.yml
		fi
	fi
	
	if [ -e ~/.config/alacritty/alacritty.toml ]; then
		if [ ! -L ~/.config/alacritty/alacritty.toml ] || [[ ! "$(readlink ~/.config/alacritty/alacritty.toml)" =~ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" ]]; then
			print_info "Backing up and removing ~/.config/alacritty/alacritty.toml..."
			cp -L ~/.config/alacritty/alacritty.toml "$backup_dir/.config/alacritty/alacritty.toml" 2>/dev/null || true
			rm -f ~/.config/alacritty/alacritty.toml
		fi
	fi
	
	# Handle alacritty directory if it's a symlink
	if [ -L ~/.config/alacritty ] && [ ! -d ~/.config/alacritty ]; then
		print_info "Removing alacritty directory symlink..."
		rm -f ~/.config/alacritty
	fi
	
	print_success "Conflicting files backed up to: $backup_dir"
	print_success "Conflicting files removed successfully"
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
		if ! sudo apt update; then
			print_error "Failed to update package lists"
			return 1
		fi
		if ! sudo apt install -y zsh; then
			print_error "Failed to install ZSH"
			return 1
		fi
		print_success "ZSH installed successfully"
	fi
	return 0
}

install_starship() {
	print_header "Installing Starship Prompt"
	
	if command_exists starship; then
		print_warning "Starship is already installed"
		starship --version
	else
		print_info "Installing Starship..."
		if ! command_exists curl; then
			print_info "Installing curl first..."
			sudo apt install -y curl || return 1
		fi
		if ! curl -sS https://starship.rs/install.sh | sh -s -- -y; then
			print_error "Failed to install Starship"
			return 1
		fi
		print_success "Starship installed successfully"
	fi
	return 0
}

install_alacritty() {
	print_header "Installing Alacritty Terminal"
	
	if command_exists alacritty; then
		print_warning "Alacritty is already installed"
		alacritty --version
	else
		print_info "Installing Alacritty..."
		if ! sudo apt update; then
			print_error "Failed to update package lists"
			return 1
		fi
		if ! sudo apt install -y alacritty; then
			print_error "Failed to install Alacritty"
			print_info "You may need to add the universe repository:"
			print_info "  sudo add-apt-repository universe"
			return 1
		fi
		print_success "Alacritty installed successfully"
	fi
	return 0
}

install_jetbrains_mono() {
	print_header "Installing JetBrains Mono Font"
	
	if fc-list | grep -qi "JetBrains Mono"; then
		print_warning "JetBrains Mono font is already installed"
	else
		print_info "Installing JetBrains Mono font..."
		
		# Ensure required tools are installed
		if ! command_exists wget; then
			print_info "Installing wget..."
			sudo apt install -y wget || return 1
		fi
		
		if ! command_exists unzip; then
			print_info "Installing unzip..."
			sudo apt install -y unzip || return 1
		fi
		
		# Create fonts directory
		mkdir -p ~/.local/share/fonts
		
		# Download and install JetBrains Mono
		cd /tmp || return 1
		if ! wget -q https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip; then
			print_error "Failed to download JetBrains Mono font"
			return 1
		fi
		
		if ! unzip -q JetBrainsMono-2.304.zip -d JetBrainsMono; then
			print_error "Failed to extract JetBrains Mono font"
			rm -f JetBrainsMono-2.304.zip
			return 1
		fi
		
		cp JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts/
		
		# Update font cache
		fc-cache -f -v > /dev/null 2>&1
		
		# Clean up
		rm -rf JetBrainsMono JetBrainsMono-2.304.zip
		
		print_success "JetBrains Mono font installed successfully"
	fi
	return 0
}

install_stow() {
	print_header "Installing GNU Stow"
	
	if command_exists stow; then
		print_warning "GNU Stow is already installed"
		stow --version | head -n 1
	else
		print_info "Installing GNU Stow..."
		if ! sudo apt update; then
			print_error "Failed to update package lists"
			return 1
		fi
		if ! sudo apt install -y stow; then
			print_error "Failed to install GNU Stow"
			return 1
		fi
		print_success "GNU Stow installed successfully"
	fi
	return 0
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
	print_header "Legacy Backup Check (Deprecated)"
	print_info "Using new conflict detection and removal system"
	print_info "Backups are now created automatically when removing conflicts"
}

apply_dotfiles() {
	print_header "Applying Dotfiles with GNU Stow"
	
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local ubuntu_dir="$script_dir"
	
	print_info "Dotfiles directory: $ubuntu_dir"
	
	# Change to dotfiles directory
	cd "$ubuntu_dir" || {
		print_error "Failed to change to dotfiles directory"
		return 1
	}
	
	# Apply stow with error handling
	print_info "Stowing zsh configuration..."
	if ! stow -v -t ~ zsh 2>&1; then
		print_error "Failed to stow zsh configuration"
		cd - > /dev/null
		return 1
	fi
	
	print_info "Stowing starship configuration..."
	if ! stow -v -t ~ starship 2>&1; then
		print_error "Failed to stow starship configuration"
		cd - > /dev/null
		return 1
	fi
	
	print_info "Stowing alacritty configuration..."
	if ! stow -v -t ~ alacritty 2>&1; then
		print_error "Failed to stow alacritty configuration"
		cd - > /dev/null
		return 1
	fi
	
	cd - > /dev/null
	print_success "Dotfiles applied successfully"
	return 0
}

set_zsh_default() {
	print_header "Setting ZSH as Default Shell"
	
	local zsh_path=$(which zsh)
	
	if [ -z "$zsh_path" ]; then
		print_error "ZSH executable not found in PATH"
		return 1
	fi
	
	# Check if zsh is in /etc/shells
	if ! grep -q "^$zsh_path$" /etc/shells; then
		print_info "Adding ZSH to /etc/shells..."
		echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
	fi
	
	if [ "$SHELL" = "$zsh_path" ]; then
		print_warning "ZSH is already your default shell"
	else
		print_info "Changing default shell to ZSH..."
		if ! chsh -s "$zsh_path"; then
			print_error "Failed to change default shell"
			print_info "You can manually change it later with: chsh -s $zsh_path"
			return 1
		fi
		print_success "Default shell changed to ZSH"
		print_warning "Please log out and log back in for the change to take effect"
	fi
	return 0
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
	
	if [[ $REPLY =~ ^[Nn]$ ]]; then
		print_info "Installation cancelled"
		exit 0
	fi
	
	# Check OS compatibility
	if ! check_os_compatibility; then
		print_error "OS compatibility check failed"
		exit 1
	fi
	
	# Detect conflicting files
	if detect_conflicting_files; then
		echo ""
		read -p "Do you want to backup and remove these files? (Y/n): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Nn]$ ]]; then
			remove_conflicting_files || {
				print_error "Failed to remove conflicting files"
				exit 1
			}
		else
			print_warning "Cannot proceed with conflicting files present"
			print_info "Please manually resolve conflicts and try again"
			exit 1
		fi
	fi
	
	# Installation steps with error handling
	install_zsh || {
		print_error "ZSH installation failed"
		exit 1
	}
	
	install_starship || {
		print_error "Starship installation failed"
		exit 1
	}
	
	install_alacritty || {
		print_warning "Alacritty installation failed, continuing anyway..."
	}
	
	install_jetbrains_mono || {
		print_warning "JetBrains Mono font installation failed, continuing anyway..."
	}
	
	install_stow || {
		print_error "GNU Stow installation failed"
		exit 1
	}
	
	install_optional_tools
	
	setup_directories || {
		print_error "Failed to setup directories"
		exit 1
	}
	
	apply_dotfiles || {
		print_error "Failed to apply dotfiles"
		exit 1
	}
	
	set_zsh_default || {
		print_warning "Failed to set ZSH as default shell, continuing anyway..."
	}
	
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
	echo "To uninstall, run: ./uninstall_dotfiles.sh"
	echo ""
	print_success "Enjoy your new terminal setup! 🚀"
}

# Run main function
main
