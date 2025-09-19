// ======== 变量定义 ========

variable "version" {
  // 用于迁移和检查的版本
  type    = string
  default = "0_init"
}

variable "db_pass" {
  // 数据库连接的密码
  type    = string
  default = "password"
}

variable "db_name" {
  // 要连接的数据库名称
  type    = string
  default = "example"
}

// ======== 环境定义 ========

// 多数据库设置的“生产”环境配置
env "multi_db" {
  // schema的生命代码存储位置
  src = "file://schema/definition/multi_db/${var.version}"

  // 要管理的数据库URL
  url = "mysql://root:${var.db_pass}@localhost:3306"

  // 开发数据库的URL，用于差异比较和验证
  // 参见: https://atlasgo.io/concepts/dev-database
  dev = "docker://mysql/8"

  migration {
    // 版本化迁移文件目录的位置
    dir = "file://migrations/multi_db"
  }

  // 默认的格式化定义
  format {
    schema {
      inspect = "{{ sql . \"  \" }}"
    }
  }
}

// 单数据库设置的“生产”环境配置
env "single_db" {
  // schema的生命代码存储位置
  src = "file://schema/definition/single_db/${var.version}"

  // 要管理的数据库URL
  url = "mysql://root:${var.db_pass}@localhost:3306/${var.db_name}"

  // 开发数据库的URL，用于差异比较和验证
  // 参见: https://atlasgo.io/concepts/dev-database
  dev = "docker://mysql/8/${var.db_name}"

  migration {
    // 版本化迁移文件目录的位置
    dir = "file://migrations/single_db"
  }

  // 默认的格式化定义
  format {
    schema {
      inspect = "{{ sql . \"  \" }}"
    }
  }
}

// 单数据库设置的“开发/测试”环境配置
env "single_db_dev" {
  // schema的生命代码存储位置
  src = "file://schema/definition/single_db/${var.version}"

  // 要管理的数据库URL (使用3307端口以区分开发环境)
  url = "mysql://root:${var.db_pass}@localhost:3307/${var.db_name}"

  // 开发数据库的URL，用于差异比较和验证
  // 参见: https://atlasgo.io/concepts/dev-database
  dev = "docker://mysql/8/${var.db_name}"

  migration {
    // 版本化迁移文件目录的位置
    dir = "file://migrations/single_db"
  }

  // 默认的格式化定义
  format {
    schema {
      inspect = "{{ sql . \"  \" }}"
    }
  }
}

// ======== Linting规则 ========

lint {
  // 检测到非线性迁移时是否报错
  non_linear {
    error = true
  }
}
