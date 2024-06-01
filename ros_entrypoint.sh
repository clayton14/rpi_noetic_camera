#!/bin/bash
set -e

# setup ros environment
#source "/opt/ros/$ROS_DISTRO/setup.bash" --
chmod +x "/home/catkin_ws/devel/setup.bash" --
chmod +x "$CAM_PKG_PATH/src/camera_node.py"
source /home/catkin_ws/devel/setup.bash
roslaunch "$CAM_PKG_NAME" camera.launch

exec "$@"