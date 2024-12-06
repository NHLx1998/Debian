#!/bin/bash

set -e

echo "Debian 11 auf Debian 12 Upgrade-Skript"
echo "--------------------------------------"
echo "Bitte sicherstellen, dass ein Backup vorhanden ist und keine kritischen Dienste laufen."
read -p "Möchtest du fortfahren? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Abgebrochen."
    exit 1
fi

# 1. Systemaktualisierung und Bereinigung
echo "Aktualisiere aktuelles System..."
sudo apt update && sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove --purge -y

# 2. Prüfen, ob alle Pakete aktuell sind
echo "Prüfe, ob alle Pakete aktuell sind..."
sudo apt update && sudo apt full-upgrade -y

# 3. Ändere die APT-Quellenliste auf Debian 12 (Bookworm)
echo "Aktualisiere APT-Quellen auf Debian 12..."
sudo sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list

# 4. APT-Quellen aktualisieren
echo "APT-Quellenliste aktualisieren..."
sudo apt update

# 5. Upgrade auf Debian 12 durchführen
echo "Upgrade auf Debian 12 durchführen..."
sudo apt upgrade -y
sudo apt full-upgrade -y

# 6. Bereinigung nach dem Upgrade
echo "Bereinige veraltete Pakete..."
sudo apt autoremove --purge -y

# 7. Neustart des Systems
echo "Upgrade abgeschlossen. Ein Neustart wird empfohlen."
read -p "Jetzt neu starten? (y/n): " reboot_confirm
if [[ "$reboot_confirm" == "y" ]]; then
    sudo reboot
else
    echo "Bitte starte das System manuell neu, um die Änderungen abzuschließen."
fi
