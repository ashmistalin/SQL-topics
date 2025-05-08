--- VIEWS

--- Simple view for select command


CREATE TABLE production.product_audits(  product_id INT NOT NULL, product_name VARCHAR(255) NOT NULL, brand_id INT NOT NULL, updated_at DATETIME NOT NULL, operation CHAR(3) NOT NULL, CHECK(operation = 'INS' or operation='DEL') );


create table sales.order_log (log_id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-increment ID
    order_id INT,
    order_date DATE,
    customer_id INT,
    log_timestamp DATETIME)

use BikeStores
create view prod_info
as
select product_name,brand_name,list_price from production.products p inner join production.brands b on p.brand_id =b.brand_id 

select * from prod_info


--- EXERCISE 1

create view vw_ProductDetails
as
select p.product_name,c.category_name,b.brand_name,p.list_price from production.products p 
join production.brands b on p.brand_id =b.brand_id 
join production.categories c on p.category_id=c.category_id

select * from vw_ProductDetails


--- EXERCISE 2

create view vw_CustomerOrder
as
select o.order_id,o.order_date, c.first_name+' '+c.last_name as Customer_name, s.store_name, oi.quantity from sales.orders o 
join sales.customers c on o.customer_id = c.customer_id
join sales.order_items oi on o.order_id = oi.order_id
join sales.stores s on o.store_id=s.store_id

select * from vw_CustomerOrder


--- EXERCISE 3
create view vw_StoreStockLevels
as
Select s.store_name, p.product_name,st.quantity from production.stocks st 
join production.products p on st.product_id=p.product_id
join sales.stores s on st.store_id = s.store_id

select * from vw_StoreStockLevels


--- EXERCISE 4

create view vw_TopSellingProducts
as
Select p.product_name,SUM(oi.quantity) as TotalQuantitySold,SUM(oi.list_price * oi.quantity) as Total_sales_amount from production.products p join sales.order_items oi on p.product_id=oi.product_id group by product_name

Select * from vw_TopSellingProducts  order by TotalQuantitySold desc


--- EXERCISE 5
create view vw_OrdersSummary
as
select o.order_date,
count(o.order_id) as Total_numOf_Orders,
SUM(oi.quantity) as TotalQuantitySold,
SUM(oi.list_price * oi.quantity) as Total_sales_amount
from sales.orders o
join sales.order_items oi on o.order_id = oi.order_id group by o.order_date

Select * from vw_OrdersSummary

--- TRIGGERS

--- SAMPLE 


/*create trigger [production].[trg_pro_audit]
on [production].[products]
after insert,delete
as
begin
insert into production.audits (pro_id,pro_name,brand_id,updtaed_at,operation)
select i.product_id,product_name,brand_id,GETDATE(),'INS' from inserted i union all
select d.product_id,product_name,brand_id,GETDATE(),'DEL' from deleted d
end*/

--- EXERCISE 1

create trigger trg_LogNew
on sales.orders
after insert
as
begin

insert into sales.order_log(order_id,order_date,customer_id,log_timestamp)
select i.order_id,i.order_date,i.customer_id, GETDATE() from inserted i

end

INSERT INTO sales.orders(customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
VALUES (2, 4, '20190101', '20190103', '20190103', 1, 2);

SELECT * FROM sales.order_log;


---- EXERCISE 2

--create table 
CREATE TABLE production.price_change_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    old_price DECIMAL(10, 2),
    new_price DECIMAL(10, 2),
    change_date DATETIME
);

create trigger trg_UpdateProductsNew
on production.products
after update
as
BEGIN
    INSERT INTO production.price_change_log (product_id, old_price, new_price, change_date)
    SELECT 
        d.product_id,         
        d.list_price AS old_price,
        i.list_price AS new_price, 
        GETDATE()
    FROM 
        inserted i
    JOIN 
        deleted d ON i.product_id = d.product_id
    WHERE 
        d.list_price <> i.list_price;  
END;

UPDATE production.products
SET list_price = 499.99
WHERE product_id = 101;

Select * from production.products

Select * from production.price_change_log


---- EXERCISE 3

/*create trigger trg_PreventDelete
on sales.customers
instead of delete
as
begin 
	if exists(select 1 from deleted d join sales.orders o on d.customer_id= o.customer_id)
	begin
		raiseerror('Customer has an order scheduled, Cannont delete',16,1);
		return;
	end
	else
	begin
		delete from sales.customers where customer_id in (select customer_id from deleted);
	end
end;*/


create trigger trg_PreventDelete
on sales.customers
instead of delete
as
begin 
    if exists(select 1 from deleted d 
              join sales.orders o on d.customer_id = o.customer_id)
    begin
        raiserror('Customer has an order scheduled, Cannot delete', 16, 1);
        return;
    end
    else
    begin
        delete from sales.customers 
        where customer_id in (select customer_id from deleted);
    end
end

DELETE FROM sales.customers WHERE customer_id = 259;
SELECT * FROM sales.customers
SELECT * FROM sales.orders


--- EXERCISE 4	
	
create trigger trg_PreventNegativeStock
on production.stocks
instead of update
as
begin
    -- Check if the update is trying to set the quantity below zero
    if exists (select 1 from inserted i
               where i.quantity < 0)
    begin
        -- Raise an error if stock quantity is set to below zero
        raiserror('Stock quantity cannot be reduced below zero.', 16, 1);
        return;
    end;

    -- If the quantity is valid, perform the update
    update production.stocks
    set quantity = i.quantity
    from inserted i
    where production.stocks.product_id = i.product_id;
end;






