-- atlas:import ../example.sql
-- atlas:import users.sql

-- create "audit_log" table
CREATE TABLE `example`.`audit_log` (
  `log_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `table_name` varchar(50) NOT NULL,
  `record_id` bigint unsigned NOT NULL,
  `action` enum('INSERT','UPDATE','DELETE') NOT NULL,
  `old_values` json NULL,
  `new_values` json NULL,
  `changed_by_user_id` bigint unsigned NULL,
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  INDEX `idx_changed_at` (`changed_at`),
  INDEX `idx_changed_by` (`changed_by_user_id`),
  INDEX `idx_table_action` (`table_name`, `action`),
  CONSTRAINT `audit_log_ibfk_1` FOREIGN KEY (`changed_by_user_id`) REFERENCES `example`.`users` (`user_id`) ON UPDATE CASCADE ON DELETE SET NULL
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
