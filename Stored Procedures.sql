--- STORED PROCEDURES

use BikeStores;


--- SIMPLE STORED PROCEDURE
create procedure ListProd
as
begin
select * from production.products order by product_name
end

exec ListProd


--- USING PARAMETER
create procedure findProd(@lp as decimal)
as
begin
select product_name,list_price from production.products where list_price>@lp order by product_name
end

exec findProd 1000


--- EXERCISE 1

create procedure usp_GetProductsByCategory(@Category_ID as int)
as
begin
select p.product_name,b.brand_name,p.list_price from production.products p inner join production.brands b on p.brand_id= b.brand_id where p.category_id = @Category_ID
end

exec usp_GetProductsByCategory 6


--- EXERCISE 2

create procedure usp_AddCustomernew(@fn as varchar(255),@ln as varchar(255),@phone as varchar(255),@email as varchar(255),@street as varchar(255),@city as varchar(255),@state as varchar(255),@zip_code as varchar(255))
as
begin
insert into sales.customers( first_name, last_name, phone, email,street, city, state, zip_code)VALUES (@fn, @ln, @Phone, @Email,
        @Street, @City, @State, @zip_code)
end

EXEC usp_AddCustomernew 'Ashmi', 'Stalin', '9876543210', 'ashmi@email.com','123 Road', 'Chennai', 'TN', '60000'


SELECT * FROM sales.customers WHERE LOWER(first_name) = 'ashmi';


--- EXERCISE 3


create procedure usp_updateProductStock(@sid as int,@pid as int, @quantity as int)
as
begin
update production.stocks set quantity=@quantity where store_id=@sid and product_id=@pid
end

exec usp_updateProductStock 1,10,40

Select * from production.stocks


--- EXERCISE 4

create procedure usp_GetOrderDetails(@Order_id as int) 
as
begin
select o.order_date,c.first_name+' '+c.last_name as customer_name, s.store_id,p.product_name, oi.quantity, oi.list_price
from sales.orders o
join sales.customers c on o.customer_id = c.customer_id
join sales.stores s on o.store_id=s.store_id
join sales.order_items oi on o.order_id=oi.order_id
join production.products p on oi.product_id= p.product_id

where o.order_id=@Order_id 
end

exec usp_GetOrderDetails 2
