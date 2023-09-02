use spotify_user_analysis;

-- CREATE table activity
-- (
-- user_id varchar(20),
-- event_name varchar(20),
-- event_date date,
-- country varchar(20)
-- );

-- delete from activity;
-- insert into activity values (1,'app-installed','2022-01-01','India')
-- ,(1,'app-purchase','2022-01-02','India')
-- ,(2,'app-installed','2022-01-01','USA')
-- ,(3,'app-installed','2022-01-01','USA')
-- ,(3,'app-purchase','2022-01-03','USA')
-- ,(4,'app-installed','2022-01-03','India')
-- ,(4,'app-purchase','2022-01-03','India')
-- ,(5,'app-installed','2022-01-03','SL')
-- ,(5,'app-purchase','2022-01-03','SL')
-- ,(6,'app-installed','2022-01-04','Pakistan')
-- ,(6,'app-purchase','2022-01-04','Pakistan');

# Find out total active users each day 

-- select 
-- event_date,
-- count(distinct user_id) as active_users
-- from 
-- activity
-- where event_name in ('app-installed' , 'app-purchase')
-- group by 1

# Find total active users each week

# By default mysql treats Sunday as the first day of the week, hence the dates that are lying below that are considered as zero 
# In this case 2022-01-01 is saturday and since the first day of the week is sunday in mysql, it is giving zeros for those values
# So in order to fix this we just add + 1 to each of them making them treat as if monday is the starting day of the week which in turn 
# returns the correct order of date

-- with week_wise_users as (
-- select 
-- *,
-- week(event_date) + 1 AS week_number
-- from 
-- activity
-- )

-- select 
-- week_number,
-- count(distinct user_id) as active_users_per_week
-- from 
-- week_wise_users 
-- group by 1

# Date wise, return the total number of users who made the purchase same day they installed the app

-- with rapid_users as (
-- select 
-- event_date,
-- (case when count(event_name) >= 2 then 1 else 0 end) as no_of_users_with_same_day_purchase
-- from 
-- activity
-- group by event_date, user_id
-- )

-- select 
-- event_date,
-- sum(no_of_users_with_same_day_purchase) as no_of_users_with_same_day_purchase
-- from 
-- rapid_users
-- group by 1

# Return Percentage of paid users in India, USA and other country should be tagged as others. For India and USA it
# should return percentages 

# Country wise paid users

-- with country_wise_users as (
-- select
-- case when country in ('India','USA') then country else 'others' end as country,
-- count(user_id) / (select count(user_id) from activity where event_name = 'app-purchase') as users
-- from 
-- activity
-- where event_name = 'app-purchase'
-- group by country
-- )

-- select 
-- country,
-- round(sum(users) * 100) as percentage_users
-- from 
-- country_wise_users
-- group by 1

# Amongst all the users who installed the app on a given day, how many did in app purchased on the very next day
# day wise results

with event_dates as (
select 
*,
lead(event_date) over(partition by user_id) as purchase_date
from 
activity
order by user_id, event_date
),

setting_status as (
select 
*,
case when datediff(purchase_date, event_date) = 1 then 1 else 0 end as purchase_status
from 
event_dates
where purchase_date is not null
)

select 
e.event_date,
case when sum(s.purchase_status) is null then 0 else sum(s.purchase_status) end as cnt_users
from 
setting_status as s 
right join 
event_dates as e 
on s.purchase_date = e.event_date
group by 1




