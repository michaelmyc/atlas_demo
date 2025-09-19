-- atlas:import ../example.sql

-- create "users" table
CREATE TABLE `example`.`users` (
  `user_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `date_of_birth` date NOT NULL,
  `is_active` bool NULL DEFAULT 1,
  `role` enum('admin','user','moderator') NOT NULL DEFAULT "user",
  `parent_user_id` bigint unsigned NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `email` (`email`),
  INDEX `idx_active_role` (`is_active`, `role`),
  INDEX `idx_email` (`email`),
  INDEX `idx_username` (`username`),
  INDEX `parent_user_id` (`parent_user_id`),
  UNIQUE INDEX `username` (`username`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`parent_user_id`) REFERENCES `example`.`users` (`user_id`) ON UPDATE CASCADE ON DELETE SET NULL
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
