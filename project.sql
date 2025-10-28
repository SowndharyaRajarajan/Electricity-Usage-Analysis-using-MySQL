create database Electric;
use Electric;
show tables;


select * from billing_info;
select * from appliance_usage;
select * from calculated_metrics;
select * from environmental_data;
select * from household_info;



set autocommit=off;

start transaction;

update billing_info 
set payment_status=case 
    when Cost_usd > 200 then "high"
	when Cost_usd between 100 and 200 then "medium"
else "Low" End;

select * from billing_info;

rollback;


-- TASK 2
show tables;

select 
	household_id,
    month,
    year,
    sum(total_Kwh) as total_Kwh ,
	rank() over(partition by year order by sum(total_kwh) desc) as usage_rank,
	case when sum(Total_kwh)>500 then "High" Else "Low" 
end as Usage_level
from billing_info
group by 1,2,3;

-- task -3

SELECT 
    month,
    SUM(CASE WHEN month = 'Jan' THEN cost_usd   ELSE 0 END) AS Jan_usage,
    SUM(CASE WHEN month = 'Feb' THEN cost_usd  ELSE 0 END) AS Feb_usage,
    SUM(CASE WHEN month = 'Mar' THEN cost_usd  ELSE 0 END) AS Mar_usage
FROM billing_info
GROUP BY month;


-- task-4


select 
h.household_id,
h.city,
avg(monthly_total_Kwh) as Avg_monthly_Kwh
from 
(select household_id,month,year,sum(Total_kwh)
as monthly_Total_kwh from billing_info group by 1,2,3) b
 inner join 
houseHold_info h 
on h.household_id=b.household_id 
group by h.city,h.household_id;


-- Task 5

show tables;
select * from appliance_usage;
select * from environmental_data;
select 
	a.household_id,
    a.Kwh_usage_AC,
    e.avg_outdoor_temp
from appliance_usage a inner join environmental_data e 
on a.household_id=e.household_id
Where a.household_id in(
	select household_id from appliance_usage where Kwh_usage_AC>100);
    
-- Task 6

show tables;

select * from household_info;
select * from billing_info;

delimiter !! 
create procedure billing_region(in region_name varchar(100))#parameter
begin 
select
	b.* #returns only billing_info
from household_info h #household_info table 
inner join billing_info b #billing_info table
on h.household_id=b.household_id 
where region=region_name #returns paramter
order by b.year,b.month; 
end
!! delimiter ;

call billing_region('west');
call billing_region('east');


-- Task-7
show tables;
select * from billing_info;

delimiter !! 
create procedure calculate_total(in hold_id varchar(100),inout tot_kwh double)
begin 
select 
	sum(total_kwh) as Total_Kwh #calculate total_Kwh from billing_info
into tot_Kwh # stored into paramter
from billing_info # in billing_Info
where houseHold_id=hold_id;#Stored 
end
!! delimiter ;

call  calculate_total('H0001',@tot_sal);
select @tot_sal as houseHold_Total;


-- TASK 8
select * from billing_info;
drop trigger bef_billing_info;
delimiter !! 
create trigger bef_billing_info before Insert on billing_info  for each row
begin
if new.rate_per_Kwh is null or new.rate_per_Kwh=0 or new.rate_per_kwh=' '
then set new.rate_per_kwh=0.18; 
end if;
set new.cost_usd=round(new.total_kwh*new.rate_per_Kwh,2);
end
!! delimiter ;

set autocommit=off;
start Transaction;
select * from billing_info;
insert into billing_info 
(household_id, month, year, billing_cycle, payment_status, rate_per_kwh,total_kwh) 
values 
('01', 'Jan', '2025', '2025-01-01 to 2025-01-30', 'Unpaid', '0.18', '1885.9499999999998'),
('02', 'mar', '2025', '2025-01-01 to 2025-01-30', 'Unpaid', 0, '2999.9499999999998'),
('03', 'mar', '2025', '2025-01-01 to 2025-01-30', 'Unpaid', null, '1999.9499999999998'),
('04', 'mar', '2025', '2025-01-01 to 2025-01-30', 'Unpaid', null, '1999.9499999999998');

select * from billing_info order by household_id asc;

rollback;

-- task -9
drop trigger after_billing_info;
select * from calculated_metrics;
select * from household_info;
show tables;
delimiter !! 
create trigger after_billing_info after insert on billing_info for each row 
begin

insert into calculated_metrics 
(household_id,Kwh_per_occupant,Kwh_per_sqft,Usage_category) 
select 
	h.household_id,
	new.total_kwh/h.num_occupants,
    new.total_kwh/floor_area_sqft,
case 
	when new.total_kwh>600 Then "High" 
    else "Moderate" 
End 
from household_info h 
where h.household_id=new.household_id;
end
!! delimiter ;

set autocommit=off;
start transaction;
select * from billing_info;
select * from household_info;
select * from billing_info;

insert into household_info () values
('0003', 'East', 'Lakeland', '605757', 'Apartment', '2040', '2', 'Yes'),
('0004', 'North', 'RiverTown', '605761', 'Detached', '2040', '7', 'no');

insert into billing_info values
('0003', 'Jan', '2025', '2025-01-01 to 2025-01-30', 'Unpaid', '0.18', '339.47', '1885.9499999999998'),
('0004', 'Jan', '2025', '2025-01-01 to 2025-01-30', 'Unpaid', '0.18', '669.47', '400.9499999999998');

select * from calculated_metrics order by household_id;

rollback;

select * from household_info;
delete from household_info where household_id in('0001','0002','0003','0004');

commit;


-- final Answer 
select 
	household_id,
    month,
    year,
    sum(Total_kwh) as monthly_usage,
rank() over(partition by year order by sum(total_kwh) desc) as rnk,
if(sum(total_kwh)>500,"High","Low") as level from billing_info
group by household_id,month,year;















-- Project Task 8: Automatically calculate cost_usd 
-- before inserting into billing_info.










-- Project Task 9 : After a new billing entry, 
-- insert calculated metrics into calculated_metrics.








