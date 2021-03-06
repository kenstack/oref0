#!/bin/bash


self=$(basename $0)
NAME=${1-help}
shift
PROGRAM="oref0-${NAME}"
COMMAND=$(which $PROGRAM | head -n 1)

function help_message ( ) {
  cat <<EOF
  Usage:
$self <cmd>

     ______   ______   ______  ______ 0
    / |  | \ | |  | \ | |     | |      
    | |  | | | |__| | | |---- | |----  
    \_|__|_/ |_|  \_\ |_|____ |_|      

Valid commands:
  oref0 device-helper - <name> <spec>  : create/template a device from bash commands easily
  oref0 alias-helper  - <name> <spec>  : create/template a alias from bash commands easily
  oref0 cron-5-minute-helper  - <cmds> - generate a cron template for commands
                                         to run every 5 minutes:
                                         oref0 cron-5-minute-helper openaps do-everything
  oref0 env                            - print information about environment.
  oref0 pebble
  oref0 ifttt-notify
  oref0 get-profile
  oref0 calculate-iob
  oref0 meal
  oref0 determine-basal
  oref0 export-loop [backup-loop.json] - Print a backup json representation of
                                         entire configuration. Optionally, if a
                                         filename is specified, listing is
                                         saved in the file instead.
  oref0 help - this message
EOF
}

case $NAME in
device-helper)
  name=$1
  shift
  cat <<EOF
{"$name": {"vendor": "openaps.vendors.process", "extra": "${name}.ini"}, "type": "device", "name": "$name", "extra": {"fields": "", "cmd": "bash", "args": "-c \"$*\" -- "}}

EOF
  ;;
alias-helper)
  name=$1
  shift
  cat <<EOF
{"type": "alias", "name": "$name", "$name": {"command": "! bash -c \"$*\" --"}}
EOF
  ;;
cron-5-minute-helper)
  name=${1-'openaps do-everything'}
  shift
  workdir=$(pwd)
  cat <<EOF
SHELL=/bin/bash
PATH=$PATH

*/5 * * * * (cd $workdir && time ${name} $*) 2>&1 | logger -t openaps-loop

EOF
  ;;
env)
  echo PATH=$PATH
  env
  exit
  ;;
export-loop)
  out=${1-/dev/stdout}
  openaps import -l | while read type ; do openaps $type show --json ; done | json -g > $out

  exit
  ;;
help|--help|-h)
  help_message
  ;;
*)
  test -n "$COMMAND" && exec $COMMAND $*
  ;;
esac


