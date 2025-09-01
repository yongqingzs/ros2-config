#!/bin/bash
set -e

# Source ROS2
. "/opt/ros/${ROS_DISTRO}/setup.bash"

# Source workspace
. "${QUAD_WS}/install/setup.bash"

# Execute the command passed into this entrypoint
exec "$@"
