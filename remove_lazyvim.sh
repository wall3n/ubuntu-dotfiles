#!/usr/bin/env bash
# =============================================================================
# remove_lazyvim.sh - Complete LazyVim Removal Script for Ubuntu
# 
# This script completely removes LazyVim and all related Neovim configurations
# from your Ubuntu system.
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

# =============================================================================
# Removal Functions
# =============================================================================

check_directories() {
	print_header "Checking LazyVim/Neovim Directories"
	
	local dirs_to_remove=(
		"$HOME/.config/nvim"
		"$HOME/.local/share/nvim"
		"$HOME/.local/state/nvim"
		"$HOME/.cache/nvim"
	)
	
	local found_dirs=()
	
	for dir in "${dirs_to_remove[@]}"; do
		if [ -d "$dir" ]; then
			found_dirs+=("$dir")
			local size=$(du -sh "$dir" 2>/dev/null | cut -f1)
			echo -e "  ${YELLOW}•${NC} $dir (${size})"
		fi
	done
	
	if [ ${#found_dirs[@]} -eq 0 ]; then
		print_info "No LazyVim/Neovim directories found"
		return 1
	fi
	
	return 0
}

create_backup() {
	print_header "Creating Backup"
	
	local backup_dir="$HOME/.nvim_backup_$(date +%Y%m%d_%H%M%S)"
	
	read -p "Do you want to create a backup before removing? (Y/n): " -n 1 -r
	echo
	
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
		print_info "Creating backup at: $backup_dir"
		mkdir -p "$backup_dir"
		
		[ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" "$backup_dir/nvim_config"
		[ -d "$HOME/.local/share/nvim" ] && cp -r "$HOME/.local/share/nvim" "$backup_dir/nvim_data"
		[ -d "$HOME/.local/state/nvim" ] && cp -r "$HOME/.local/state/nvim" "$backup_dir/nvim_state"
		[ -d "$HOME/.cache/nvim" ] && cp -r "$HOME/.cache/nvim" "$backup_dir/nvim_cache"
		
		print_success "Backup created successfully at: $backup_dir"
		return 0
	else
		print_warning "Skipping backup"
		return 1
	fi
}

remove_lazyvim() {
	print_header "Removing LazyVim/Neovim Configurations"
	
	local dirs_to_remove=(
		"$HOME/.config/nvim"
		"$HOME/.local/share/nvim"
		"$HOME/.local/state/nvim"
		"$HOME/.cache/nvim"
	)
	
	print_warning "This will permanently delete the following directories:"
	for dir in "${dirs_to_remove[@]}"; do
		if [ -d "$dir" ]; then
			echo -e "  ${RED}•${NC} $dir"
		fi
	done
	echo ""
	
	read -p "Are you absolutely sure you want to proceed? (yes/NO): " -r
	echo
	
	if [[ $REPLY == "yes" ]]; then
		for dir in "${dirs_to_remove[@]}"; do
			if [ -d "$dir" ]; then
				print_info "Removing $dir..."
				rm -rf "$dir"
				print_success "Removed $dir"
			fi
		done
		
		print_success "LazyVim/Neovim configurations removed successfully"
		return 0
	else
		print_error "Removal cancelled by user"
		return 1
	fi
}

remove_neovim_package() {
	print_header "Neovim Package Removal"
	
	if command -v nvim &> /dev/null; then
		echo -e "${YELLOW}Neovim is still installed on your system${NC}\n"
		read -p "Do you want to remove Neovim package as well? (y/N): " -n 1 -r
		echo
		
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			print_info "Removing Neovim package..."
			
			# Check if installed via apt
			if dpkg -l | grep -q neovim; then
				sudo apt remove -y neovim
				sudo apt autoremove -y
				print_success "Neovim removed via apt"
			# Check if installed via snap
			elif snap list 2>/dev/null | grep -q nvim; then
				sudo snap remove nvim
				print_success "Neovim removed via snap"
			else
				print_warning "Neovim binary found but not installed via apt or snap"
				print_info "You may need to remove it manually"
			fi
		else
			print_info "Keeping Neovim package installed"
		fi
	else
		print_info "Neovim is not installed"
	fi
}

verify_removal() {
	print_header "Verifying Removal"
	
	local dirs_to_check=(
		"$HOME/.config/nvim"
		"$HOME/.local/share/nvim"
		"$HOME/.local/state/nvim"
		"$HOME/.cache/nvim"
	)
	
	local remaining_dirs=()
	
	for dir in "${dirs_to_check[@]}"; do
		if [ -d "$dir" ]; then
			remaining_dirs+=("$dir")
		fi
	done
	
	if [ ${#remaining_dirs[@]} -eq 0 ]; then
		print_success "All LazyVim/Neovim directories have been removed"
		return 0
	else
		print_warning "Some directories still exist:"
		for dir in "${remaining_dirs[@]}"; do
			echo -e "  ${YELLOW}•${NC} $dir"
		done
		return 1
	fi
}

# =============================================================================
# Main Removal Process
# =============================================================================

main() {
	print_header "LazyVim Complete Removal Tool"
	echo "This script will remove ALL LazyVim and Neovim configurations."
	echo ""
	echo -e "${RED}WARNING: This action cannot be undone easily!${NC}"
	echo ""
	
	# Check if there's anything to remove
	if ! check_directories; then
		print_success "Nothing to remove. LazyVim is not installed."
		exit 0
	fi
	
	echo ""
	read -p "Do you want to continue with the removal process? (y/N): " -n 1 -r
	echo
	
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# Create backup
		create_backup
		
		echo ""
		
		# Remove LazyVim configurations
		if remove_lazyvim; then
			# Verify removal
			verify_removal
			
			# Ask about removing Neovim package
			echo ""
			remove_neovim_package
			
			# Final message
			print_header "Removal Complete!"
			echo -e "${GREEN}LazyVim has been completely removed from your system.${NC}\n"
			
			if command -v nvim &> /dev/null; then
				echo "Neovim is still installed. When you next run 'nvim', it will start fresh."
			else
				echo "Neovim has been uninstalled from your system."
			fi
			
			echo ""
			print_success "Your system is now clean! 🧹"
		else
			print_error "Removal process was cancelled"
			exit 1
		fi
	else
		print_info "Removal cancelled by user"
		exit 0
	fi
}

# Run main function
main
