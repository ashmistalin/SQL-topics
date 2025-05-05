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


--- EXERCISE 5 

CREATE PROCEDURE usp_GetTotalSalesByStore
    @StartDate as DATE,
    @EndDate as DATE
AS
BEGIN
    SELECT 
        s.store_name,
        SUM(oi.quantity * oi.list_price) AS total_sales
    FROM sales.orders o
    JOIN sales.stores s ON o.store_id = s.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN @StartDate AND @EndDate
    GROUP BY s.store_name;
END

Select * from sales.orders

exec usp_GetTotalSalesByStore @StartDate = '2016-01-01', @EndDate = '2016-05-05';



---- FUNCTIONS 


--- SCALAR FUNCTIONS 
create function sales.simple(@qty int,@price decimal(10,2),@discount decimal(4,2))
returns decimal(10,2)
as
begin
return @qty*@price*(1-@discount)
end

select sales.simple(10,700,0.5) as sales_done

--- using this function to get the net_price after the discount for each order id 

select order_id, SUM(sales.simple(quantity,list_price,discount)) as net_price from sales.order_items group by order_id order by order_id\


--- TABLE - VALUED FUCNTIONS 

create function production.pro_yr(@yr int)
returns table
as
return 
select product_name,model_year,list_price from production.products
where model_year=@yr

select * from pro_yr(2016)


--- EXERCISE 1

create function sales.fn_CalculateDiscountedPrice(@list_price decimal(10,2),@discount_percent decimal(4,2))
returns decimal(10,2)
as
begin
return @list_price*(1- @discount_percent/100.00) 
end

select sales.fn_CalculateDiscountedPrice(700,0.5) as Discounted_price


--- EXERCISE 2

create function sales.fn_GetFullCustomerName(@fn varchar(255),@ln varchar(255))
returns varchar(255)
as
begin
return '"'+@fn+','+@ln+'"'
end

select sales.fn_GetFullCustomerName('Ashmi','Stalin') as CustomerFullName


--- EXERCISE 3

create function sales.fn_CalculateTotalOrderAmount(@Order_id int)
returns decimal(10,2)
as
begin
return (select sum(quantity*list_price) from sales.order_items where order_id = @Order_id)
end

select sales.fn_CalculateTotalOrderAmount(10) 


--- EXERCISE 4

create function production.fn_GetProductsByBrand(@brand_id int)
returns table
as
return (select p.product_id,p.product_name,p.category_id,p.list_price from production.products p join production.brands b on b.brand_id = p.brand_id where p.brand_id=@brand_id)

select * from production.fn_GetProductsByBrand(9)

select * from production.brands


--- EXERCISE 5

create function sales.fn_GetOrdersByCustomer(@Cust_id int)
returns table
as
return (Select order_id,order_date,store_id,staff_id from sales.orders where customer_id=@Cust_id)

create function sales.fn_GetOrdersByCustomerCount(@Cust_id int)
returns table
as
return (Select count(order_id) as Order_count from sales.orders where customer_id=@Cust_id)

select * from sales.fn_GetOrdersByCustomer(1)

select * from sales.fn_GetOrdersByCustomerCount(1)


select * from sales.orders



--- EXERCISE 6

CREATE FUNCTION sales.fn_GetStockByStore (@store_id INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity
    FROM 
        production.products p
    JOIN 
        sales.order_items oi ON p.product_id = oi.product_id
    JOIN 
        sales.orders o ON oi.order_id = o.order_id
    WHERE 
        o.store_id = @store_id
    GROUP BY 
        p.product_id, p.product_name
);


SELECT * 
FROM sales.fn_GetStockByStore(1);
