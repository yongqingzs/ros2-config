FROM --platform=linux/arm64 ros:jazzy-ros-base

# Setup user for GUI to work without xhost
ARG UNAME=ocs2
ARG UID=1000
ARG GID=1000
ARG http_proxy=http://127.0.0.1:7890
ARG https_proxy=http://127.0.0.1:7890
ARG no_proxy=localhost,127.0.0.1
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN usermod -aG sudo ${UNAME}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${UNAME}

# Remove ubuntu user to avoid UID conflicts
RUN sudo deluser ubuntu || true

# Set LD_LIBRARY_PATH for custom libraries
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Create workspace
ENV QUAD_WS=/home/ocs2/quad_ws
RUN mkdir -p ${QUAD_WS}/src

# Disable terminal interaction for apt
ENV DEBIAN_FRONTEND=noninteractive

# Make default shell in Dockerfile bash instead of sh
SHELL ["/bin/bash", "-c"]

# Install basic tools
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    wget \
    vim \
    gdb \
    git \
    cmake \
    build-essential \
    python3 \
    python3-pip \
    python3-colcon-common-extensions \
    python3-colcon-clean \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Install MuJoCo dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    libglfw3-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    libyaml-cpp-dev \
    libglfw3 \
    && sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Clone quadruped_ros2_control
RUN cd ${QUAD_WS}/src && \
    git clone https://github.com/legubiao/quadruped_ros2_control.git && \
    cd quadruped_ros2_control && \
    git checkout 5434c5810d1a7fe223bcfd04550e9d3bfdd4b458

# Clone ocs2_ros2
RUN cd ${QUAD_WS}/src && \
    git clone https://github.com/legubiao/ocs2_ros2 && \
    cd ocs2_ros2 && \
    git checkout bac496f915f3b6a9c859b8989e3d6b6f56970271 && \
    git submodule update --init --recursive

# Install dependencies and build ROS2 packages
RUN sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN sudo apt-get update
RUN cd ${QUAD_WS} && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y || true && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN cd ${QUAD_WS} && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    MAKEFLAGS="-j4" colcon build --packages-up-to unitree_guide_controller go2_description keyboard_input --symlink-install

# Build ocs2_quadruped_controller
RUN cd ${QUAD_WS} && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    . install/setup.bash && \
    MAKEFLAGS="-j4" colcon build --packages-up-to ocs2_qp_solver blasfeo_colcon --symlink-install

COPY ocs2_arm64/replace/hpipm_colcon/CMakeLists.txt \
        ${QUAD_WS}/src/ocs2_ros2/mpc/ocs2_sqp/hpipm_colcon/CMakeLists.txt

RUN cd ${QUAD_WS} && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    MAKEFLAGS="-j4" colcon build --packages-select hpipm_colcon

RUN cd ${QUAD_WS} && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    . install/setup.bash && \
    MAKEFLAGS="-j4" colcon build --packages-up-to ocs2_quadruped_controller --symlink-install

# Build MuJoCo
RUN cd ${QUAD_WS}/src && \
    git clone https://github.com/google-deepmind/mujoco.git && \
    cd mujoco && \
    git checkout d77ecb3f064678cc9227cdb8e0f5fccad97569fc && \
    mkdir build && cd build && \
    cmake .. && \
    make -j4 && \
    sudo make install

# Build unitree_sdk2
RUN cd ${QUAD_WS}/src && \
    git clone https://github.com/unitreerobotics/unitree_sdk2.git && \
    cd unitree_sdk2/ && \
    git checkout 3d7f4a57c169420301cfa12479789e5142342d8e && \
    mkdir build && cd build && \
    cmake .. && \
    make -j4 && \
    sudo make install

# Build unitree_mujoco
RUN cd ${QUAD_WS}/src && \
    git clone https://github.com/legubiao/unitree_mujoco && \
    cd unitree_mujoco && \
    git checkout 1fda65800287c369001da5e07ebd4652470f22f3

COPY ocs2_arm64/replace/unitree_mujoco/main.cc \
        ${QUAD_WS}/src/unitree_mujoco/simulate/src/main.cc

COPY ocs2_arm64/replace/unitree_mujoco/unitree_sdk2_bridge.cc \
        ${QUAD_WS}/src/unitree_mujoco/simulate/src/unitree_sdk2_bridge/unitree_sdk2_bridge.cc

RUN cd ${QUAD_WS}/src/unitree_mujoco/simulate && \
    mkdir build && cd build && \
    cmake .. && \
    make -j4

# Build hardware_unitree_sdk2
RUN cd ${QUAD_WS} && \
    . /opt/ros/${ROS_DISTRO}/setup.bash && \
    . install/setup.bash && \
    MAKEFLAGS="-j4" colcon build --packages-up-to hardware_unitree_sdk2 --symlink-install

# Source ROS workspace automatically when new terminal is opened
RUN echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo ". ${QUAD_WS}/install/setup.bash" >> ~/.bashrc

# Set up alias for unitree_mujoco
RUN echo "alias unitree_mujoco='${QUAD_WS}/src/unitree_mujoco/simulate/build/unitree_mujoco'" >> ~/.bashrc

WORKDIR ${QUAD_WS}

# Source ROS in the main terminal
COPY ocs2_arm64/ros_entrypoint.sh /ros_entrypoint.sh
RUN sudo chmod +x /ros_entrypoint.sh

# Source ROS in the main terminal
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]

