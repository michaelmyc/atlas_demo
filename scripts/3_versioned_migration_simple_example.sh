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

# 第1步：初始化数据库环境，清理之前的迁移结果
# 这一步确保我们从一个干净的状态开始
echo -e "${GREEN}第1步：初始化数据库，清空过往结果${NC}"

# 调用辅助脚本初始化主数据库容器
bash scripts/helpers/init_db.sh
# 向主数据库填充初始数据
bash scripts/helpers/populate_db.sh atlas-demo

# 删除现有的多数据库迁移目录，确保从零开始
rm -rf migrations/multi_db

# 第2步：登录Atlas Pro账户
# Pro版本提供更多的数据库功能支持（如视图、触发器等）
echo -e "${GREEN}第2步：登录Pro用户${NC}"

# 执行Atlas登录命令，需要用户交互输入认证信息
atlas login

# 第3步：将现有数据库的schema设置为基线（baseline）
# 这是版本化迁移的第一步，用于标记数据库的初始状态
echo -e "${GREEN}第3步：设置已有数据库schema为baseline${NC}"

# 生成基线迁移文件，包含当前数据库结构
atlas migrate diff baseline --env multi_db

# 提取基线版本号，用于后续的迁移应用
BASELINE_VER=$(ls migrations/multi_db/*.sql | sed -E 's/.*\/([0-9]+).*$/\1/' | sort -n | head -1)
# 应用基线迁移，标记数据库当前状态为已知版本
atlas migrate apply --env multi_db --baseline $BASELINE_VER

# 第4步：创建schema迁移DDL
# 基于schema定义的差异生成迁移脚本
echo -en "${GREEN}第4步：创建schema迁移DDL${NC}"; read

# 生成迁移脚本，比较当前环境与目标schema的差异
# 这里使用multi_db环境和1_simple_edit目录中的schema定义
atlas migrate diff simple_edit --env multi_db --to "file://schema/definition/multi_db/1_simple_edit"

# 第5步：执行schema迁移DDL
# 将生成的迁移脚本应用到数据库
echo -en "${GREEN}第5步：执行schema迁移DDL${NC}"; read

# 应用迁移脚本到multi_db环境
atlas migrate apply --env multi_db

# 第6步：查看migration状态
# 检查迁移的状态，确认迁移是否成功应用
echo -en "${GREEN}第6步：查看migration状态${NC}"; read

# 显示multi_db环境的迁移状态
atlas migrate status --env multi_db

# 第7步：查看线上schema与原始schema的差异
# 验证当前数据库schema与初始schema的差异
echo -en "${GREEN}第6步：查看线上schema与原始schema的差异${NC}"; read

# 比较当前数据库schema与初始schema定义的差异
atlas schema diff --env multi_db --from env://url --to file://schema/definition/multi_db/0_init

# 第8步：schema回滚dry run确认
# 在实际执行回滚之前，先进行模拟运行以确认操作
echo -en "${GREEN}第7步：schema回滚dry run确认${NC}"; read

# 执行回滚的模拟运行，显示将要执行的操作但不实际执行
atlas migrate down --env multi_db --dry-run

# 第9步：再次查看migration状态
# 确认在dry run之后迁移状态没有改变
echo -en "${GREEN}第8步：查看migration状态${NC}"; read

# 再次显示multi_db环境的迁移状态
atlas migrate status --env multi_db

# 第10步：执行schema回滚
# 实际执行回滚操作，撤销最近应用的迁移
echo -en "${GREEN}第9步：执行schema回滚${NC}"; read

# 执行回滚操作，撤销最近应用的迁移
atlas migrate down --env multi_db

# 第11步：最后查看migration状态
# 确认回滚操作已成功执行
echo -en "${GREEN}第10步：查看migration状态${NC}"; read

# 最后显示multi_db环境的迁移状态
atlas migrate status --env multi_db
