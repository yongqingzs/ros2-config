# ros2-config
A containerized ROS 2 Humble environment with Gazebo support.

## usage
- support xterm
```bash
xhost +local:docker
```

- support nvidia gpu
```bash
# Install the NVIDIA Container Toolkit packages
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Configure the container runtime
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```
