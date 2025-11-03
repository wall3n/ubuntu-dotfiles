#!/usr/bin/env bash
# =============================================================================
# install_dotfiles.sh - Minimal Dotfiles Installation for Ubuntu
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
	echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
	echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
	echo -e "${YELLOW}⚠ $1${NC}"
}

command_exists() {
	command -v "$1" &> /dev/null
}

backup_and_remove_conflicts() {
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
	local has_conflicts=false
	
	# Check and backup conflicting files
	for file in ~/.zshrc ~/.zshenv ~/.zprofile ~/.config/starship.toml ~/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.toml; do
		if [ -e "$file" ]; then
			if [ ! -L "$file" ] || [[ ! "$(readlink "$file" 2>/dev/null)" =~ "$script_dir" ]]; then
				if [ "$has_conflicts" = false ]; then
					mkdir -p "$backup_dir/.config/alacritty"
					has_conflicts=true
				fi
				cp -L "$file" "$backup_dir/$file" 2>/dev/null || true
				rm -f "$file"
			fi
		fi
	done
	
	# Remove broken alacritty symlink
	if [ -L ~/.config/alacritty ] && [ ! -d ~/.config/alacritty ]; then
		rm -f ~/.config/alacritty
	fi
	
	[ "$has_conflicts" = true ] && print_success "Backed up conflicts to: $backup_dir"
}

# Install packages
install_packages() {
	print_info "Installing packages..."
	sudo apt update -qq
	sudo apt install -y zsh stow curl wget unzip 2>/dev/null
	
	# Install Starship
	if ! command_exists starship; then
		curl -sS https://starship.rs/install.sh | sh -s -- -y
	fi
	
	# Install Alacritty (optional, may not be in all repos)
	sudo apt install -y alacritty 2>/dev/null || print_warning "Alacritty not available"
	
	# Install JetBrains Mono font
	if ! fc-list | grep -qi "JetBrains Mono"; then
		mkdir -p ~/.local/share/fonts
		cd /tmp
		wget -q https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
		unzip -q JetBrainsMono-2.304.zip -d JetBrainsMono
		cp JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts/
		fc-cache -fv > /dev/null 2>&1
		rm -rf JetBrainsMono JetBrainsMono-2.304.zip
		cd - > /dev/null
	fi
	
	print_success "Packages installed"
}

# Apply dotfiles with stow
apply_dotfiles() {
	print_info "Applying dotfiles..."
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	
	mkdir -p ~/.config/alacritty
	
	cd "$script_dir"
	stow -t ~ zsh
	stow -t ~ starship
	stow -t ~ alacritty
	cd - > /dev/null
	
	print_success "Dotfiles applied"
}

# Set ZSH as default shell
set_default_shell() {
	local zsh_path=$(which zsh)
	
	if [ "$SHELL" != "$zsh_path" ]; then
		print_info "Setting ZSH as default shell..."
		grep -q "^$zsh_path$" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
		chsh -s "$zsh_path"
		print_warning "Log out and back in to use ZSH"
	fi
}

# Main
main() {
	echo -e "\n${BLUE}Ubuntu Dotfiles Installation${NC}\n"
	
	backup_and_remove_conflicts
	install_packages
	apply_dotfiles
	set_default_shell
	
	echo -e "\n${GREEN}✓ Installation complete!${NC}"
	echo -e "Run: ${BLUE}./uninstall_dotfiles.sh${NC} to uninstall\n"
}

main
