#!/bin/sh

# REQUIRE: FILESYSTEMS
# REQUIRE: NETWORKING
# PROVIDE: meshcommander

. /etc/rc.subr

name="meshcommander"
rcvar="meshcommander_enable"
start_cmd="meshcommander_start"
stop_cmd="meshcommander_stop"

pidfile="/var/run/${name}.pid"

load_rc_config ${name}

meshcommander_start()
{
  if checkyesno ${rcvar}; then
    echo "Starting meshcommander. "
    cd /usr/local/meshcommander
    /usr/local/bin/node node_modules/meshcommander --any &
    echo $! > $pidfile

  fi
}

meshcommander_stop()
{

  if [ -f $pidfile ]; then
    echo -n "Signaling the meshcommander  to stop..."

    kill -9 `cat $pidfile`

    # Remove the pid file:
    rm $pidfile

    echo " stopped.";
  else
    echo "There is no pid file."
  fi
}

run_rc_command "$1"
