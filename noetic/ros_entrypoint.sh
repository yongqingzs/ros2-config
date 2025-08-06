#!/bin/bash
set -e

. "/opt/ros/${ROS_DISTRO}/setup.bash"
. "${EXERCISES_WS}/devel/setup.bash"

exec "$@"
