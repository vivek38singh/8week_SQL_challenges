
--danny dinner problem
--8 weekSQLchallenge CASE STUDY 1

--Sqlchallenge - is our Database name
--so Sqlchallenge..menu means extracting the table name menu from Sqlchallenge databse


-------------------------------------------------------------------------
Select * from Sqlchallenge..members
Select * from Sqlchallenge..sales
Select * from Sqlchallenge..menu

-- 1. What is the total amount each customer spent at the restaurant?

with result as(
select sales.customer_id, sum(menu.price) as total_spent
from Sqlchallenge..sales
join Sqlchallenge..menu on sales.product_id=menu.product_id
group by sales.customer_id)

select * from result
order by total_spent desc;

-- 2. How many days has each customer visited the restaurant?

with result as(
select sales.customer_id,count(distinct sales.order_date) as no_of_visited_days 
from Sqlchallenge..sales
group by customer_id)

select *
from result
order by no_of_visited_days desc


-- 3. What was the first item from the menu purchased by each customer?

with result as(
select distinct sales.customer_id as c_id, menu.product_name as p_name,
dense_rank() over (partition by sales.customer_id order by sales.order_date) as rnk
from Sqlchallenge..sales 
inner join Sqlchallenge..menu on sales.product_id=menu.product_id)

select c_id,p_name
from result
where rnk=1
order by 1,2

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

with result as(
select menu.product_name, COUNT(sales.product_id) as no_purchase
from Sqlchallenge..menu
join Sqlchallenge..sales on menu.product_id=sales.product_id
group by menu.product_name
)

select top 1 * 
from  result
order by no_purchase desc

-- 5. Which item was the most popular for each customer?

with result as(
select sales.customer_id, menu.product_name,
COUNT(menu.product_name) as order_count,
RANK()over(partition by customer_id order by count(menu.product_id) desc) as rnk
from Sqlchallenge..sales
join Sqlchallenge..menu on sales.product_id=menu.product_id
group by sales.customer_id, menu.product_name
)

select customer_id, product_name, order_count
from result
where rnk=1
order by 1,2

-- 6. Which item was purchased first by the customer after they became a member?

with result as(
select members.customer_id, menu.product_name,sales.order_date,
dense_rank() over (partition by members.customer_id order by sales.order_date) as rnk
from Sqlchallenge..members
join Sqlchallenge..sales on sales.customer_id=members.customer_id
join Sqlchallenge..menu on sales.product_id=menu.product_id
where sales.order_date >= members.join_date
)

select customer_id,product_name,order_date
from result
where rnk =1

-- 7. Which item was purchased just before the customer became a member?

with result as(
select members.customer_id, menu.product_name,sales.order_date,
rank() over (partition by members.customer_id order by sales.order_date desc) as rnk
from Sqlchallenge..members
join Sqlchallenge..sales on sales.customer_id=members.customer_id
join Sqlchallenge..menu on sales.product_id=menu.product_id
where sales.order_date < members.join_date
)

select customer_id,product_name,order_date
from result
where rnk =1

-- 8. What is the total items and amount spent for each member before they became a member?

with result as(
select members.customer_id,
count(menu.product_id) as total_items,
sum(menu.price) as total_spent
from Sqlchallenge..members
join Sqlchallenge..sales on sales.customer_id=members.customer_id
join Sqlchallenge..menu on sales.product_id=menu.product_id
where sales.order_date < members.join_date
group by members.customer_id
)

select customer_id,total_items,total_spent
from result
order by customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with result as(
select members.customer_id,
SUM(case 
        when menu.product_name = 'sushi' then menu.price*20 
		else menu.price*10 end) as total_points
from Sqlchallenge..members
join Sqlchallenge..sales on sales.customer_id=members.customer_id
join Sqlchallenge..menu on sales.product_id=menu.product_id
group by members.customer_id
)

select customer_id,total_points
from result


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?
with result_date as(
	select *, 
		DATEADD(DAY, 6, join_date) as valid_date, 
		EOMONTH('2021-01-1') as last_date
	from Sqlchallenge..members
)

select
	sales.customer_id,
	sum(CASE
		WHEN sales.product_id = 1 
		     THEN price*20
		WHEN sales.order_date between result_date.join_date and result_date.valid_date 
		     THEN price*20
		ELSE price*10 
	END) as total_points
from
	result_date,
	Sqlchallenge..sales,
	Sqlchallenge..menu
where
	result_date.customer_id = sales.customer_id
	AND
	menu.product_id = sales.product_id
	AND
	sales.order_date <= result_date.last_date
group by sales.customer_id;

