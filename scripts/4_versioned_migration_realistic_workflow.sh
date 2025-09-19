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

# 删除现有的单数据库迁移目录，确保从零开始
rm -rf migrations/single_db

# 第2步：登录Atlas Pro账户
# Pro版本提供更多的数据库功能支持（如视图、触发器等）
echo -e "${GREEN}第2步：登录Pro用户${NC}"

# 执行Atlas登录命令，需要用户交互输入认证信息
atlas login

# 第3步：将现有数据库的schema设置为基线（baseline）
# 这是版本化迁移的第一步，用于标记数据库的初始状态
echo -e "${GREEN}第3步：设置已有数据库schema为baseline${NC}"

# 生成基线迁移文件，包含当前数据库结构
atlas migrate diff baseline --env single_db

# 提取基线版本号，用于后续的迁移应用
BASELINE_VER=$(ls migrations/single_db/*.sql | sed -E 's/.*\/([0-9]+).*$/\1/' | sort -n | head -1)
# 应用基线迁移，标记数据库当前状态为已知版本
atlas migrate apply --env single_db --baseline $BASELINE_VER

# 第4步：开发人员启动开发数据库并手动开发新的schema
# 模拟真实的开发场景，开发人员在开发环境中进行schema变更
echo -en "${GREEN}第4步：开发同学拉起开发数据库并手动开发新schema${NC}"; read

# 初始化开发数据库容器（运行在不同端口3307）
bash scripts/helpers/init_dev_db.sh

# 在开发环境中应用当前的数据库迁移
atlas migrate apply --env single_db_dev

# 手动执行SQL命令，将reviews表重命名为product_reviews
# 这模拟了开发人员在开发数据库中进行的实际schema变更
docker exec -i atlas-demo-dev mysql -u root -ppassword -e "ALTER TABLE example.reviews RENAME TO example.product_reviews;"

# 等待用户确认开发工作完成
echo -en "${GREEN}第4步：开发同学拉起开发数据库并手动开发新schema${NC}"; read

# 定义schema保存位置并清空现有结果
SCHEMA_SAVE_LOCATION=schema/definition/single_db/1_rename_reviews_table
rm -rf $SCHEMA_SAVE_LOCATION
# 检查开发数据库的当前schema，并将其保存到指定位置
# 这一步将开发环境的变更固化为schema定义文件
atlas schema inspect --env single_db_dev --format "{{ sql . | split | write \"$SCHEMA_SAVE_LOCATION\" }}"

# 第5步：自动化创建schema迁移DDL
# 开发同学通过Atlas根据schema差异自动生成迁移脚本
echo -en "${GREEN}第5步：自动化创建schema迁移DDL${NC}"; read

# 生成迁移脚本，比较开发环境与目标schema的差异
atlas migrate diff rename_reviews_table --env single_db_dev --to "file://$SCHEMA_SAVE_LOCATION"

# 第6步：审查生成的迁移DDL并执行lint检查
# 确保生成的迁移脚本符合规范且不会引入问题
# 这一步会在代码合并的CI流程中执行，避免不好的DDL脚本不会进入release
# 这里，我们假设我们的开发同学不自觉，完全没有审查自动生成的脚本
echo -en "${GREEN}第6步：确认生成的迁移DDL，并执行lint检查${NC}"; read

# 对最近的迁移执行lint检查，验证其正确性
atlas migrate lint --env single_db --latest 1

# 这里，我们能看到有数据表被drop，这不太对劲，我们就能发现自动生成SQL的问题，避免生产问题

# 第7步：手动修改迁移DDL并重新执行lint检查
# 在实际项目中，可能需要手动优化自动生成的迁移脚本
echo -en "${GREEN}第7步：手动修改迁移DDL，并执行lint检查${NC}"; read

# 定位包含rename_reviews_table的迁移文件
TARGET_SQL_FILE=$(ls migrations/single_db/*.sql | grep rename_reviews_table)
# 使用预定义的SQL脚本替换自动生成的迁移文件，模拟开发同学的修订
cp schema/ddl/rename_reviews_table.sql $TARGET_SQL_FILE

# 重新计算迁移文件的哈希值，否则这种“篡改”不被Atlas工具承认，会在数据库操作时被阻拦
atlas migrate hash --env single_db
# 再次执行lint检查，验证手动修改后的迁移脚本
atlas migrate lint --env single_db --latest 1

# 这里，我们能看到Atlas识别到了数据表重命名可能带来应用上的向前兼容问题，并提醒我们注意

# 第8步：清空开发数据库并测试迁移DDL
# 在应用到生产环境之前，先在开发环境中测试迁移脚本
echo -en "${GREEN}第8步：清空开发数据库，测试迁移DDL${NC}"; read

# 清空开发数据库中的所有表
atlas schema clean --env single_db_dev

# 在开发环境中重现baseline
NUM_MIGRATIONS=$(ls migrations/single_db/*.sql | wc -l | tr -d ' ')
NUM_NEW_MIGRATIONS=1
atlas migrate apply --env single_db_dev $((NUM_MIGRATIONS - NUM_NEW_MIGRATIONS))

# 在开发环境中应用迁移脚本
atlas migrate apply --env single_db_dev

# 第9步：确认开发数据库schema与理想schema一致
# 验证迁移脚本是否正确地将数据库转换为目标状态
# 这一步也会在CI流程中体现，作为merge的依据之一
echo -en "${GREEN}第9步：确认开发数据库schema与理想schema一致${NC}"; read

# 比较开发数据库当前schema与目标schema的差异
atlas schema diff --env single_db_dev --from env://url --to "file://$SCHEMA_SAVE_LOCATION"

# 第10步：在生产环境执行迁移DDL
# 经过充分测试后，将迁移应用到生产环境
echo -en "${GREEN}第10步：在生产环境执行迁移DDL${NC}"; read

# 在生产环境中应用迁移脚本
atlas migrate apply --env single_db

# 第11步：生产环境验收
# 最后验证生产环境的schema是否与预期一致
echo -en "${GREEN}第11步：生产环境执行验收${NC}"; read

# 比较生产数据库当前schema与目标schema的差异
atlas schema diff --env single_db --from env://url --to "file://$SCHEMA_SAVE_LOCATION"
