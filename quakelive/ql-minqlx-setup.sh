#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'ghcr.io/parkervcp/installers:debian'

# Install packages. Default packages below are not required if using our existing install image thus speeding up the install process.
#apt -y update
#apt -y --no-install-recommends install curl lib32gcc-s1 ca-certificates

## just in case someone removed the defaults.
if [[ "${STEAM_USER}" == "" ]] || [[ "${STEAM_PASS}" == "" ]]; then
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
./steamcmd.sh +force_install_dir /mnt/server +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) ${INSTALL_FLAGS} validate +quit ## other flags may be needed depending on install. looking at you cs 1.6

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

## add below your custom commands if needed

# MinQLX Installation
apt-get update
apt-get -y install python3 python3-dev python3-pip python3-redis redis-server git build-essential

export PYTHONPATH=/usr/local/lib/python3.11/dist-packages:$PYTHONPATH

cd /mnt/server/
git clone https://github.com/MinoMino/minqlx.git
cd minqlx
make

# Move files to the correct location
cp -a /mnt/server/minqlx/bin/. /mnt/server/
rm -rf /mnt/server/minqlx

# Install minqlx plugins
cd /mnt/server/
git clone https://github.com/MinoMino/minqlx-plugins.git
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py
export PIP_BREAK_SYSTEM_PACKAGES=1  # Workaround for Debian 12+ users
pip install --target=/mnt/server/ -r /mnt/server/minqlx-plugins/requirements.txt
#python3 -m pip install --upgrade pip
pip install --target=/mnt/server/ redis


# Install Redis locally in the server directory
cd /mnt/server/
mkdir -p redis_local
cd redis_local
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
make PREFIX=/mnt/server/redis install

# Create a Redis configuration file
cat > /mnt/server/redis.conf << 'EOL'
daemonize yes
port 6379
bind 127.0.0.1
dir ./
pidfile ./redis_6379.pid
logfile ./redis.log
EOL

# Create a proper startup script
cat > /mnt/server/start_server.sh << 'EOL'
#!/bin/bash
# Start Redis server
echo "Starting Redis server..."
# Use the full path to the redis-server binary
./redis_local/redis-stable/src/redis-server ./redis.conf
# Wait a bit for Redis to start
sleep 2
echo "Redis started. Starting Quake Live server..."
# Start Quake Live with minqlx
exec ./run_server_x64_minqlx.sh "$@"
EOL


## install end
echo "-----------------------------------------"
echo "Installation completed..."
echo "-----------------------------------------"