#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi


echo "Starting to ripping Wine and related packages..."

pacman -Rns wine winetricks wine-mono wine-gecko --noconfirm

pacman -Rns dotnet-sdk dotnet-runtime nuget --noconfirm 2>/dev/null

pacman -Rns $(pacman -Qdtq) --noconfirm 2>/dev/null

for user in /home/*; do
    if [ -d "$user" ]; then
        rm -rf "$user/.wine"
        rm -rf "$user/.cache/wine"
        rm -rf "$user/.local/share/wine"
        rm -rf "$user/lutris/drive_c/"
        rm -rf "$user/.local/share/lutris/runners/wine/"
        rm -rf "$user/.nuget/"
        rm -rf "$user/.dotnet/"
        rm -rf "$user/.local/share/dotnet/"
        rm -rf "$user/.local/share/nuget/"
        rm -rf "$user/.cache/nuget/"
        rm -rf "$user/.cache/dotnet/"
        rm -rf "$user/.cache/nuget/"
        
        echo "Cleaned Wine files for user: $(basename "$user")"
    fi
done

rm -rf /usr/share/wine
rm -rf /var/cache/wine
rm -rf /var/lib/wine

echo "Finished ripping Wine and related packages."

exit 0
