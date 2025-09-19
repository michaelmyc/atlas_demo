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

# 第1步：清空数据库
# 初始化数据库环境，为声明式迁移做准备
echo -e "${GREEN}第1步：清空数据库${NC}"

# 调用辅助脚本初始化主数据库容器
bash scripts/helpers/init_db.sh

# 第2步：在非登录状态声明式apply schema
# 演示免费版Atlas的声明式迁移功能
echo -en "${GREEN}第2步：在非登录状态声明式apply schema${NC}"; read

# 退出Atlas登录状态，使用免费版功能
atlas logout
# 应用multi_db环境的schema定义（免费版功能）
atlas schema apply --env multi_db

# 第3步：在登录Pro用户状态声明式apply schema
# 演示Pro版Atlas的增强声明式迁移功能
echo -en "${GREEN}第2步：在登录Pro用户状态声明式apply schema${NC}"; read

# 登录Atlas Pro账户以使用增强功能
atlas login
# 应用multi_db环境的schema定义（Pro版功能）
atlas schema apply --env multi_db

# 提示用户注意免费版与Pro版的功能差异
echo -e "${RED}注意：可以看到，虽然apply的是同一个schema，但有一些功能（如view、trigger等）只有Pro版有，所以这里需要格外小心 - https://atlasgo.io/features#database-features${NC}"
