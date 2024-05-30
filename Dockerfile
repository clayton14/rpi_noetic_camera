# This is an auto generated Dockerfile for ros:ros-core
# generated from docker_images/create_ros_core_image.Dockerfile.em
FROM ubuntu:focal

# set default shell
SHELL ["/bin/bash", "-c"]

#update sources.list
COPY ./sources.list /etc/apt/source.list


# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get upgrade -y  
RUN apt-get install -q -y --no-install-recommends \
    build-essential \
    dirmngr \
    gnupg2 \
    apt-utils \
    curl \
    wget \
    git \
    ffmpeg \
    v4l-utils \
    && rm -rf /var/lib/apt/lists/*

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

# setup environment

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV PORT=11311
ENV ROS_DISTRO noetic


EXPOSE 11311
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-ros-core=1.5.0-1* \
    && rm -rf /var/lib/apt/lists/*


# Setup Ros workspace
RUN source /opt/ros/$ROS_DISTRO/setup.bash -- \
    && mkdir -p /home/catkin_ws/src \
    && cd /home/catkin_ws \
    && catkin_make \
    && source devel/setup.bash \
    && echo "[ROS TEST] package path is -> $ROS_PACKAGE_PATH) " 

    # setup entrypoint
COPY ./ros_entrypoint.sh /
COPY ./camera_node.py /home/



#ENTRYPOINT ["/ros_entrypoint.sh"]




CMD ["bash"]