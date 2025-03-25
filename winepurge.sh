#!/bin/bash

# Exit on any error
set -e

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

echo "Starting to remove Wine and related packages..."

# Remove Wine and related packages, suppress errors if not installed
pacman -Rns wine winetricks wine-mono wine-gecko --noconfirm 2>/dev/null || true

# Remove dotnet and nuget packages, suppress errors if not installed
pacman -Rns dotnet-sdk dotnet-runtime nuget --noconfirm 2>/dev/null || true

# Remove orphaned dependencies, if any exist
if pacman -Qdtq &>/dev/null; then
    pacman -Rns $(pacman -Qdtq) --noconfirm 2>/dev/null || true
else
    echo "No orphaned dependencies found."
fi

# Clean up Wine-related files for all users in /home
for user_dir in /home/*; do
    if [[ -d "$user_dir" ]]; then
        user=$(basename "$user_dir")
        echo "Cleaning Wine files for user: $user..."

        # Array of paths to remove
        paths=(
            "$user_dir/.wine"
            "$user_dir/.cache/wine"
            "$user_dir/.local/share/wine"
            "$user_dir/lutris/drive_c"
            "$user_dir/.local/share/lutris/runners/wine"
            "$user_dir/.nuget"
            "$user_dir/.dotnet"
            "$user_dir/.local/share/dotnet"
            "$user_dir/.local/share/NuGet"
            "$user_dir/.cache/nuget"
            "$user_dir/.cache/dotnet"
        )

        # Remove each path if it exists
        for path in "${paths[@]}"; do
            if [[ -d "$path" || -f "$path" ]]; then
                rm -rf "$path" && echo "Removed: $path"
            fi
        done
    fi
done

# Clean up system-wide Wine directories
echo "Cleaning system-wide Wine directories..."
system_paths=(
    "/usr/share/wine"
    "/var/cache/wine"
    "/var/lib/wine"
)

for path in "${system_paths[@]}"; do
    if [[ -d "$path" || -f "$path" ]]; then
        rm -rf "$path" && echo "Removed: $path"
    fi
done

# Final cleanup: clear pacman cache for removed packages
echo "Clearing pacman package cache..."
pacman -Sc --noconfirm 2>/dev/null || true

echo "Finished removing Wine and related packages."

exit 0
