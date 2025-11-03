#!/usr/bin/env bash
# =============================================================================
# uninstall_dotfiles.sh - Uninstall Dotfiles from Ubuntu
# 
# This script removes dotfiles installed by install_dotfiles.sh and optionally
# restores previous configurations from backups.
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
# Uninstallation Functions
# =============================================================================

detect_dotfiles_symlinks() {
	print_header "Detecting Installed Dotfiles"
	
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	local found=false
	
	# Check for zsh symlinks
	if [ -L ~/.zshrc ]; then
		local link_target=$(readlink ~/.zshrc)
		if [[ "$link_target" =~ "$script_dir" ]]; then
			echo "  ✓ ~/.zshrc → $link_target"
			found=true
		fi
	fi
	
	if [ -L ~/.zshenv ]; then
		local link_target=$(readlink ~/.zshenv)
		if [[ "$link_target" =~ "$script_dir" ]]; then
			echo "  ✓ ~/.zshenv → $link_target"
			found=true
		fi
	fi
	
	if [ -L ~/.zprofile ]; then
		local link_target=$(readlink ~/.zprofile)
		if [[ "$link_target" =~ "$script_dir" ]]; then
			echo "  ✓ ~/.zprofile → $link_target"
			found=true
		fi
	fi
	
	# Check for starship symlinks
	if [ -L ~/.config/starship.toml ]; then
		local link_target=$(readlink ~/.config/starship.toml)
		if [[ "$link_target" =~ "$script_dir" ]]; then
			echo "  ✓ ~/.config/starship.toml → $link_target"
			found=true
		fi
	fi
	
	# Check for alacritty symlinks
	if [ -L ~/.config/alacritty ]; then
		local link_target=$(readlink ~/.config/alacritty)
		if [[ "$link_target" =~ "$script_dir" ]]; then
			echo "  ✓ ~/.config/alacritty → $link_target"
			found=true
		fi
	fi
	
	if [ -L ~/.config/alacritty/alacritty.yml ]; then
		local link_target=$(readlink ~/.config/alacritty/alacritty.yml)
		if [[ "$link_target" =~ "$script_dir" ]]; then
			echo "  ✓ ~/.config/alacritty/alacritty.yml → $link_target"
			found=true
		fi
	fi
	
	if [ -L ~/.config/alacritty/alacritty.toml ]; then
		local link_target=$(readlink ~/.config/alacritty/alacritty.toml)
		if [[ "$link_target" =~ "$script_dir" ]]; then
			echo "  ✓ ~/.config/alacritty/alacritty.toml → $link_target"
			found=true
		fi
	fi
	
	echo ""
	
	if [ "$found" = false ]; then
		print_info "No dotfiles symlinks found"
		return 1
	fi
	
	return 0
}

unstow_dotfiles() {
	print_header "Removing Dotfiles Symlinks"
	
	local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	
	if ! command_exists stow; then
		print_warning "GNU Stow is not installed, removing symlinks manually..."
		
		# Remove symlinks manually
		if [ -L ~/.zshrc ]; then
			print_info "Removing ~/.zshrc symlink..."
			rm -f ~/.zshrc
		fi
		
		if [ -L ~/.zshenv ]; then
			print_info "Removing ~/.zshenv symlink..."
			rm -f ~/.zshenv
		fi
		
		if [ -L ~/.zprofile ]; then
			print_info "Removing ~/.zprofile symlink..."
			rm -f ~/.zprofile
		fi
		
		if [ -L ~/.config/starship.toml ]; then
			print_info "Removing ~/.config/starship.toml symlink..."
			rm -f ~/.config/starship.toml
		fi
		
		if [ -L ~/.config/alacritty ]; then
			print_info "Removing ~/.config/alacritty symlink..."
			rm -f ~/.config/alacritty
		elif [ -d ~/.config/alacritty ]; then
			if [ -L ~/.config/alacritty/alacritty.yml ]; then
				print_info "Removing ~/.config/alacritty/alacritty.yml symlink..."
				rm -f ~/.config/alacritty/alacritty.yml
			fi
			if [ -L ~/.config/alacritty/alacritty.toml ]; then
				print_info "Removing ~/.config/alacritty/alacritty.toml symlink..."
				rm -f ~/.config/alacritty/alacritty.toml
			fi
		fi
		
		print_success "Symlinks removed manually"
	else
		# Use stow to remove symlinks
		cd "$script_dir" || {
			print_error "Failed to change to dotfiles directory"
			return 1
		}
		
		print_info "Unstowing zsh configuration..."
		stow -D -v -t ~ zsh 2>/dev/null || print_warning "Failed to unstow zsh (may not be stowed)"
		
		print_info "Unstowing starship configuration..."
		stow -D -v -t ~ starship 2>/dev/null || print_warning "Failed to unstow starship (may not be stowed)"
		
		print_info "Unstowing alacritty configuration..."
		stow -D -v -t ~ alacritty 2>/dev/null || print_warning "Failed to unstow alacritty (may not be stowed)"
		
		cd - > /dev/null
		print_success "Dotfiles unstowed successfully"
	fi
	
	return 0
}

list_backups() {
	print_header "Available Backups"
	
	local backup_dirs=()
	
	# Find all backup directories
	for dir in ~/.dotfiles_backup_*; do
		if [ -d "$dir" ]; then
			backup_dirs+=("$dir")
		fi
	done
	
	if [ ${#backup_dirs[@]} -eq 0 ]; then
		print_info "No backup directories found"
		return 1
	fi
	
	echo "Found ${#backup_dirs[@]} backup(s):"
	local i=1
	for dir in "${backup_dirs[@]}"; do
		local backup_date=$(basename "$dir" | sed 's/.dotfiles_backup_//')
		echo "  $i) $dir"
		if [ -f "$dir/.zshrc" ]; then
			echo "     - .zshrc"
		fi
		if [ -f "$dir/.config/starship.toml" ]; then
			echo "     - .config/starship.toml"
		fi
		if [ -f "$dir/.config/alacritty/alacritty.yml" ]; then
			echo "     - .config/alacritty/alacritty.yml"
		fi
		if [ -f "$dir/.config/alacritty/alacritty.toml" ]; then
			echo "     - .config/alacritty/alacritty.toml"
		fi
		((i++))
	done
	
	echo ""
	return 0
}

restore_backup() {
	print_header "Restoring Backup"
	
	local backup_dirs=()
	
	# Find all backup directories
	for dir in ~/.dotfiles_backup_*; do
		if [ -d "$dir" ]; then
			backup_dirs+=("$dir")
		fi
	done
	
	if [ ${#backup_dirs[@]} -eq 0 ]; then
		print_info "No backup directories found"
		return 1
	fi
	
	# Show backups
	list_backups
	
	# Ask which backup to restore
	read -p "Enter backup number to restore (or 0 to skip): " backup_num
	
	if [ "$backup_num" = "0" ]; then
		print_info "Skipping backup restoration"
		return 0
	fi
	
	if ! [[ "$backup_num" =~ ^[0-9]+$ ]] || [ "$backup_num" -lt 1 ] || [ "$backup_num" -gt ${#backup_dirs[@]} ]; then
		print_error "Invalid backup number"
		return 1
	fi
	
	local backup_dir="${backup_dirs[$((backup_num-1))]}"
	print_info "Restoring from: $backup_dir"
	
	# Restore files
	if [ -f "$backup_dir/.zshrc" ]; then
		print_info "Restoring ~/.zshrc..."
		cp "$backup_dir/.zshrc" ~/.zshrc
	fi
	
	if [ -f "$backup_dir/.zshenv" ]; then
		print_info "Restoring ~/.zshenv..."
		cp "$backup_dir/.zshenv" ~/.zshenv
	fi
	
	if [ -f "$backup_dir/.zprofile" ]; then
		print_info "Restoring ~/.zprofile..."
		cp "$backup_dir/.zprofile" ~/.zprofile
	fi
	
	if [ -f "$backup_dir/.config/starship.toml" ]; then
		print_info "Restoring ~/.config/starship.toml..."
		mkdir -p ~/.config
		cp "$backup_dir/.config/starship.toml" ~/.config/starship.toml
	fi
	
	if [ -f "$backup_dir/.config/alacritty/alacritty.yml" ]; then
		print_info "Restoring ~/.config/alacritty/alacritty.yml..."
		mkdir -p ~/.config/alacritty
		cp "$backup_dir/.config/alacritty/alacritty.yml" ~/.config/alacritty/alacritty.yml
	fi
	
	if [ -f "$backup_dir/.config/alacritty/alacritty.toml" ]; then
		print_info "Restoring ~/.config/alacritty/alacritty.toml..."
		mkdir -p ~/.config/alacritty
		cp "$backup_dir/.config/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
	fi
	
	print_success "Backup restored successfully"
	
	# Ask if user wants to delete the backup
	echo ""
	read -p "Do you want to delete this backup directory? (y/N): " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		rm -rf "$backup_dir"
		print_success "Backup directory deleted"
	fi
	
	return 0
}

reset_shell_to_bash() {
	print_header "Reset Default Shell"
	
	echo ""
	read -p "Do you want to reset your default shell to bash? (y/N): " -n 1 -r
	echo
	
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		local bash_path=$(which bash)
		
		if [ -z "$bash_path" ]; then
			print_error "Bash executable not found"
			return 1
		fi
		
		if [ "$SHELL" = "$bash_path" ]; then
			print_info "Bash is already your default shell"
		else
			print_info "Changing default shell to bash..."
			if ! chsh -s "$bash_path"; then
				print_error "Failed to change default shell"
				print_info "You can manually change it later with: chsh -s $bash_path"
				return 1
			fi
			print_success "Default shell changed to bash"
			print_warning "Please log out and log back in for the change to take effect"
		fi
	else
		print_info "Keeping current default shell"
	fi
	
	return 0
}

remove_packages() {
	print_header "Remove Installed Packages"
	
	echo "This will NOT uninstall the following packages:"
	echo "  • ZSH"
	echo "  • Starship"
	echo "  • Alacritty"
	echo "  • JetBrains Mono Font"
	echo "  • GNU Stow"
	echo "  • Optional tools (eza, fzf, bat, zoxide, ripgrep)"
	echo ""
	print_info "These packages may be useful for other purposes"
	print_info "If you want to remove them, you can do so manually:"
	echo ""
	echo "  sudo apt remove zsh alacritty stow fzf bat ripgrep"
	echo "  sudo apt remove eza  # if installed via apt"
	echo "  rm -rf ~/.local/bin/zoxide  # if installed via curl"
	echo "  rm -f ~/.local/bin/starship  # if installed via curl"
	echo "  rm -rf ~/.local/share/fonts/JetBrainsMono*"
	echo "  fc-cache -f -v"
	echo ""
}

# =============================================================================
# Main Uninstallation Process
# =============================================================================

main() {
	print_header "Ubuntu Dotfiles Uninstallation"
	echo "This script will:"
	echo "  • Remove all dotfiles symlinks"
	echo "  • Optionally restore previous configurations from backup"
	echo "  • Optionally reset your default shell to bash"
	echo ""
	echo "This will NOT uninstall packages like ZSH, Starship, or Alacritty"
	echo ""
	
	# Detect installed dotfiles
	if ! detect_dotfiles_symlinks; then
		print_warning "No dotfiles found to uninstall"
		echo ""
		read -p "Do you want to see available backups anyway? (y/N): " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			if list_backups; then
				restore_backup
			fi
		fi
		exit 0
	fi
	
	read -p "Do you want to continue with uninstallation? (y/N): " -n 1 -r
	echo
	
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		print_info "Uninstallation cancelled"
		exit 0
	fi
	
	# Uninstall dotfiles
	unstow_dotfiles || {
		print_error "Failed to remove dotfiles symlinks"
		exit 1
	}
	
	# Check for backups and offer restoration
	if list_backups 2>/dev/null; then
		echo ""
		read -p "Do you want to restore a previous configuration? (y/N): " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			restore_backup
		fi
	fi
	
	# Offer to reset shell
	reset_shell_to_bash
	
	# Information about packages
	remove_packages
	
	# Final message
	print_header "Uninstallation Complete!"
	echo -e "${GREEN}Your dotfiles have been removed successfully!${NC}\n"
	echo "What was removed:"
	echo "  ✓ All dotfiles symlinks"
	echo ""
	echo "What was NOT removed:"
	echo "  • ZSH, Starship, Alacritty, and other installed packages"
	echo "  • Backup directories (unless you chose to delete them)"
	echo ""
	print_success "Dotfiles uninstalled! 👋"
}

# Run main function
main
