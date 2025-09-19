-- atlas:import ../example.sql
-- atlas:import ../tables/order_items.sql

-- create trigger "update_stock_after_order_item"
CREATE TRIGGER `example`.`update_stock_after_order_item` AFTER INSERT ON `example`.`order_items` FOR EACH ROW BEGIN
    UPDATE products 
    SET stock_quantity = stock_quantity - NEW.quantity 
    WHERE product_id = NEW.product_id;
END;
