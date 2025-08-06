FROM osrf/ros:noetic-desktop-full

# Setup user for GUI to work without xhost
ARG UNAME=noetic
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN usermod -aG sudo ${UNAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${UNAME}

# Create a catkin workspace and workspace for exercises
ENV CATKIN_WS=/home/noetic/catkin_ws
RUN mkdir -p ${CATKIN_WS}/src
ENV EXERCISES_WS=/home/noetic/noetic_ws
RUN mkdir -p ${EXERCISES_WS}/src

# Disable terminal interaction for apt
ENV DEBIAN_FRONTEND=noninteractive

# Make default shell in Dockerfile bash instead of sh
SHELL ["/bin/bash", "-c"]

# Base
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    git \
    wget \
    vim \
    gdb \
    python3 \
    python3-pip \
    python3-catkin-tools \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Install Gazebo 11 (compatible with ROS Noetic)
RUN sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get install gazebo11 -y

# Install dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    ros-$ROS_DISTRO-navigation \
    ros-$ROS_DISTRO-turtlesim \
    ros-$ROS_DISTRO-tf2-geometry-msgs \
    ros-$ROS_DISTRO-gazebo-ros \
    ros-$ROS_DISTRO-gazebo-ros-pkgs \
    ros-$ROS_DISTRO-gazebo-ros-control \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN sudo rosdep init || true
RUN rosdep update

# Build exercises_ws
RUN cd ${EXERCISES_WS}/src && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd .. && \
    rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    catkin build

# Source ROS workspace automatically when new terminal is opened
RUN sudo echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    sudo echo ". ${EXERCISES_WS}/devel/setup.bash" >> ~/.bashrc

WORKDIR /home/noetic/noetic_ws

# Source ROS in the main terminal
COPY noetic/ros_entrypoint.sh /ros_entrypoint.sh

# Source ROS in the main terminal
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]
