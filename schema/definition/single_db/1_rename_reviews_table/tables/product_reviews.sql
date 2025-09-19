-- atlas:import products.sql
-- atlas:import users.sql

-- create "product_reviews" table
CREATE TABLE `product_reviews` (
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
  CONSTRAINT `product_reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `product_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `product_reviews_chk_1` CHECK (`rating` between 1 and 5)
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
