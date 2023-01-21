
--danny dinner problem
--8 weekSQLchallenge CASE STUDY 1

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
select sales.customer_id,count(distinct sales.order_date) as no_days 
from Sqlchallenge..sales
group by customer_id)

select *
from result
order by no_days desc


-- 3. What was the first item from the menu purchased by each customer?

with result as(
select sales.customer_id as c_id, menu.product_name as p_name,
ROW_NUMBER() over (partition by sales.customer_id order by sales.order_date, sales.product_id) as rnk
from Sqlchallenge..sales 
join Sqlchallenge..menu on sales.product_id=menu.product_id)

select c_id,p_name
from result
where rnk=1

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
RANK()over(partition by customer_id order by count(menu.product_id) desc) as rnk
from Sqlchallenge..sales
join Sqlchallenge..menu on sales.product_id=menu.product_id
group by sales.customer_id, menu.product_name
)

select *
from result
where rnk=1

-- 6. Which item was purchased first by the customer after they became a member?

with result as(
select members.customer_id, menu.product_name,
rank() over (partition by members.customer_id order by sales.order_date) as rnk
from Sqlchallenge..members
join Sqlchallenge..sales on sales.customer_id=members.customer_id
join Sqlchallenge..menu on sales.product_id=menu.product_id
where sales.order_date >= members.join_date
)

select customer_id,product_name
from result
where rnk =1

-- 7. Which item was purchased just before the customer became a member?

with result as(
select members.customer_id, menu.product_name,
rank() over (partition by members.customer_id order by sales.order_date desc) as rnk
from Sqlchallenge..members
join Sqlchallenge..sales on sales.customer_id=members.customer_id
join Sqlchallenge..menu on sales.product_id=menu.product_id
where sales.order_date < members.join_date
)

select customer_id,product_name,rnk
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

select *
from result
order by customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with result as(
select members.customer_id,
SUM(case when menu.product_name = 'sushi' then menu.price*20 else menu.price*10 end) as total_points
from Sqlchallenge..members
join Sqlchallenge..sales on sales.customer_id=members.customer_id
join Sqlchallenge..menu on sales.product_id=menu.product_id
group by members.customer_id
)

select * 
from result


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- - how many points do customer A and B have at the end of January?

with result as(
select members.customer_id,
SUM(case 
        when sales.order_date < members.join_date then 
             case when menu.product_name='sushi' then menu.price*20 else menu.price*10 end
	    when sales.order_date > (members.join_date + 6) then
		     case when menu.product_name='sushi' then  menu.price*20 else menu.price*10 end 
	else menu.price*20 end ) as total_points

from Sqlchallenge..members
join Sqlchallenge..sales on sales.customer_id=members.customer_id
join Sqlchallenge..menu on sales.product_id=menu.product_id
where sales.order_date <= 2021-01-31
group by members.customer_id
)

select *
from result 
order by members.customer_id;