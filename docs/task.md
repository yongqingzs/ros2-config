## tips
1. 使用中文完成文档。
2. 使用中文和我对话。

## task1
分析并梳理 IssacLab 包中的文件，完成以下任务:
1. 说明其实现的功能和各个文件间的关系。
2. 说明各个文件的功能。
3. 说明我该如何使用它。
4. 说明你觉得应当说明的内容。
5. 将整理好的内容输出到 docs 下的 IssacLab.md 中。

## task2
依据 ocs2_ros2/start.md、jazzy 的内容，完成以下任务:
1. 完成类似 jazzy 文件夹下的镜像建立、docker compose 管理
2. 需要符合 start.md 中的源码构建
3. 在 ocs2_ros2 下输出说明文档，包括
- 该镜像是否兼容 arm64、x64
- 该容器通过 docker run 启用时的命令行

## task3
ocs2_ros2 目录下是针对 x64 架构的 ocs2 环境。根据 ocs2_ros2，现在完成以下任务:
1. 不使用"osrf/ros:jazzy-desktop-full"这种完全版，而是使用"ros:jazzy-base"( 但需要注意，我不清楚哪里提供 arm64 的 ros:jazzy-base )
2. 创建一个新的文件夹，针对 arm64 架构的 ocs2 环境，完成相关镜像构建、docker compose 管理
