# 🚀 Guía Rápida de Instalación - Dotfiles Ubuntu

## Comandos Esenciales

### 📥 Instalación Completa (Recomendado)

```bash
# 1. Navegar al directorio ubuntu
cd ~/.dotfiles/ubuntu

# 2. Dar permisos de ejecución a los scripts
chmod +x install_dotfiles.sh remove_lazyvim.sh

# 3. Ejecutar el instalador
./install_dotfiles.sh

# 4. Cerrar sesión y volver a iniciar (para activar ZSH)
# Luego abrir Alacritty desde el menú de aplicaciones
```

---

### 🔧 Instalación Manual con Stow

Si prefieres instalar manualmente sin el script:

```bash
# Instalar dependencias
sudo apt update
sudo apt install -y zsh stow alacritty

# Instalar Starship
curl -sS https://starship.rs/install.sh | sh

# Instalar JetBrains Mono Font
mkdir -p ~/.local/share/fonts
cd /tmp
wget https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
unzip JetBrainsMono-2.304.zip -d JetBrainsMono
cp JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts/
fc-cache -f -v
rm -rf JetBrainsMono JetBrainsMono-2.304.zip

# Crear directorios necesarios
mkdir -p ~/.config/alacritty

# Aplicar dotfiles con Stow
cd ~/.dotfiles/ubuntu
stow -t ~ zsh
stow -t ~ starship
stow -t ~ alacritty

# Cambiar shell predeterminada a ZSH
chsh -s $(which zsh)

# Cerrar sesión y volver a iniciar
```

---

### 🧹 Eliminar LazyVim

```bash
cd ~/.dotfiles/ubuntu
chmod +x remove_lazyvim.sh
./remove_lazyvim.sh
```

---

### 🔄 Actualizar Dotfiles

```bash
cd ~/.dotfiles
git pull origin main

# Re-aplicar con Stow (los symlinks se actualizan automáticamente)
cd ubuntu
stow -R -t ~ zsh starship alacritty
```

---

### ❌ Desinstalar Dotfiles

```bash
cd ~/.dotfiles/ubuntu

# Eliminar symlinks de Stow
stow -D -t ~ zsh
stow -D -t ~ starship
stow -D -t ~ alacritty

# Restaurar shell original (bash)
chsh -s /bin/bash
```

---

### 📦 Herramientas Opcionales

```bash
# eza (mejor ls)
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# fzf (fuzzy finder)
sudo apt install -y fzf

# bat (mejor cat)
sudo apt install -y bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# ripgrep (mejor grep)
sudo apt install -y ripgrep

# zoxide (mejor cd)
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

---

### 🎨 Personalización Rápida

```bash
# Editar ZSH
vim ~/.zshrc

# Editar Starship
vim ~/.config/starship.toml

# Editar Alacritty
vim ~/.config/alacritty/alacritty.yml

# Recargar ZSH
source ~/.zshrc
```

---

### 🐛 Troubleshooting

#### Starship no aparece
```bash
# Agregar al PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### Fuente no se ve bien
```bash
# Verificar que JetBrains Mono esté instalada
fc-list | grep "JetBrains Mono"

# Si no está, instalarla:
cd /tmp
wget https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
unzip JetBrainsMono-2.304.zip -d JetBrainsMono
cp JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts/
fc-cache -f -v
rm -rf JetBrainsMono JetBrainsMono-2.304.zip
```

#### ZSH no es shell predeterminada
```bash
chsh -s $(which zsh)
# Cerrar sesión y volver a iniciar
```

#### Alacritty no inicia
```bash
# Verificar instalación
which alacritty

# Verificar configuración
alacritty --print-events

# Ver logs
alacritty -vvv
```

---

### 📊 Verificar Instalación

```bash
# Versiones
zsh --version
starship --version
alacritty --version
stow --version

# Verificar shell actual
echo $SHELL

# Verificar fuentes instaladas
fc-list | grep "JetBrains Mono"

# Verificar dotfiles (symlinks)
ls -la ~ | grep "\.zshrc"
ls -la ~/.config | grep "starship.toml"
ls -la ~/.config/alacritty | grep "alacritty.yml"
```

---

### 🎯 Resultado Esperado

Después de la instalación exitosa, deberías tener:

- ✅ **ZSH** como shell predeterminada con autocompletado y aliases
- ✅ **Starship** mostrando un prompt bonito con tema Catppuccin Mocha
- ✅ **Alacritty** funcionando con la misma configuración visual que Ghostty
- ✅ **JetBrains Mono** como fuente con iconos
- ✅ Archivos de configuración gestionados con **Stow** (fácil de actualizar)

---

**¡Listo para usar! 🎉**
