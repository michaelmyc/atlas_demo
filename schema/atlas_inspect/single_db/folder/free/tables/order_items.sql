-- atlas:import orders.sql
-- atlas:import products.sql

-- create "order_items" table
CREATE TABLE `order_items` (
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
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `order_items_chk_1` CHECK (`quantity` > 0),
  CONSTRAINT `order_items_chk_2` CHECK (`unit_price` >= 0),
  CONSTRAINT `order_items_chk_3` CHECK ((`discount` >= 0) and (`discount` <= 100))
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
