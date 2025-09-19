# Overview

[Atlas](https://atlasgo.io/) 是一个开源的数据库Schema管理工具，它将数据库Schema视为代码。开发者可以使用Atlas HCL或者SQL DDL来定义数据库的期望状态。Atlas 会根据这个期望状态，自动计算出需要执行的迁移脚本，从而让数据库Schema与代码库中的定义保持一致。

Atlas 提供两种主要的方式来应用Schema变更：

- 声明式迁移 (Declarative Migrations)：这是 Atlas 的核心优势。你只需定义最终的Schema状态，Atlas 会自动生成并执行必要的迁移脚本。声明式迁移的整体流程类似Terraform。

- 版本化迁移 (Versioned Migrations)：这种方式更接近传统的迁移工具，你需要手动编写一系列带版本号的SQL脚本。Atlas 会追踪哪些脚本已经被执行，确保它们按顺序应用。Atlas 同样可以帮助你自动生成这些版本化脚本，这在需要精细控制迁移过程时非常有用。

对于风险较低、复杂度较低的项目，声明式迁移的便利性是非常有优势的，而在较为复杂的生产项目，版本化迁移则提供了更高的可控性。

同时，Atlas 能够与CI/CD流水线无缝集成：

- 在代码合并到主分支之前，你可以让CI系统运行 Atlas，对数据库Schema变更进行静态分析。例如，Atlas 可以检查一个 DROP COLUMN 操作是否会导致数据丢失，或者一个 ALTER TABLE 操作是否会锁定大表，从而在部署之前就发现潜在的风险。

- 在部署阶段，CI/CD流水线可以自动执行 Atlas 生成的迁移脚本，确保数据库结构随着应用程序代码的更新而同步演进。

# 功能

## atlas（cli工具）功能

- 查看/导出数据库schema
- 比较数据库schema（支持DDL-DDL，DDL-数据库，数据库-数据库的相互比较）
- 声明式的数据库schema迁移
- 版本化的数据库schema迁移
    - 迁移脚本审查
    - git协作避免冲突
    - 自动化回滚
- 支持一个数据库instance下多个db的管理，也支持一个数据库instance下单个db的管理

## atlas cloud功能

- 线上数据库监控（检测非atlas管理的变更）
- schema可视化
- 无需临时数据库
- 云上CI/CD集成

## 付费版vs免费版

| 功能 | 免费版 | Pro（9$/mo） |
|-----|-------|--------------|
| Atlas Cloud | 无 | 有，单独计费 |
| [数据库功能](https://atlasgo.io/features#database-features) | 部分 | 全部 |
| [数据库支持](https://atlasgo.io/features#database-support) | 部分 | 全部 |
| [迁移脚本检查](https://atlasgo.io/features#linting-rules) | 部分 | 全部 |
| [迁移脚本checkpoint](https://atlasgo.io/versioned/checkpoint) | 不支持 | 支持 |
| [组合schema](https://atlasgo.io/atlas-schema/projects#data-source-composite_schema) | 不支持 | 支持 |

# Demo
```bash
# 查看/导出真实数据库schema
bash scripts/1_inspect_schema.sh

# 声明式的数据库schema迁移
bash scripts/2_declarative_migration.sh

# 简单的版本化数据库schema迁移
bash scripts/3_versioned_migration_simple_example.sh

# 版本化数据库schema迁移的一个比较真实的mock场景
bash scripts/4_versioned_migration_realistic_workflow.sh

# 停止临时docker数据库
bash scripts/5_cleanup_dbs.sh
```