# Check if the server.cfg file already exists
if [ -f /home/container/tf/cfg/server.cfg ]; then
    echo "The file /home/container/tf/cfg/server.cfg already exists. Script will not run."
    exit 1
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