FROM osrf/ros:jazzy-desktop-full

# Setup user for GUI to work without xhost
ARG UNAME=sar
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN usermod -aG sudo ${UNAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${UNAME}

# Create a custom ros2 overlay workspace and workspace for exercises
RUN sudo deluser ubuntu || true
ENV ROS2_WS=/home/sar/ros2_ws
RUN mkdir -p ${ROS2_WS}/src
ENV EXERCISES_WS=/home/sar/jazzy_ws
RUN mkdir -p ${EXERCISES_WS}/src
ENV RL_PATH=/home/sar/rl_sar

# Disable terminal interaction for apt
ENV DEBIAN_FRONTEND=noninteractive

# Make default shell in Dockerfile bash instead of sh
SHELL ["/bin/bash", "-c"]

# Base
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    wget \
    vim \
    gdb \
    zip \
    unzip \
    p7zip-full \
    python3 \
    python3-pip \
    python3-colcon-clean \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Install Gazebo Fortress
RUN sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get install gz-harmonic -y

# Install dependencies
# sudo apt install cmake g++ build-essential libyaml-cpp-dev libeigen3-dev libboost-all-dev libspdlog-dev libfmt-dev libtbb-dev liblcm-dev
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    ros-$ROS_DISTRO-tf-transformations \
    ros-jazzy-ros-gz \
    cmake \
    g++ \
    build-essential \
    libyaml-cpp-dev \
    libeigen3-dev \
    libboost-all-dev \
    libspdlog-dev \
    libfmt-dev \
    libtbb-dev \
    liblcm-dev \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN sudo apt-get update && \
    sudo apt install -y --no-install-recommends \
    ros-jazzy-teleop-twist-keyboard \
    ros-jazzy-ros2-control \
    ros-jazzy-ros2-controllers \
    ros-jazzy-control-toolbox \
    ros-jazzy-robot-state-publisher \
    ros-jazzy-joint-state-publisher-gui \
    ros-jazzy-ros-gz-sim \
    ros-jazzy-ros-gz-sim-demos \
    ros-jazzy-xacro \
    libglfw3-dev \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Build exercises_ws
RUN cd ${EXERCISES_WS}/src && \
    git clone https://github.com/yongqingzs/quadruped_ros2_control.git && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd .. && \
    MAKEFLAGS="-j4" colcon build --packages-up-to keyboard_input --symlink-install

RUN cd && \
    git clone --recursive --depth 1 https://github.com/yongqingzs/rl_sar && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    . ${EXERCISES_WS}/install/setup.bash

RUN cd ${RL_PATH} && \
    ./build.sh -do

RUN cd ${RL_PATH} && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    . ${EXERCISES_WS}/install/setup.bash && \
    ./build.sh

RUN cd ${RL_PATH} && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    . ${EXERCISES_WS}/install/setup.bash && \
    ./build.sh -mj

# Source ROS workspace automatically when new terminal is opened
RUN sudo echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    sudo echo ". ${EXERCISES_WS}/install/setup.bash" >> ~/.bashrc && \
    sudo echo ". ${RL_PATH}/install/setup.bash" >> ~/.bashrc

WORKDIR /home/sar/rl_sar

# Source ROS in the main terminal
COPY rl_sar_jazzy/ros_entrypoint.sh /ros_entrypoint.sh

# Source ROS in the main terminal
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]
