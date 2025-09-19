-- atlas:import ../example.sql
-- atlas:import users.sql

-- create "orders" table
CREATE TABLE `example`.`orders` (
  `order_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `order_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','processing','shipped','delivered','cancelled') NOT NULL DEFAULT "pending",
  `total_amount` decimal(10,2) NOT NULL,
  `shipping_address` json NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `notes` text NULL,
  PRIMARY KEY (`order_id`),
  INDEX `idx_order_date` (`order_date`),
  INDEX `idx_total_amount` (`total_amount`),
  INDEX `idx_user_status` (`user_id`, `status`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `example`.`users` (`user_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `orders_chk_1` CHECK (`total_amount` >= 0)
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
