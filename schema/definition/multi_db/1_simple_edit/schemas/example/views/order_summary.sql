-- atlas:import ../example.sql
-- atlas:import ../tables/order_items.sql
-- atlas:import ../tables/orders.sql
-- atlas:import ../tables/users.sql

-- create "order_summary" view
CREATE VIEW `example`.`order_summary` (
  `order_id`,
  `user_id`,
  `username`,
  `total_amount`,
  `status`,
  `item_count`,
  `calculated_total`
) AS select `o`.`order_id` AS `order_id`,`o`.`user_id` AS `user_id`,`u`.`username` AS `username`,`o`.`total_amount` AS `total_amount`,`o`.`status` AS `status`,count(`oi`.`order_item_id`) AS `item_count`,sum(`oi`.`subtotal`) AS `calculated_total` from ((`example`.`orders` `o` join `example`.`users` `u` on((`o`.`user_id` = `u`.`user_id`))) join `example`.`order_items` `oi` on((`o`.`order_id` = `oi`.`order_id`))) group by `o`.`order_id`,`o`.`user_id`,`u`.`username`,`o`.`total_amount`,`o`.`status` having (`calculated_total` = `o`.`total_amount`);
