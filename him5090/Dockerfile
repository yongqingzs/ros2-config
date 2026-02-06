# 基础镜像：Ubuntu 20.04 + CUDA 11.3 + cuDNN 8
FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

# 设置非交互模式，避免 tzdata 等卡死
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["bash", "-c"]

# 更新系统并安装基本工具
RUN apt-get update && apt-get install -y \
    wget git curl vim zip unzip bzip2 ca-certificates cmake\
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    libopenblas-dev libomp-dev libgl1-mesa-glx libglew-dev \
    p7zip-full p7zip-rar \
    && rm -rf /var/lib/apt/lists/*

# 安装 Miniconda
WORKDIR /opt
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_24.3.0-0-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

# 创建工作目录
WORKDIR /workspace

# 下载 Isaac Gym Preview 4 （⚠️需手动下载）
# 由于 Isaac Gym 需登录 NVIDIA 开发者账号下载，无法自动拉取
# 你需手动将 Isaac Gym 压缩包放入同级目录（与 Dockerfile 同级）
# 文件名例如：IsaacGym_Preview_4_Package.tar.gz
COPY IsaacGym_Preview_4_Package.tar.gz /workspace/

# 解压并安装 Isaac Gym
RUN tar -xzf IsaacGym_Preview_4_Package.tar.gz

COPY torch-2.3.0a0+git63d5e92-cp38-cp38-linux_x86_64.whl /workspace/

RUN conda create -y -n himloco python=3.8 && \
    echo "conda activate himloco" >> ~/.bashrc && \
    mkdir -p /opt/conda/envs/himloco/etc/conda/activate.d && \
    echo 'export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH' >> /opt/conda/envs/himloco/etc/conda/activate.d/env_vars.sh

RUN source activate himloco && \
    pip install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple && \
    pip install numpy==1.23.5 -i https://mirrors.aliyun.com/pypi/simple

RUN source activate himloco && \
    cd /workspace/ && \
    pip install torch-2.3.0a0+git63d5e92-cp38-cp38-linux_x86_64.whl -i https://mirrors.aliyun.com/pypi/simple

RUN source activate himloco && \
    pip install torchvision==0.18.1 torchaudio==2.3.1 -i https://mirrors.aliyun.com/pypi/simple

RUN source activate himloco && \
    cd /workspace/isaacgym/python && \
    pip install -e . -i https://mirrors.aliyun.com/pypi/simple

RUN source activate himloco && \
    cd /workspace/ && \
    pip install torch-2.3.0a0+git63d5e92-cp38-cp38-linux_x86_64.whl

RUN source activate himloco && \
    pip3 install tensorboard matplotlib -i https://mirrors.aliyun.com/pypi/simple

# 需要在外面做好准备，适配 5090
COPY HIMLoco/ /workspace/HIMLoco/

RUN source activate himloco && \
    cd /workspace/HIMLoco/rsl_rl && pip install -e . && \
    cd /workspace/HIMLoco/legged_gym && pip install -e .

RUN rm -f /workspace/IsaacGym_Preview_4_Package.tar.gz /workspace/torch-2.3.0a0+git63d5e92-cp38-cp38-linux_x86_64.whl

RUN sed -i '/conda activate himloco/d' ~/.bashrc && \
    echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate himloco" >> ~/.bashrc

# 设置默认环境
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

WORKDIR /workspace/HIMLoco

CMD ["/bin/bash"]
