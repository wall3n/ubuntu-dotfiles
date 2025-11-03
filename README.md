# 🐧 Ubuntu Dotfiles

Dotfiles adaptados para Ubuntu desde macOS. Incluye configuraciones para **ZSH**, **Starship** y **Alacritty**.

## 📂 Estructura

```
├── zsh/
│   └── .zshrc                    # Configuración de ZSH
├── starship/
│   └── .config/starship.toml     # Configuración de Starship Prompt
├── alacritty/
│   └── .config/alacritty/
│       └── alacritty.yml         # Configuración de Alacritty (convertida desde Ghostty)
```

## 🚀 Instalación Rápida

### 1. Clonar el repositorio (si aún no lo has hecho)

```bash
git clone https://github.com/wall3n/ubuntu-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Ejecutar el script de instalación

```bash
stow .
```

El script instalará automáticamente:
- ✅ **ZSH** - Shell interactivo
- ✅ **Starship** - Prompt personalizable
- ✅ **Alacritty** - Terminal emulator GPU-acelerado
- ✅ **JetBrains Mono** - Fuente monoespaciada
- ✅ **GNU Stow** - Gestor de symlinks
- ⚙️ **Herramientas opcionales**: eza, fzf, bat, zoxide, ripgrep

### 3. Cerrar sesión y volver a iniciar

Para que ZSH se active como shell predeterminada, cierra sesión y vuelve a iniciar.

### 4. Lanzar Alacritty

Abre Alacritty desde el menú de aplicaciones o ejecuta `alacritty` en la terminal.

## 🎨 Características

### ZSH (`.zshrc`)
- ✨ Autocompletado inteligente
- 📜 Historial compartido entre sesiones
- 🔧 Aliases útiles para Git, navegación, etc.
- 🎯 Funciones personalizadas (mkcd, extract, etc.)
- 🔌 Integración con fzf, zoxide, etc.

### Starship (`starship.toml`)
- 🌈 Tema **Catppuccin Mocha**
- 📊 Información de Git en tiempo real
- 💻 Indicadores de lenguajes (Node.js, Python, Rust, etc.)
- ⚡ Renderizado ultra-rápido

### Alacritty (`alacritty.yml`)
- 🎨 Tema **Catppuccin Mocha** (convertido desde Ghostty)
- 🔤 Fuente **JetBrains Mono** a 17pt
- 🪟 Opacidad del 95%
- ⌨️ Atajos de teclado personalizados
- 🚀 Aceleración GPU para máximo rendimiento

## 🔧 Personalización

### Editar configuración de ZSH
```bash
vim ~/.zshrc
```

### Editar configuración de Starship
```bash
vim ~/.config/starship.toml
```

### Editar configuración de Alacritty
```bash
vim ~/.config/alacritty/alacritty.yml
```

Después de editar, recarga la configuración:
```bash
source ~/.zshrc  # Para ZSH
```

Alacritty recarga automáticamente su configuración al guardar el archivo.

## 🧹 Eliminar LazyVim

Si tienes LazyVim instalado y quieres eliminarlo completamente:

```bash
chmod +x remove_lazyvim.sh
./remove_lazyvim.sh
```

El script:
1. Detecta todas las configuraciones de Neovim/LazyVim
2. Ofrece crear un backup antes de eliminar
3. Elimina completamente todas las configuraciones
4. Opcionalmente desinstala Neovim del sistema

## 📦 Gestión con GNU Stow

GNU Stow crea symlinks desde `~/.dotfiles/ubuntu/` hacia tu directorio home.

### Aplicar configuraciones manualmente

```bash
cd ~/.dotfiles/ubuntu

# Aplicar solo ZSH
stow -t ~ zsh

# Aplicar solo Starship
stow -t ~ starship

# Aplicar solo Alacritty
stow -t ~ alacritty

# Aplicar todas las configuraciones
stow -t ~ zsh starship alacritty
```

### Deshacer configuraciones

```bash
cd ~/.dotfiles/ubuntu

# Deshacer ZSH
stow -D -t ~ zsh

# Deshacer Starship
stow -D -t ~ starship

# Deshacer Alacritty
stow -D -t ~ alacritty
```

## 🛠️ Aliases Útiles

Después de instalar, tendrás acceso a estos aliases:

### Navegación
- `..` - Subir un directorio
- `...` - Subir dos directorios
- `dotfiles` - Ir al directorio de dotfiles

### Git
- `gadd` - git add
- `gc` - git commit -m
- `gca` - git add --all && git commit --amend --no-edit
- `gco` - git checkout
- `gst` - git status
- `gps` - git push
- `gpl` - git pull
- `gb` - git branch
- `gl` - git log

### Sistema (Ubuntu)
- `update` - sudo apt update && sudo apt upgrade -y
- `install` - sudo apt install
- `remove` - sudo apt remove

### Listado de archivos (con eza)
- `ls` - Listado con iconos y colores
- `l` - Listado detallado con archivos ocultos
- `lt` - Árbol de directorios (nivel 2)
- `ltree` - Árbol simple de directorios

## 🐛 Solución de Problemas

### ZSH no es el shell predeterminado
```bash
chsh -s $(which zsh)
```
Luego cierra sesión y vuelve a iniciar.

### Starship no aparece
Verifica que esté en tu PATH:
```bash
which starship
```

Si no está, agrega al `.zshrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### La fuente no se muestra correctamente en Alacritty
Verifica que JetBrains Mono esté instalada:
```bash
fc-list | grep "JetBrains Mono"
```

Si no está, instálala con el script de instalación o manualmente.

### Los iconos no se muestran (cuadrados o símbolos raros)
Necesitas una **Nerd Font**. El script instala JetBrains Mono que incluye íconos.

## 🔄 Actualizar Dotfiles

```bash
cd ~/.dotfiles
git pull origin main
cd ubuntu
./install_dotfiles.sh
```

## 📝 Notas

- **Adaptado desde macOS**: Las rutas de Homebrew (`/opt/homebrew`) han sido reemplazadas por rutas estándar de Ubuntu (`/usr/bin`, `/usr/local/bin`)
- **Ghostty → Alacritty**: La configuración de Ghostty se ha convertido a formato YAML de Alacritty manteniendo colores, fuente y tema
- **Catppuccin Mocha**: Tema de colores consistente en ZSH, Starship y Alacritty
- **GNU Stow**: Gestiona los dotfiles mediante symlinks, facilitando la actualización y sincronización

## 📚 Referencias

- [Starship Prompt](https://starship.rs/)
- [Alacritty Terminal](https://alacritty.org/)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [JetBrains Mono Font](https://www.jetbrains.com/lp/mono/)

## 🤝 Contribuir

Si encuentras problemas o mejoras, siéntete libre de abrir un issue o pull request.

## 📄 Licencia

Este repositorio está bajo tu licencia personal. Úsalo libremente.

---

**¡Disfruta de tu nuevo entorno de terminal en Ubuntu! 🎉**
