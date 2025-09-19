-- create "attributes" table
CREATE TABLE `attributes` (
  `attribute_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `data_type` enum('string','integer','decimal','boolean','date') NOT NULL,
  PRIMARY KEY (`attribute_id`),
  UNIQUE INDEX `uk_name` (`name`)
) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
