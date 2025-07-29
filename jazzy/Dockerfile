FROM osrf/ros:jazzy-desktop-full

# Setup user for GUI to work without xhost
ARG UNAME=jazzy
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN usermod -aG sudo ${UNAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${UNAME}

# Create a custom ros2 overlay workspace and workspace for exercises
RUN sudo deluser ubuntu || true
ENV ROS2_WS=/home/jazzy/ros2_ws
RUN mkdir -p ${ROS2_WS}/src
ENV EXERCISES_WS=/home/jazzy/jazzy_ws
RUN mkdir -p ${EXERCISES_WS}/src

# Disable terminal interaction for apt
ENV DEBIAN_FRONTEND=noninteractive

# Make default shell in Dockerfile bash instead of sh
SHELL ["/bin/bash", "-c"]

# Base
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    wget \
    vim \
    python3-colcon-clean \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Install Gazebo Fortress
RUN sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get install gz-harmonic -y

# Install dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    ros-$ROS_DISTRO-navigation2 \
    ros-$ROS_DISTRO-turtle-nest \
    ros-$ROS_DISTRO-tf-transformations \
    ros-jazzy-ros-gz \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# pass: Install andino_gz and other packages with their dependencies

# Build exercises_ws
RUN cd ${EXERCISES_WS}/src && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd .. && \
    rosdep update && rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    colcon build --symlink-install

# Source ROS workspace automatically when new terminal is opened
RUN sudo echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    sudo echo ". ${EXERCISES_WS}/install/setup.bash" >> ~/.bashrc

WORKDIR /home/jazzy/jazzy_ws

# Source ROS in the main terminal
COPY jazzy/ros_entrypoint.sh /ros_entrypoint.sh

# Source ROS in the main terminal
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]
