-- check for duplicates
WITH CTE AS
(
select *, ROW_NUMBER() OVER(PARTITION BY transaction_id order by transaction_id) as row_num from dbo.sales
)
select * 
FROM CTE 
WHERE row_num > 1
/*
transaction_id
1001
1004
1030
1074
*/

-- delete duplicates records
WITH CTE AS
(
select *, ROW_NUMBER() OVER(PARTITION BY transaction_id order by transaction_id) as row_num from dbo.sales
)
delete 
FROM CTE 
WHERE row_num > 1

-- check for Null value
select * from dbo.sales 
where transaction_id is null
or customer_id is null

------------------------------------------------------------------------------------
DECLARE @SQL NVARCHAR(MAX) = '';
SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;

------------------------------------------------------------------------------------
-- treating Null values

select distinct category from dbo.sales

--- catagory Unknown

update dbo.sales
SET category ='Unknown'
where category is null

-------------------------------- customer_address

select distinct customer_address from dbo.sales

update dbo.sales
SET customer_address ='Not Available'
where customer_address is null

--------------------------------------
select distinct customer_id from dbo.sales

select distinct payment_method from dbo.sales

update dbo.sales
SET payment_method ='Credit Card'
where payment_method IN ('credit','CC','creditcard')

update dbo.sales
SET payment_method = 'Cash'
where payment_method IS NULL

select distinct payment_method from dbo.sales

----------------delivery_status

select distinct delivery_status from dbo.sales

update dbo.sales
SET delivery_status = 'Not Delivered'
where delivery_status IS NULL


------------------------------

select distinct price from dbo.sales
------2510.76 avg/MEAN
select avg(price) from dbo.sales

---------------------mod

select price, count(*) from sales
group by price
order by max(price) asc

----median  2530.75
select distinct PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY PRICE) OVER() AS MEDIAN FROM SALES

select category, AVG(price)
from sales
group by category


/*
category	(No column name)
Clothing	2539.2781871345
Toys	2235.47168918919
Unknown	2511.41640522876
Electronics	2663.92784090909
Books	2574.45734693878
Home & Kitchen	2507.05837837838
*/


--Clothing	2539.2781871345
select  * from dbo.sales
where category = 'Clothing' and price is null


update dbo.sales
SET price = 2539.27
where category = 'Clothing' and price is null

--Toys	2235.47
select  * from dbo.sales
where category = 'Toys' and price is null

update dbo.sales
SET price = 2235.47
where category = 'Toys' and price is null

--Electronics	2663.92

select  * from dbo.sales
where category = 'Electronics' and price is null

update dbo.sales
SET price = 2663.92
where category = 'Electronics' and price is null

--Books	2574.45
select  * from dbo.sales
where category = 'Books' and price is null

update dbo.sales
SET price = 2574.45
where category = 'Books' and price is null


select  * from dbo.sales
where category = 'Home & Kitchen' and price is null

update dbo.sales
SET price = 2507.05
where category = 'Home & Kitchen' and price is null

--Unknown	2511.41

update dbo.sales
SET price = 2511.41
where category = 'Unknown' and price is null


select * from dbo.sales where customer_name is null

update dbo.sales
set customer_name = 'User'
where customer_name is null

select * from dbo.sales 

----quantity handling negative values
select * from dbo.sales
where quantity < 0

update dbo.sales
set quantity = ABS(quantity)
where quantity < 0 

-- total_amount
select * from dbo.sales
where total_amount like '-%'

UPDATE sales 
SET total_amount= price*quantity
WHERE total_amount IS NULL OR total_amount <> price*quantity


 --Fixing Inconsistent Date Formats & Invalid Dates
 select * from dbo.sales  where purchase_date = '2024-02-30'

update DBO.sales 
SET purchase_date = 
	CASE
		WHEN TRY_CONVERT(DATE,purchase_date, 103) IS NOT NULL
		THEN TRY_CONVERT(DATE,purchase_date, 103) 
	ELSE null
END;

select email from dbo.sales where email not like '%@%'

update sales
set  email= null
where email not like '%@%'

--- check data type of column

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales'
