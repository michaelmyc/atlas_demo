-- atlas:import ../example.sql

-- create "categories" table
CREATE TABLE `example`.`categories` (
  `category_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text NULL,
  `parent_category_id` bigint unsigned NULL,
  `level` int NOT NULL DEFAULT 1,
  `is_visible` bool NULL DEFAULT 1,
  `sort_order` int NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  INDEX `idx_level_sort` (`level`, `sort_order`),
  INDEX `idx_parent_visible` (`parent_category_id`, `is_visible`),
  UNIQUE INDEX `uk_name_parent` (`name`, `parent_category_id`),
  CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `example`.`categories` (`category_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `categories_chk_1` CHECK (`level` > 0)
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
