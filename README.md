# dotfiles

This repository contains my personal dotfiles and configuration files used on Linux (WSL Arch).

## Structure

```
.inputrc          # Readline UTF-8 support
.zshrc            # Zsh configuration (Korean UTF-8, prompt, completion)
wsl/
  setup.sh        # WSL Arch Linux initial setup script
```

## Neovim

My Neovim configuration is maintained in a separate repository:

👉 https://github.com/spidychoipro/neovim-config

## WSL Setup

```bash
# Clone and run setup
git clone https://github.com/spidychoipro/dotfiles.git
cd dotfiles
bash wsl/setup.sh
```

## Notes

- These configurations are tailored to my personal workflow.
- Korean UTF-8 support is pre-configured.
- Use at your own discretion.
