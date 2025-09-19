-- atlas:import categories.sql

-- create "products" table
CREATE TABLE `products` (
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
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `products_chk_1` CHECK (`price` >= 0),
  CONSTRAINT `products_chk_2` CHECK (`cost` >= 0),
  CONSTRAINT `products_chk_3` CHECK (`stock_quantity` >= 0)
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
