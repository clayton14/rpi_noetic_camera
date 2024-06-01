# This is an auto generated Dockerfile for ros:ros-core
# generated from docker_images/create_ros_core_image.Dockerfile.em
FROM ros:noetic-ros-core-focal

# set default shell
SHELL ["/bin/bash", "-c"]

#update sources.list
COPY ./sources.list /etc/apt/source.list

# set environment varables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_PORT=11311
ENV ROS_DISTRO=noetic
ENV CAM_PKG_NAME=pi_zero_camera
ENV CAM_PKG_PATH=/home/catkin_ws/src/"$CAM_PKG_NAME"

EXPOSE 11311

# setup timezone
# RUN echo 'Etc/UTC' > /etc/timezone && \
#     ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
#     apt-get update && \
#     apt-get install -q -y --no-install-recommends tzdata && \
#     rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get upgrade -y  
RUN apt-get install -q -y --no-install-recommends \
    build-essential \
    python3-pip \
    python3.8-venv \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    dirmngr \
    gnupg2 \
    apt-utils \
    curl \
    wget \
    git \
    ffmpeg \
    v4l-utils \
    python3-numpy \
    python3-opencv \
    libboost-python-dev \
    && rm -rf /var/lib/apt/lists/*


# bootstrap rosdep
RUN rosdep init && \
  rosdep update --rosdistro "$ROS_DISTRO"

# setup keys
RUN set -eux; \
       key='C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654'; \
       export GNUPGHOME="$(mktemp -d)"; \
       gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
       mkdir -p /usr/share/keyrings; \
       gpg --batch --export "$key" > /usr/share/keyrings/ros1-latest-archive-keyring.gpg; \
       gpgconf --kill all; \
       rm -rf "$GNUPGHOME"

# setup sources.list
RUN echo "deb [ signed-by=/usr/share/keyrings/ros1-latest-archive-keyring.gpg ] http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list

# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-ros-base=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*

# install cv-bridge 
RUN apt-get update && apt-get install "ros-$ROS_DISTRO-cv-bridge" -y \
    && rm -rf /var/lib/apt/lists/*

# Setup Ros workspace
RUN source /opt/ros/"$ROS_DISTRO"/setup.bash -- \
    && mkdir -p /home/catkin_ws/src \
    && cd /home/catkin_ws \
    && catkin_make \
    && chmod +x /home/catkin_ws/devel/setup.bash \
    && source /home/catkin_ws/devel/setup.bash \
    && printf "#####[ROS ENVIRONMENT VARS]#####\n$(printenv | grep ROS)"


#create camera package    
RUN cd /home/catkin_ws/src/ \ 
    && catkin_create_pkg "$CAM_PKG_NAME" std_msgs rospy roscpp cv_bridge

# coppy files     
COPY ./ros_entrypoint.sh /
COPY ./camera_node.py "${CAM_PKG_PATH}/src"
COPY ./camera.launch  "${CAM_PKG_PATH}/src"

#Run camera_node.py
RUN source /home/catkin_ws/devel/setup.bash \
    && chmod +x "$CAM_PKG_PATH/src/camera_node.py" \
    && chmod +x ros_entrypoint.sh


COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

# CMD [ "ros_entrypoint.sh" ]
# CMD [ "roslaunch". "$CAM_PKG_NAME", "camera.launch" ]