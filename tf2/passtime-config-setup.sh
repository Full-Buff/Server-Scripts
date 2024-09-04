#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'debian:buster-slim'

##
#
# Variables
# STEAM_USER, STEAM_PASS, STEAM_AUTH - Steam user setup. If a user has 2fa enabled it will most likely fail due to timeout. Leave blank for anon install.
# WINDOWS_INSTALL - if it's a windows server you want to install set to 1
# SRCDS_APPID - steam app id ffound here - https://developer.valvesoftware.com/wiki/Dedicated_Servers_List
# EXTRA_FLAGS - when a server has extra glas for things like beta installs or updates.
#
##

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
mkdir -p /mnt/server/steamapps # Fix steamcmd disk write error when this folder is missing
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
./steamcmd.sh +force_install_dir /mnt/server +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} validate +quit ## other flags may be needed depending on install. looking at you cs 1.6

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so



# FullBuff Customizations

rm -rf /mnt/server/tmp/*

echo "Installing unzip package"
apt-get install -y unzip

# Download and install MetaMod:Source
echo "Pulling MetaMod:Source files."
mkdir -p /mnt/server/tmp
cd /mnt/server/tmp
curl -sSL -o metamod.tar.gz https://lnk.fullbuff.gg/metamodsource-latest
tar -xzvf metamod.tar.gz
cp -r addons /mnt/server/tf

rm -rf /mnt/server/tmp/*

# Download and install SourceMod
echo "Pulling SourceMod files."
curl -sSL -o sourcemod.tar.gz https://lnk.fullbuff.gg/sourcemod-latest
tar -xzvf sourcemod.tar.gz
cp -r addons /mnt/server/tf
cp -r cfg /mnt/server/tf

rm -rf /mnt/server/tmp/*

# Download and install Curl Extension for SourceMod
echo "Pulling curl-extension for sourcemod files."
curl -sSL -o curlext.zip https://lnk.fullbuff.gg/curlext-latest
unzip curlext.zip -d curlext
cp -r curlext/* /mnt/server/tf/addons/sourcemod

rm -rf /mnt/server/tmp/*


# Pulling all necessary plugins from the RGL server-resources-updater individually to avoid passtime specific errors 

# Download and extract Passtime configs
echo "Pulling Passtime files."
curl -sSL -o p4sstime-configs-main.zip https://github.com/SpeakersVolumeUp/p4sstime-configs/archive/refs/heads/main.zip
unzip -o p4sstime-configs-main.zip -d /mnt/server/tmp/
cp -r /mnt/server/tmp/p4sstime-configs-main/cfg/* /mnt/server/tf/cfg/

# Download Passtime plugin
echo "Pulling Passtime plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/p4sstime.smx https://lnk.fullbuff.gg/passtime-plugin-latest

# Download Updater plugin files
wget -r -np -nH --cut-dirs=3 -P /mnt/server/tf/addons/sourcemod/ https://mirror.fullbuff.gg/tf2/addons/updater/

# Download and install tf2-comp-fixes plugin
echo "Pulling tf2-comp-fixes-latest files."
curl -sSL -o tf2-comp-fixes.zip https://lnk.fullbuff.gg/tf2-comp-fixes-latest
unzip tf2-comp-fixes.zip -d tf2-comp-fixes
cp -r tf2-comp-fixes/* /mnt/server/tf/addons

# Download SrcTV+ files
echo "Pulling SrcTV+ files."
curl -sSL -o /mnt/server/tf/addons/srctvplus.so https://lnk.fullbuff.gg/srctvplus-linux-latest
curl -sSL -o /mnt/server/tf/addons/srctvplus.vdf https://lnk.fullbuff.gg/passtime-plugin-latest

# Download and install updated-pause-plugin  plugin
echo "Pulling updated-pause-plugin files."
curl -sSL -o updated-pause-plugin.zip https://lnk.fullbuff.gg/updated-pause-latest
unzip updated-pause-plugin.zip -d updated-pause-plugin
cp -r updated-pause-plugin/* /mnt/server/tf

# Download and install RGL server-resources-updater plugin
echo "Pulling RGL server-resources-updater files."
curl -sSL -o server-resources-updater.zip https://lnk.fullbuff.gg/rgl-server-resources-updater-latest
unzip server-resources-updater.zip -d server-resources-updater
cp server-resources-updater/addons/sourcemod/plugins/rglupdater.smx /mnt/server/tf/addons/sourcemod/plugins/rglupdater.smx



rm -rf /mnt/server/tmp/*

# Download and install demos.tf plugin
echo "Pulling demos.tf plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/demostf.smx https://github.com/demostf/plugin/raw/master/demostf.smx

# Download and copy MedicStats plugin
echo "Pulling Medicstats plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/medicstats.smx https://mirror.fullbuff.gg/tf2/addons/medicstats/medicstats.smx

# Download and copy SupStats plugin
echo "Pulling Supstats plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/supstats2.smx https://mirror.fullbuff.gg/tf2/addons/supstats2/supstats2.smx

# Download and copy LogsTF plugin
echo "Pulling Logstf plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/logstf.smx https://mirror.fullbuff.gg/tf2/addons/logstf/logstf.smx

# Download and copy RecordSTV plugin
echo "Pulling RecordSTV plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/recordstv.smx https://mirror.fullbuff.gg/tf2/addons/recordstv/recordstv.smx

# Download and copy WaitForSTV plugin
echo "Pulling WaitForSTV plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/waitforstv.smx https://mirror.fullbuff.gg/tf2/addons/waitforstv/waitforstv.smx

# Download and copy AFK plugin
echo "Pulling AFK plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/afk.smx https://mirror.fullbuff.gg/tf2/addons/afk/afk.smx

# Download and copy RestoreScore plugin
echo "Pulling RestoreScore plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/restorescore.smx https://mirror.fullbuff.gg/tf2/addons/restorescore/restorescore.smx

# Download and copy FixSTVSlot plugin
echo "Pulling FixSTVSlot plugin files."
curl -sSL -o /mnt/server/tf/addons/sourcemod/plugins/fixstvslot.smx https://mirror.fullbuff.gg/tf2/addons/fixstvslot/fixstvslot.smx


# Extra Plugins



rm -rf /mnt/server/tmp/*



# Download and copy MOTD files
echo "Pulling MOTD files."
curl -sSL https://mirror.fullbuff.gg/tf2/cfg/motd_text_default.txt > /mnt/server/tf/cfg/motd_text_default.txt
curl -sSL https://mirror.fullbuff.gg/tf2/cfg/motd_default.txt > /mnt/server/tf/cfg/motd_default.txt


# Check if the server.cfg file already exists
if [ ! -f /home/container/tf/cfg/server.cfg ]; then
    # Download the default server.cfg file
    curl -sSL -o /mnt/server/tf/cfg/server.cfg https://mirror.fullbuff.gg/tf2/cfg/server.cfg
    echo "server.cfg downloaded successfully."
else
    echo "The file /home/container/tf/cfg/server.cfg already exists. Skipping download."
fi

# Remove default maps and download current Passtime map pool
echo "Pulling Passtime map pool."
rm -rf /mnt/server/tf/maps/*
cd /mnt/server/tf/maps
wget -r -np -nH --cut-dirs=1 -A "*.bsp" https://fastdl.fullbuff.gg/tf2-4v4_passtime-pool/

# Download 2Fort as a backup default map
echo "Pulling 2fort as a backup default map."
cd /mnt/server/tf/maps
wget -np -nH --cut-dirs=1 -A "*" https://fastdl.fullbuff.gg/tf/ctf_2fort.bsp


echo -e "Install Complete \nInstall Complete \nInstall Complete \n \n \n Please Start the server to begin playing!"