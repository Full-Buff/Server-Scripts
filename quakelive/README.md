# Scripts for Quake Live Game Servers

## ql-minqlx-setup.sh
Because of how pterodactyl's filesystem/networking functions in regards to resources inside of a given game server container, I have this setup script installing all the python packages, and even building redis, directly in the /mnt/server directory. Then, all the configs for redis, minqlx, etc., that are run out of this "root" directory, should just point to other files with "./...". Otherwise, during runtime of the server, anything with absolute paths wont be accessible. I'm pretty sure it would be accessible by /home/container instead, but o well :3
For some reason, the startup variables break during the passing of arguements from script, to script, to binary, so i just copy the output from the startup page directly into the startup configuration on the admin view side. Will keep trying to fix this.

Ideally, to avoid a lot of this, and integrate it better with ptero, I would instead setup a pterodactyl MySQL database on the server instance, and point minqlx to that, but i have no idea how it would behave interfacing with a totally different db. Will also work on this in the future.

Current example startup command: ./start_server.sh  +set net_port {{SERVER_PORT}} +set sv_hostname.....

Redis files that matter in our context if we need to reinstall:
    1. ./dump.rdb
    2. ./redis_6379.pid
    3. ./redis.log