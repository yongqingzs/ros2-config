#!/bin/bash
set -e

. "/opt/ros/${ROS_DISTRO}/setup.bash"
. "${QUAD_WS}/install/setup.bash"

exec "$@"
