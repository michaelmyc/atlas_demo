#!/bin/bash

# 定义颜色变量，用于在终端中输出彩色文本
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color - 重置颜色

# 第1步：初始化数据库环境，清理之前的导出结果
# 这一步确保我们从一个干净的状态开始
echo -e "${GREEN}第1步：初始化数据库，清空过往结果${NC}"

# 调用辅助脚本初始化主数据库容器
bash scripts/helpers/init_db.sh
# 向主数据库填充初始数据
bash scripts/helpers/populate_db.sh atlas-demo

# 删除现有的schema导出目录，确保从零开始
rm -rf schema/atlas_inspect
# 创建用于存储导出schema的目录结构
mkdir -p schema/atlas_inspect/multi_db/single_file
mkdir -p schema/atlas_inspect/multi_db/folder
mkdir -p schema/atlas_inspect/single_db/single_file
mkdir -p schema/atlas_inspect/single_db/folder

# 第2步：在非登录状态导出schema
# 演示免费版Atlas的功能限制
echo -en "${GREEN}第2步：在非登录状态导出schema${NC}"; read

# 退出Atlas登录状态，使用免费版功能
atlas logout

# 导出multi_db环境的schema到单个SQL文件（免费版）
atlas schema inspect --env multi_db --format '{{ sql . }}' > schema/atlas_inspect/multi_db/single_file/free.sql
# 导出single_db环境的schema到单个SQL文件（免费版）
atlas schema inspect --env single_db --format '{{ sql . }}' > schema/atlas_inspect/single_db/single_file/free.sql
# 导出multi_db环境的schema到多个文件（免费版）
atlas schema inspect --env multi_db --format '{{ sql . | split | write "schema/atlas_inspect/multi_db/folder/free" }}'
# 导出single_db环境的schema到多个文件（免费版）
atlas schema inspect --env single_db --format '{{ sql . | split | write "schema/atlas_inspect/single_db/folder/free" }}'

# 第3步：在登录状态导出schema
# 演示Pro版Atlas的增强功能
echo -en "${GREEN}第3步：在登录状态导出schema${NC}"; read

# 登录Atlas Pro账户以使用增强功能
atlas login

# 导出multi_db环境的schema到单个SQL文件（Pro版）
atlas schema inspect --env multi_db --format '{{ sql . }}' > schema/atlas_inspect/multi_db/single_file/pro.sql
# 导出single_db环境的schema到单个SQL文件（Pro版）
atlas schema inspect --env single_db --format '{{ sql . }}' > schema/atlas_inspect/single_db/single_file/pro.sql
# 导出multi_db环境的schema到多个文件（Pro版）
atlas schema inspect --env multi_db --format '{{ sql . | split | write "schema/atlas_inspect/multi_db/folder/pro" }}'
# 导出single_db环境的schema到多个文件（Pro版）
atlas schema inspect --env single_db --format '{{ sql . | split | write "schema/atlas_inspect/single_db/folder/pro" }}'

# 提示用户注意免费版与Pro版的功能差异
echo -e "${RED}注意：有一些功能（如view、trigger等）只有Pro版有，所以这里需要格外小心 - https://atlasgo.io/features#database-features${NC}"