-- atlas:import ../example.sql
-- atlas:import ../tables/order_items.sql

-- create trigger "update_stock_on_order_item_update"
CREATE TRIGGER `example`.`update_stock_on_order_item_update` AFTER UPDATE ON `example`.`order_items` FOR EACH ROW BEGIN
    IF OLD.quantity != NEW.quantity THEN
        UPDATE products 
        SET stock_quantity = stock_quantity - (NEW.quantity - OLD.quantity) 
        WHERE product_id = NEW.product_id;
    END IF;
END;
