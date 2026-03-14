# local-dev-env Setup

This repository contains a modular Ansible system designed to bootstrap and configure a professional-grade development environment on macOS (and maybe Linux).

## What it does

* **System Tools**: Installs core utilities (`curl`, `git`, `fzf`) and macOS apps (`Raycast`, `Docker Desktop`, `Ghostty`).
* **Terminal**: Configures Oh My Zsh with recommended plugins (`git`, `fzf`, `zsh-syntax-highlighting`, `zsh-autosuggestions`) and applies a standard `.zshrc`.
* **Languages**: Uses `mise` (next-generation version manager, rust-based successor to `asdf`) to automatically install and set global versions for **Java 25 (LTS)** and **Maven**.

## Configuration

By default, the terminal profile configures `zsh` with Oh My Zsh.

## Prerequisites

You just need a clean installation of macOS or Linux.
The bootstrap script will take care of installing packages like Homebrew, APT updates, and Ansible automatically.

## Quick Start (Bootstrap)

To execute the setup for the first time, from the root of this folder, simply run the setup script.
It will ask for your system password to elevate privileges for installing applications.

```bash
./setup.sh
```

## Running Ansible Manually

If you already have skipped the bootstrap or just want to re-run the playbook to apply recent configuration changes:

```bash
ansible-playbook main.yml -i inventory --ask-become-pass
```

## Repository Structure

* `main.yml`: The entry point playbook configuring the OS.
* `ansible.cfg`: Core Ansible configurations.
* `inventory`: Points to `localhost`.
* `roles/`:
  * `system/`: Installs OS-level packages (Homebrew casks on Mac, APT dependencies).
  * `terminal/`: Installs Oh My Zsh, clones ZSH plugins, and handles terminal config.
  * `languages/`: Sets up the `mise` version manager to install Java/Maven.
* `dotfiles/`: Contains the Jinja2 template for generating the `~/.zshrc`.
