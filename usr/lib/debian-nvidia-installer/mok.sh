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

# Public MOK key path (Ubuntu uses shim-signed's key)
mok::pub_key() {
    if utils::os::is_ubuntu; then
        echo "/var/lib/shim-signed/mok/MOK.der"
    else
        echo "/var/lib/dkms/mok.pub"
    fi
}

# Verifica se o mokutil está instalado no sistema
mok::check_mokutil() {
    if command -v mokutil &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Verifica se o Secure Boot está habilitado
mok::check_secure_boot() {
    if mokutil --sb-state | grep -q "enabled"; then
        return 0
    else
        return 1
    fi
}

# Verifica se o MOK está inscrito
mok::check_mok() {
    local key="${1:-$(mok::pub_key)}"
    if [[ -f "$key" ]] && mokutil --test-key "$key" | grep -iq "already enrolled"; then
        return 0
    else
        return 1
    fi
}

# Gera a chave MOK
mok::generate_mok() {
    if utils::os::is_ubuntu; then
        update-secureboot-policy --new-key
    else
        dkms generate_mok
    fi
}

# Importa a chave MOK, precisa da interação do usuário para definir a senha
mok::import_mok() {
    local key="${1:-$(mok::pub_key)}"
    if utils::os::is_ubuntu; then
        update-secureboot-policy --enroll-key
    else
        mokutil --import "$key"
    fi
}
