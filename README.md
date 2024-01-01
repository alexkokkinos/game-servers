# Game Servers in Hetzner Cloud

## What is this doing?

```shell
├─ modules/
  ├─ hetzner-game-server/
     game.tf #Creates a generic server with a storage volume and a firewall supplied by an input variable
     ...other files
production-[server].tf #So far, it creates an instance of the hetzner-game-server module to create a blank server intended for Minecraft. Also creates firewalls for this purpose.
```

## Crap to remove from ~/mods

```shell
rm notenoughanimations-forge*
rm preview_OptiFine_*
rm DistantHorizons*
```

## Install Valheim

### SCP: files to copy
```shell
# THIS REPOSITORY DIRECTORY
scp valheim.service root@:~/
scp install-update-valheim.sh root@:~/
```

https://developer.valvesoftware.com/wiki/SteamCMD#Linux

### steamcmd/Valheim Install
```shell
# ROOT USER
useradd -m steam
passwd steam
sudo -u steam -s
chsh -s /bin/bash steam
# Edit sources.list and add Hetnzer mirrors https://docs.hetzner.com/robot/dedicated-server/operating-systems/hetzner-aptitude-mirror/
apt update
apt install software-properties-common
dpkg --add-architecture i386
apt update
apt install lib32gcc-s1 steamcmd
mv ~/install-update-valheim.sh /home/steam/install-update-valheim.sh
chown steam:steam /home/steam/install-update-valheim.sh
chmod 0755 /home/steam/install-update-valheim.sh

# STEAM USER
sudo su - steam
./install-update-valheim.sh
```

### Backblaze setup:
```shell
# STEAM USER
wget https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux
chmod +x b2-linux
./b2-linux authorize-account # Key is in 1Password, or make a new one
```

### Restore Save Game Backups:
```shell
/home/steam/b2-linux sync b2://tram-game-server-backups/valheim/saved /home/steam/valheim-server/saved
```

### Valheim Service:
```shell
# ROOT USER
mv ~/valheim.service /etc/systemd/system/valheim.service
chmod 0644 /etc/systemd/system/valheim.service
```

### Start Services
```shell
# ROOT USER
systemctl enable valheim.service
systemctl start valheim.service
```

### Set up regular backups
```shell
# STEAM USER
crontab -e
```

In the crontab editor:
```
0 15 * * 1 /home/steam/b2-linux sync --allowEmptySource /home/steam/valheim-server/saved b2://tram-game-server-backups/valheim/saved
```

## Install Minecraft

```shell
useradd -m minecraft
groupadd minecraft
mv forge-1.20.1-47.1.28-installer.jar /home/minecraft/
chown minecraft:minecraft /home/minecraft/forge-1.20.1-47.1.28-installer.jar
apt install unzip make gcc libc6-dev git -y
apt install openjdk-17-jre-headless
apt update
nano /usr/local/bin/minecraft/start ## Put in the start script (customized-minecraft-files)
nano /usr/local/bin/minecraft/start ## Put in the stop script (customized-minecraft-files)
chmod +x /usr/local/bin/minecraft/stop
chmod +x /usr/local/bin/minecraft/start
nano /etc/systemd/system/minecraft.service # minecraft.service
nano /home/minecraft/whitelist.json # whitelist.json
```

### mcrcon in /home/minecraft 
```shell
git clone https://github.com/Tiiffi/mcrcon.git
cd mcrcon
make
sudo make install
```

### Update Minecraft files
