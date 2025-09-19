-- Modify "users" table
ALTER TABLE `example`.`users` ADD COLUMN `alias` varchar(100) NOT NULL AFTER `username`;
