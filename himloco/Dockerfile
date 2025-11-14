# 基础镜像：Ubuntu 20.04 + CUDA 11.3 + cuDNN 8
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

# 设置非交互模式，避免 tzdata 等卡死
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["bash", "-c"]

# 更新系统并安装基本工具
RUN apt-get update && apt-get install -y \
    wget git curl vim zip unzip bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    libopenblas-dev libomp-dev libgl1-mesa-glx libglew-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装 Miniconda
WORKDIR /opt
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_24.3.0-0-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

# 创建 conda 环境 himloco
RUN conda create -y -n himloco python=3.7.16 && \
    echo "conda activate himloco" >> ~/.bashrc
RUN source activate himloco && \
    pip install --upgrade pip && \
    pip install torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 \
        -f https://download.pytorch.org/whl/cu113/torch_stable.html

RUN source activate himloco && \
    pip install matplotlib gym==0.21.0 onnx onnxruntime scipy tqdm -i https://mirrors.aliyun.com/pypi/simple/

# 创建工作目录
WORKDIR /workspace

# 下载 Isaac Gym Preview 4 （⚠️需手动下载）
# 由于 Isaac Gym 需登录 NVIDIA 开发者账号下载，无法自动拉取
# 你需手动将 Isaac Gym 压缩包放入同级目录（与 Dockerfile 同级）
# 文件名例如：IsaacGym_Preview_4_Package.tar.gz
COPY IsaacGym_Preview_4_Package.tar.gz /workspace/

# 解压并安装 Isaac Gym
RUN tar -xzf IsaacGym_Preview_4_Package.tar.gz && \
    cd isaacgym/python && source activate himloco && pip install -e .

# 克隆 HIMLoco 源码
RUN git clone https://github.com/OpenRobotLab/HIMLoco.git /workspace/HIMLoco

# 安装 HIMLoco (rsl_rl & legged_gym)
RUN source activate himloco && \
    cd /workspace/HIMLoco/rsl_rl && pip install -e . && \
    cd /workspace/HIMLoco/legged_gym && pip install -e .

RUN source activate himloco && \
    pip install tensorboard==2.11.2 tensorboard-data-server==0.6.1 tensorboard-plugin-wit==1.8.1 -i https://mirrors.aliyun.com/pypi/simple/

RUN sed -i '/conda activate himloco/d' ~/.bashrc && \
    echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate himloco" >> ~/.bashrc

RUN ln -s /opt/conda/envs/himloco/lib/libpython3.7m.so /usr/lib/libpython3.7m.so.1.0

# 替换 tensorboard __init__.py 文件
RUN cat <<'EOF' > /opt/conda/envs/himloco/lib/python3.7/site-packages/torch/utils/tensorboard/__init__.py
import tensorboard
#from setuptools import distutils

#LooseVersion = distutils.version.LooseVersion

#if not hasattr(tensorboard, '__version__') or LooseVersion(tensorboard.__version__) < LooseVersion('1.15'):
#    raise ImportError('TensorBoard logging requires TensorBoard version 1.15 or above')

#del distutils
#del LooseVersion
del tensorboard

from .writer import FileWriter, SummaryWriter  # noqa: F401
from tensorboard.summary.writer.record_writer import RecordWriter  # noqa: F401
EOF


# 设置默认环境
ENV PATH=/opt/conda/envs/himloco/bin:$PATH
ENV CONDA_DEFAULT_ENV=himloco
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

WORKDIR /workspace/HIMLoco

CMD ["/bin/bash"]
