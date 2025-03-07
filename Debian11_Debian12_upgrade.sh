#!/bin/bash

# Fehler-Handling aktivieren: Stoppt das Skript, falls ein Fehler auftritt
set -e

# Farben für besseres Terminal-Feedback
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Debian 11 auf Debian 12 Upgrade-Skript${NC}"
echo "--------------------------------------"
echo "📌 Bitte sicherstellen, dass ein Backup vorhanden ist und keine kritischen Dienste laufen."
read -p "Möchtest du fortfahren? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo -e "${RED}❌ Abgebrochen.${NC}"
    exit 1
fi

# 🛑 Prüfen, ob das System auf Debian 11 läuft
if [[ $(lsb_release -cs) != "bullseye" ]]; then
    echo -e "${RED}❌ Fehler: Dieses Skript kann nur auf Debian 11 ausgeführt werden!${NC}"
    exit 1
fi

# 📌 1. Backup wichtiger Dateien erstellen
echo -e "${GREEN}📂 Erstelle ein Backup der wichtigsten Konfigurationsdateien...${NC}"
tar -czf /root/backup_debian11.tar.gz /etc /var/lib/dpkg /var/lib/apt /var/cache/apt /home 2>/dev/null
echo -e "${GREEN}✅ Backup gespeichert unter: /root/backup_debian11.tar.gz${NC}"

# 📌 2. System aktualisieren & bereinigen
echo -e "${GREEN}🔄 Aktualisiere aktuelles System...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove --purge -y

# 📌 3. APT-Quellen auf Debian 12 "Bookworm" umstellen
echo -e "${GREEN}✏️  Ändere APT-Quellen auf Debian 12...${NC}"
sudo sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sudo sed -i '/non-free/ s/$/ non-free-firmware/' /etc/apt/sources.list

# 📌 4. Drittanbieter-Repos von Bullseye auf Bookworm aktualisieren
echo -e "${GREEN}🔍 Aktualisiere Drittanbieter-Repos...${NC}"
sudo find /etc/apt/sources.list.d -type f -exec sed -i 's/bullseye/bookworm/g' {} \;

# 📌 5. System-Upgrade starten
echo -e "${GREEN}⬆️  Starte das Upgrade auf Debian 12...${NC}"
sudo apt update && sudo apt full-upgrade -y

# 📌 6. Bereinigung nach dem Upgrade
echo -e "${GREEN}🧹 Entferne alte Pakete...${NC}"
sudo apt autoremove --purge -y
sudo apt clean

# 📌 7. Upgrade erfolgreich – Neustart vorbereiten
echo -e "${GREEN}✅ Upgrade abgeschlossen. Ein Neustart wird empfohlen.${NC}"
read -p "Jetzt neu starten? (y/n): " reboot_confirm
if [[ "$reboot_confirm" == "y" ]]; then
    echo -e "${GREEN}🔄 Neustart in 10 Sekunden...${NC}"
    sleep 10
    sudo reboot
else
    echo -e "${RED}⚠️ Bitte starte das System manuell neu, um die Änderungen abzuschließen.${NC}"
fi
