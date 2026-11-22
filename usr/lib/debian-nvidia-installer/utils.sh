#!/usr/bin/env bash

# debian-nvidia-installer - NVIDIA Driver Installer for Debian (TUI)
# Copyright (C) 2025 Leonardo Amaral
#
# This file is part of debian-nvidia-installer.
#
# debian-nvidia-installer is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# debian-nvidia-installer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with debian-nvidia-installer. If not, see <https://www.gnu.org/licenses/gpl-3.0.html>.

# Escapa caracteres que podem quebrar regex
utils::escape_chars() {
    local string="$1"
    printf '%s\n' "$string" | sed 's/[][\/.^$*?()+]/\\&/g'
}

# Verifica se o script está sendo executado com privilégios sudo
utils::check_sudo() {
    [[ "$EUID" -eq 0 ]]
}

# Reexecuta o script como sudo
utils::force_sudo() {
    local self
    self="$(readlink -f "$0")"
    shift
    exec sudo --preserve-env "$self" "$@"
}

# Verifica se uma arquitetura multiarch está habilitada
utils::multiarch::check() {
    local arch="$1"

    if [[ -z "$arch" ]]; then
        return 255
    fi

    if ! dpkg --print-foreign-architectures | grep -q "^$arch\$"; then
        return 1
    fi

    return 0
}

# Habilita uma arquitetura multiarch
utils::multiarch::enable() {
    local arch="$1"

    if [[ -z "$arch" ]]; then
        return 255
    fi

    if utils::multiarch::check "$arch"; then
        return 0
    fi

    if ! dpkg --add-architecture "$arch"; then
        return 1
    fi

    return 0
}

# Detected OS info (filled by utils::os::detect)
declare -g OS_ID="" OS_VERSION_ID="" OS_CODENAME=""

# Read /etc/os-release without polluting globals
utils::os::detect() {
    local f="${OS_RELEASE_FILE:-/etc/os-release}"
    [[ -r "$f" ]] || return 1
    OS_ID="$(. "$f" && echo "${ID:-}")"
    OS_VERSION_ID="$(. "$f" && echo "${VERSION_ID:-}")"
    OS_CODENAME="$(. "$f" && echo "${VERSION_CODENAME:-}")"
}

# Succeeds on Debian 12/13 or Ubuntu 22.04/24.04 (amd64)
utils::os::is_supported() {
    utils::os::detect || return 1
    case "$OS_ID:$OS_VERSION_ID" in
        debian:12|debian:13|ubuntu:22.04|ubuntu:24.04) ;;
        *) return 1 ;;
    esac
    [[ "$(dpkg --print-architecture 2>/dev/null)" == "amd64" ]]
}

utils::os::is_debian() { [[ "$OS_ID" == "debian" ]]; }
utils::os::is_ubuntu() { [[ "$OS_ID" == "ubuntu" ]]; }

# True on Debian 12 (v550 is not in its main repos)
utils::os::is_debian12() { utils::os::is_debian && [[ "$OS_VERSION_ID" == "12" ]]; }

# CUDA repo path name (debian12, debian13, ubuntu2204, ubuntu2404)
utils::os::cuda_repo_distro() {
    echo "${OS_ID}${OS_VERSION_ID//./}"
}

# Kernel headers package for this distro
utils::os::kernel_headers_pkg() {
    if utils::os::is_ubuntu; then
        local pkg="linux-headers-$(uname -r)"
        if apt-cache show "$pkg" &>/dev/null; then echo "$pkg"; else echo "linux-headers-generic"; fi
    else
        echo "linux-headers-amd64"
    fi
}
