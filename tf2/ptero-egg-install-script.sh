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


# Create default server.cfg

create_server_cfg() {
  # Check if the server.cfg file already exists
  if [ -f /home/container/tf/cfg/server.cfg ]; then
      echo "The file /home/container/tf/cfg/server.cfg already exists. Script will not run."
      return 1
  fi

  # Create the server.cfg file in /home/container/tf/cfg/
  cat <<'EOF' > /home/container/tf/cfg/server.cfg
  // FastDL
  sv_downloadurl "https://fastdl.fullbuff.gg/tf2"
  sv_allowdownload 1

  // API keys, add your keys below
  logstf_apikey 
  sm_demostf_apikey 


  // Auto-kick timeout (minutes)
  mp_idlemaxtime 3000




  // Server Convars

  // forces clients to use game files that are consistent with your server
  // you can change this value as the rgl plugin automatically loads it to sv_pure 2 when loading a config
  sv_pure 2

  // executes bans from your server's disk when server loads
  exec banned_user.cfg
  exec banned.cfg

  // die evil mechanics
  // disables random crits and random spreads by default
  tf_weapon_criticals 0
  tf_use_fixed_weaponspreads 1
  tf_damage_disablespread 1

  // SourceTV Convars

  // enables STV
  tv_enable 1

  // autorecords STV demos
  tv_autorecord 1

  // the delay in seconds the broadcast is behind
  // rgl requires this to be set at 90
  tv_delay 90

  // sets the maximum amount of people that connect to STV
  // you should set this to a reasonable number as it can reduce performance  
  tv_maxclients 5

  // writes bans from current session to disk
  writeid
  writeip

  heartbeat
EOF

  echo "server.cfg file created successfully."
}

# Call the function in your main script
(
  trap '' EXIT
  create_server_cfg
)



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

# Download and extract RGL resources updater
echo "Pulling RGL updater files."
curl -sSL -o rgl_resources_updater.zip https://github.com/RGLgg/server-resources-updater/releases/latest/download/server-resources-updater.zip
unzip -o rgl_resources_updater.zip -d /mnt/server/tf

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

echo -e "Install Complete \nInstall Complete \nInstall Complete \n \n \n Please Start the server to begin playing!"