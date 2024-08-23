# Game Servers in Hetzner Cloud

## What is this doing?

```shell
├─ modules/
  ├─ hetzner-game-server/
     game.tf #Creates a generic server with a storage volume and a firewall supplied by an input variable
     ...other files
production-[server].tf #So far, it creates an instance of the hetzner-game-server module to create a blank server intended for Minecraft. Also creates firewalls for this purpose.
```

## Crap to remove from ~/mods (mincraft)

```shell
rm notenoughanimations-forge*
rm preview_OptiFine_*
rm DistantHorizons*
rm oculus*
```

## Plain Debian steps

```shell
sudo su -
yum install -y sudo
usermod -aG sudo [adminuser]
apt install -y 
chsh -s /usr/bin/fish
# TODO: SSH keys, no password SSH, passwordless SUDO
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

### Backups

#### Install b2

Download b2-linux and SCP to the server. Place it somewhere. `b2-linux authorize-something`

`/root/minecraft-backup.sh`

```bash
#!/bin/bash
backup_folder="/home/minecraft"
backup_file="minecraft_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
bucket_name="tram-game-server-backups"

RCON_HOST="127.0.0.1"
RCON_PORT="25575"
RCON_PASS="jokVZFYP9D2NZiKRA3Ho"

mcrcon -H $RCON_HOST -P $RCON_PORT -p $RCON_PASS "say THE SERVER IS GOING DOWN FOR WEEKLY BACKUP IN 60 SECONDS!"

sleep 60

mcrcon -H $RCON_HOST -P $RCON_PORT -p $RCON_PASS "say THE SERVER IS GOING DOWN NOW FOR WEEKLY BACKUP!"
sleep 1
mcrcon -H $RCON_HOST -P $RCON_PORT -p $RCON_PASS "say 5..."
sleep 1
mcrcon -H $RCON_HOST -P $RCON_PORT -p $RCON_PASS "say 4..."
sleep 1
mcrcon -H $RCON_HOST -P $RCON_PORT -p $RCON_PASS "say 3..."
sleep 1
mcrcon -H $RCON_HOST -P $RCON_PORT -p $RCON_PASS "say 2..."
sleep 1
mcrcon -H $RCON_HOST -P $RCON_PORT -p $RCON_PASS "say 1..."
sleep 1

systemctl stop minecraft

# Compress the minecraft directory
tar -czvf $backup_file --exclude "mods" -C $backup_folder .

systemctl start minecraft

/root/b2-linux upload_file $bucket_name $backup_file minecraft/$backup_file

echo "Cleaning up old backup files..."
. /root/delete_old_backups.sh
```

`/root/delete_old_backups.sh`

```bash
#!/bin/bash

# B2 Bucket Details
bucket_name="tram-game-server-backups"
directory_path="minecraft" # Directory inside the bucket

# List files in the directory sorted by date (newest first)
files=$(/root/b2-linux ls --long $bucket_name $directory_path | sort -rk3,3)

# Count the number of files
file_count=$(echo "$files" | wc -l)

# Number of files to keep
keep=10

# Check if there are more than 10 files
if [ $file_count -gt $keep ]; then
    # Get the files to delete
    files_to_delete=$(echo "$files" | tail -n +$((keep + 1)))

    # Loop through and delete each file
    echo "$files_to_delete" | while read -r file; do
        file_name=$(echo $file | awk '{print $9}')
        if [ ! -z "$file_name" ]; then
            echo "Deleting $file_name"
            /root/b2-linux delete_file_version $file_name $file_name
        fi
    done
else
    echo "There are $file_count files in the bucket, no need to delete."
fi
```

Crontab:

```shell
0 15 * * 1 /root/minecraft-backup.sh
```

## All The Mods 9

The ATM9 ModPack Plus

Wall-Jump TXF
GoProne
Curios Compat
Keep My Soil Tilled
Collective
