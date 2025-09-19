-- Add new schema named "example"
CREATE DATABASE `example`;
-- Create "users" table
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
-- Create "audit_log" table
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
-- Create "orders" table
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
-- Create "categories" table
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
-- Create "products" table
CREATE TABLE `example`.`products` (
  `product_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `description` text NULL,
  `sku` varchar(50) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `cost` decimal(10,2) NOT NULL,
  `stock_quantity` int NOT NULL DEFAULT 0,
  `category_id` bigint unsigned NOT NULL,
  `is_active` bool NULL DEFAULT 1,
  `weight` decimal(8,2) NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  INDEX `idx_category_active` (`category_id`, `is_active`),
  INDEX `idx_price_stock` (`price`, `stock_quantity`),
  INDEX `idx_sku` (`sku`),
  UNIQUE INDEX `sku` (`sku`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `example`.`categories` (`category_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `products_chk_1` CHECK (`price` >= 0),
  CONSTRAINT `products_chk_2` CHECK (`cost` >= 0),
  CONSTRAINT `products_chk_3` CHECK (`stock_quantity` >= 0)
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Create "order_items" table
CREATE TABLE `example`.`order_items` (
  `order_item_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `discount` decimal(5,2) NULL DEFAULT 0.00,
  `subtotal` decimal(10,2) AS ((`quantity` * `unit_price`) * (1 - (`discount` / 100))) STORED NULL,
  PRIMARY KEY (`order_item_id`),
  INDEX `idx_order_product` (`order_id`, `product_id`),
  INDEX `product_id` (`product_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `example`.`orders` (`order_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `example`.`products` (`product_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `order_items_chk_1` CHECK (`quantity` > 0),
  CONSTRAINT `order_items_chk_2` CHECK (`unit_price` >= 0),
  CONSTRAINT `order_items_chk_3` CHECK ((`discount` >= 0) and (`discount` <= 100))
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Create "attributes" table
CREATE TABLE `example`.`attributes` (
  `attribute_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `data_type` enum('string','integer','decimal','boolean','date') NOT NULL,
  PRIMARY KEY (`attribute_id`),
  UNIQUE INDEX `uk_name` (`name`)
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Create "product_attributes" table
CREATE TABLE `example`.`product_attributes` (
  `product_id` bigint unsigned NOT NULL,
  `attribute_id` bigint unsigned NOT NULL,
  `attribute_value` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`, `attribute_id`),
  INDEX `idx_attribute_value` (`attribute_id`, `attribute_value` (50)),
  CONSTRAINT `product_attributes_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `example`.`products` (`product_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `product_attributes_ibfk_2` FOREIGN KEY (`attribute_id`) REFERENCES `example`.`attributes` (`attribute_id`) ON UPDATE CASCADE ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Create "reviews" table
CREATE TABLE `example`.`reviews` (
  `review_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `rating` int NOT NULL,
  `title` varchar(200) NOT NULL,
  `comment` text NULL,
  `is_approved` bool NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  INDEX `idx_approved_created` (`is_approved`, `created_at`),
  INDEX `idx_product_rating` (`product_id`, `rating`),
  UNIQUE INDEX `uk_user_product` (`user_id`, `product_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `example`.`products` (`product_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `example`.`users` (`user_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK (`rating` between 1 and 5)
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
