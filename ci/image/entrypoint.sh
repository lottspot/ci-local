#!/bin/bash
set -e

test $# -gt 0         || { printf 'usage: %s <script>...\n' "$(basename "$0")" >&2; exit 1; }
test "$PUID"          || PUID=$(stat -c %u "$1")
test "$PGID"          || PGID=$(stat -c %g "$1")
test "$GIT_WORK_TREE" || GIT_WORK_TREE=$(pwd)
test "$GIT_DIR"       || GIT_DIR=$GIT_WORK_TREE/.git

export SHELL=/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=$GIT_WORK_TREE
export USER=$PUID
export LOGNAME=$PUID
export MAIL=/var/spool/mail/$LOGNAME
export GIT_WORK_TREE
export GIT_DIR

sup_groups="$PGID"

if [[ ${DOCKER_HOST:-unix:///var/run/docker.sock} =~ ^unix://(.*) ]] && [[ -e ${BASH_REMATCH[1]} ]]; then
  docker_sock=${BASH_REMATCH[1]}
  sup_groups+=,$(stat -c %g "$docker_sock")
fi

cd "$GIT_WORK_TREE"
exec setpriv --reuid "$PUID" --regid "$PGID" --groups "$sup_groups" /bin/bash <<EOF
set -e
$(for ci_script in "$@"; do printf 'source "%s"\n' "$ci_script"; done)
EOF
