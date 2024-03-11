create database zomato; 
USE ZOMATO;

CREATE TABLE goldusers_signup
(userid int,gold_signup_date date); 

INSERT INTO goldusers_signup
(userid,gold_signup_date) 
VALUES (1,'2017-09-22'),
(3,'2017-04-21');


CREATE TABLE users
(userid int,signup_date date); 

INSERT INTO users(userid,signup_date) 
VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

CREATE TABLE sales
(userid int,
created_date date,
product_id int); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);

CREATE TABLE product
(product_id int,
product_name text,
price int); 

INSERT INTO product
(product_id,product_name,price) 
VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


-- --------------------------------------------------------------------
-- 1.what is total amount each customer spent on zomato ?
SELECT * FROM USERS;

SELECT * FROM SALES;
SELECT * FROM PRODUCT;

SELECT * FROM SALES S INNER JOIN PRODUCT P ON S.product_id = P.product_id;
SELECT S.userid ,SUM(P.price) AS Spend_amount FROM SALES S INNER JOIN PRODUCT P ON S.product_id = P.product_id group by userid;

-- 2.How many days has each customer visited zomato?
select userid, count(created_date) from sales group by userid;
select userid, count(distinct created_date)  from sales group by userid;

-- 3. Which was the first product purchased by each customer?

select *,rank()over (partition by userid order by  created_date ) as rnk from sales;

select  * from (select *,rank()over (partition by userid order by  created_date ) as rnk from sales) d where rnk=1;
select userid,product_name from (select  * from (select *,rank()over (partition by userid order by  created_date ) as rnk from sales) d where rnk=1)d inner join product p on d.product_id = p.product_id;

-- 4. Which is the most purchased item on menu & how many times was it purchased by all customers ?
select * from sales;
select product_id, count(created_date) cnt from sales group by product_id order by cnt desc limit 1;
select product_id from sales group by product_id order by count(created_date) desc limit 1;

select userid,product_id, count(product_id) as cnt from sales where product_id= (select product_id from sales group by product_id order by count(created_date) desc limit 1) group by userid,product_id;

-- 5.which item was most popular for each customer?

select * from sales;
select userid,product_id , count(product_id) as pcnt from sales group by userid,product_id;
select *,rank() over (partition by userid order by pcnt desc) as rnk  from (select userid,product_id , count(product_id) as pcnt from sales group by userid,product_id)a ;

select * from (select *,rank() over (partition by userid order by pcnt desc) as rnk  from (select userid,product_id , count(product_id) as pcnt from sales group by userid,product_id)a) d where rnk =1;

select c.userid,p.product_name,p.price from (select * from (select *,rank() over (partition by userid order by pcnt desc) as rnk  from (select userid,product_id , count(product_id) as pcnt from sales group by userid,product_id)a) d where rnk =1)c inner join product p on p.product_id=c.product_id;

-- 6. Which item was purchased first by customer after they become a member ?

select * from goldusers_signup; 

select s.userid ,s.created_date,s.product_id,g.gold_signup_date from sales s inner join goldusers_signup g on s.userid=g.userid ;

select * from (select s.userid ,s.created_date,s.product_id,g.gold_signup_date from sales s inner join goldusers_signup g on s.userid=g.userid) w 
where created_date > gold_signup_date;

select *,rank() over (partition by userid order by created_date) rnk 
from (select s.userid,s.created_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid)d;

select * from (select *,rank() over (partition by userid order by created_date) rnk 
from (select s.userid,s.created_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid)d)c where rnk = 1;

select q.userid,p.product_name from (select * from (select *,rank() over (partition by userid order by created_date) rnk 
from (select * from (select s.userid ,s.created_date,s.product_id,g.gold_signup_date from sales s inner join goldusers_signup g on s.userid=g.userid) w 
where created_date > gold_signup_date)d)c where rnk = 1)q 
inner join product p on p.product_id=q.product_id;

-- 7. which item was purchased just before the customer became a member?
select s.userid,s.created_date,s.product_id from sales s 
inner join goldusers_signup g on s.userid=g.userid 
where s.created_date < g.gold_signup_date;

select * , rank() over(partition by userid order by created_date desc) as rnk from (select s.userid,s.created_date,s.product_id, g.gold_signup_date from sales s 
inner join goldusers_signup g on s.userid=g.userid 
where s.created_date < g.gold_signup_date) a;

select * from (select * , rank() over(partition by userid order by created_date desc) as rnk from (select s.userid,s.created_date,s.product_id, g.gold_signup_date from sales s 
inner join goldusers_signup g on s.userid=g.userid 
where s.created_date < g.gold_signup_date)a) b where rnk =1;

select c.userid,p.product_name,p.price from (select * from (select * , rank() over(partition by userid order by created_date desc) as rnk from (select s.userid,s.created_date,s.product_id, g.gold_signup_date from sales s 
inner join goldusers_signup g on s.userid=g.userid 
where s.created_date < g.gold_signup_date)a) b where rnk =1)c inner join product p on c.product_id=p.product_id;

-- 8. what is total orders and amount spent by each member before they become a member?

select s.userid,s.product_id,s.created_date from sales s 
inner join goldusers_signup g on s.userid = g.userid 
where s.created_date <= g.gold_signup_date;


select a.userid,sum(p.price) as total , count(p.price) as count from (select s.userid,s.product_id,s.created_date from sales s 
inner join goldusers_signup g on s.userid = g.userid 
where s.created_date <= g.gold_signup_date)a 
inner join product p on p.product_id=a.product_id group by a.userid ;





select * from sales;
select * from goldusers_signup;



