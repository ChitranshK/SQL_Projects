create table brands(
	brand_id int not null,
	brand_name varchar(40),
	primary key (brand_id)
)

copy brands
from 'D:\DataScience\DataSets\BikeStore\brands.csv'
delimiter ','
csv header

select * from brands

create table categories(
	category_id int not null,
	category_name varchar(40),
	primary key (category_id)
)

copy categories
from 'D:\DataScience\DataSets\BikeStore\categories.csv'
delimiter ','
csv header

select * from categories

create table customers(
	customer_id int,
	first_name varchar (30),
	last_name varchar (30),
	phone varchar (20) ,
	email varchar (40),
	street varchar(30),
	city varchar (30) ,
	state varchar (10) ,
	zip_code int,
	primary key (customer_id)
)

copy customers
from 'D:\DataScience\DataSets\BikeStore\customers.csv'
delimiter ','
csv header

select * from customers

create table order_items(
	order_id int,
	item_id int,
	product_id int,
	quantity int,
	list_price decimal (10,2),
	discount decimal (10,2),
	primary key (item_id),
	foreign key (order_id)
)

create table stores(
	store_id int,
	store_name varchar(40),
	phone varchar (20) ,
	email varchar (40),
	street varchar(30),
	city varchar (30) ,
	state varchar (10) ,
	zip_code int,
	primary key (store_id)
)

copy stores
from 'D:\DataScience\DataSets\BikeStore\stores.csv'
delimiter ','
csv header

select * from stores

create table stocks(
	store_id int,
	product_id int,
	quantity int, 
	foreign key (product_id) references products(product_id),
	foreign key (store_id) references stores(store_id)
)

copy stocks
from 'D:\DataScience\DataSets\BikeStore\stocks.csv'
delimiter ','
csv header

select * from stocks

create table staffs(
	staff_id int,
	first_name	varchar (30),
	last_name varchar (30),
	email varchar (30),
	phone varchar (30),
	active	int,
	store_id int,
	manager_id int,
	primary key (staff_id),
	foreign key (store_id) references stores(store_id)
)

copy staffs
from 'D:\DataScience\DataSets\BikeStore\staffs.csv'
delimiter ','
csv header

select * from staffs

create table products(
	product_id int,
	product_name varchar(30),	
	brand_id int,
	category_id	int,
	model_year	int,
	list_price decimal(10,2),
	primary key (product_id),
	foreign key (brand_id) references brands(brand_id),
	foreign key (category_id) references categories(category_id)
)

alter table products
alter column product_name type varchar(70)

copy products
from 'D:\DataScience\DataSets\BikeStore\products.csv'
delimiter ','
csv header

select * from products

create table orders(
	order_id int,	
	customer_id	 int,
	order_status int,	
	order_date date,
	required_date date,
	shipped_date date,
	store_id int,
	staff_id int,
	primary key (order_id),
	foreign key (customer_id) references customers(customer_id),
	foreign key (store_id) references stores(store_id),
	foreign key (staff_id) references staffs(staff_id)
)


copy orders
from 'D:\DataScience\DataSets\BikeStore\orders.csv'
delimiter ','
csv header
null as 'NULL'

select * from orders

create table order_items(
	order_id int,	
	item_id	int,
	product_id	int,
	quantity int,
	list_price	decimal(10,2),
	discount decimal(10,2),
	foreign key (order_id) references orders(order_id)
)

copy order_items
from 'D:\DataScience\DataSets\BikeStore\order_items.csv'
delimiter ','
csv header
null as 'NULL'

select * from order_items;


-- Data Exploration:

-- 1. Find all the categories of Bikes available.
select category_name 
from categories;

-- 2. Find all the stores'name and email from state 'CA'.
select store_name,email 
from stores 
where state='CA';

-- 3. Find no. of orders in the year 2017.
select count(*) 
from orders 
where extract(year from order_date)=2017;

-- 4. Find all the bikes in the store of model year 2018.
select count(*) 
from products 
where model_year=2018;

-- 5. Find no. of customers from each state. 
select count(*) as no_of_customers,state 
from customers 
group by state;

-- 6. Find the total no. of bikes ordered in the month of April 2018.
select count(*) as no_of_bikes
from orders 
where order_date>='2018-04-01' and order_date<='2018-04-30';

-- 7. Find total no. of bikes in all stores of 'NY'.
select sum(quantity) as total_no_of_bikes 
from stores inner join stocks 
on stores.store_id=stocks.store_id 
where state='NY';

-- 8. Find the first name and last name of the customers who have bought bikes worth more than 7000.
select list_price,first_name,last_name 
from order_items inner join orders 
on order_items.order_id=orders.order_id 
inner join customers 
on customers.customer_id=orders.customer_id 
where list_price>7000 
order by list_price desc;

-- 9. Find the store which has sold highest no. of bikes in the year 2018.
select sum(quantity) as total_bikes_sold,store_name 
from stores inner join orders 
on stores.store_id=orders.store_id 
inner join order_items 
on order_items.order_id=orders.order_id 
where order_date>='2018-01-01' and order_date<='2018-12-31' 
group by store_name;

-- 10. Find the average price of all 'Electra' brand bikes having model year 2018.
select round(avg(list_price),2) as avg_price,category_name 
from products inner join brands 
on products.brand_id=brands.brand_id
inner join categories 
on categories.category_id=products.category_id
where model_year=2018 and brand_name='Electra'
group by category_name;

-- 11. Find the first name and last name of staff who has made highest number of sales in year 2017.
select staffs.first_name,staffs.last_name 
from staffs 
where staff_id=
(select staffs.staff_id 
from orders inner join staffs 
on orders.staff_id=staffs.staff_id
where order_date>='2017-01-01' and order_date<='2017-12-31'
group by staffs.staff_id 
order by count(*) desc limit 1);
