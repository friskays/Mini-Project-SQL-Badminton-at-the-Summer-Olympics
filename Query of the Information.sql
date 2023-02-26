-- 1. Debut as a Demonstration Sport --

select 
	distinct g.city, g.year
from athlete_event_results ae
join games g 
	on g.edition_id = ae.edition_id
where sport='Badminton'
order by 2
limit 1
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 2. Debut as an Official Sport --

select 
	distinct g.city, g.year
from athlete_event_results ae
join games g 
	on g.edition_id = ae.edition_id
where sport='Badminton' and medal != 'na'
order by 2
limit 1

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 3. Number of Participation per Year --

with cte as(
	select gm.year year_event, gm.city city, 
	ae.country_noc Number_of_Country, ae.athlete_id Number_of_Athlete
	from athlete_event_results ae  
	left join games gm on ae.edition_id = gm.edition_id
	where sport = 'Badminton'), 
olympic_group as (
	select year_event, city, count(distinct Number_of_Country) Number_of_Country, 
		count(distinct Number_of_Athlete) Number_of_Athlete
	from cte
	where year_event not in (1972, 1988)
	group by 1,2
	order by 1)
select concat(city, ' ', year_event) olympic, Number_of_Country, Number_of_Athlete
from olympic_group

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 4. Medals per Year by Country --

with cte as(
	select c.country country, cast(left(ae.edition, 4) as int) Year_Event, ae.event event_title, ae.medal medal_type
	from athlete_event_results ae
	join country c on c.country_noc=ae.country_noc
	where sport = 'Badminton'), 
double as (
	select country, Year_Event, 
		sum(case when medal_type='Gold' then 1 else 0 end)/2 Medal_Gold,
		sum(case when medal_type='Silver' then 1 else 0 end)/2 Medal_Silver,
		sum(case when medal_type='Bronze' then 1 else 0 end)/2 Medal_Bronze
	from cte
	where event_title like 'Doubl%'
	group by 1,2),
single as (
	select country, Year_Event,
		sum(case when medal_type='Gold' then 1 else 0 end) Medal_Gold,
		sum(case when medal_type='Silver' then 1 else 0 end) Medal_Silver,
		sum(case when medal_type='Bronze' then 1 else 0 end) Medal_Bronze
	from cte
	where event_title like 'Single%'
	group by 1,2), 
union_medal as (
	select * from double 
	union 
	select * from single),
group_medal as (
select Year_Event, country, sum(Medal_Gold+Medal_Silver+Medal_Bronze) Total_Medal
from union_medal 
group by 1,2
order by year_event, country)
select country,
	sum(case when Year_Event='1992' then Total_Medal else 0 end) "92",
	sum(case when Year_Event='1996' then Total_Medal else 0 end) "96",
	sum(case when Year_Event='2000' then Total_Medal else 0 end) "00",
	sum(case when Year_Event='2004' then Total_Medal else 0 end) "04",
	sum(case when Year_Event='2008' then Total_Medal else 0 end) "08",
	sum(case when Year_Event='2012' then Total_Medal else 0 end) "12",
	sum(case when Year_Event='2016' then Total_Medal else 0 end) "16",
	sum(case when Year_Event='2020' then Total_Medal else 0 end) "20",
	sum(Total_Medal) Total_Medals
from group_medal 
where year_event not in (1972, 1988)
group by 1
having sum(Total_Medal)>0
order by Total_Medals desc, country asc

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 5. Distribution of Medal by Country --

with cte as(
	select c.country country, ae.event event_title, ae.medal medal_type
	from athlete_event_results ae
	join country c on c.country_noc=ae.country_noc
	where sport = 'Badminton'), 
double as (
	select country, 
		sum(case when medal_type='Gold' then 1 else 0 end)/2 Medal_Gold,
		sum(case when medal_type='Silver' then 1 else 0 end)/2 Medal_Silver,
		sum(case when medal_type='Bronze' then 1 else 0 end)/2 Medal_Bronze
	from cte
	where event_title like 'Doubl%'
	group by 1),
single as (
	select country, 
		sum(case when medal_type='Gold' then 1 else 0 end) Medal_Gold,
		sum(case when medal_type='Silver' then 1 else 0 end) Medal_Silver,
		sum(case when medal_type='Bronze' then 1 else 0 end) Medal_Bronze
	from cte
	where event_title like 'Single%'
	group by 1), 
group_medal as (
	select * from double 
	union 
	select * from single) 
select country, sum(Medal_Gold) Gold, sum(Medal_Silver) Silver, sum(Medal_Bronze) Bronze,
	sum(Medal_Gold+Medal_Silver+Medal_Bronze) Total_Medals
from group_medal 
group by 1
having sum(Medal_Gold+Medal_Silver+Medal_Bronze)>0
order by 2 desc, 3 desc, 4 desc

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 6. Oldest Gold Medalist --

with cte as (
	select athlete_id, 
		(case
		 when born like 'in%' then null
		 when born = 'na' then null 
		 when born like '(%' then left(right(born, 5), 4)
		 when born is null then null
		 else born 
		 end) born
	from athlete_bio),
table1 as (
select ae.edition, ae.athlete, ae.medal,
	make_date(
	nullif(left(c.born, 4), '')::int, 
	nullif(split_part(c.born, '-', 2), '')::int,
	nullif(split_part(c.born, '-', 3), '')::int) date_birth
from athlete_event_results ae
left join cte c on ae.athlete_id = c.athlete_id
where sport='Badminton'),
cte2 as (
	select edition, 
		(case
		 when start_date is null then null
		 when start_date = 'na' then left(edition, 4)
		 else start_date 
		 end) start_date
	from games), 
cte_event as (
	select edition,
		make_date(
		nullif(left(start_date, 4), '')::int,
		nullif(split_part(start_date, '-', 2), '')::int,
		nullif(split_part(start_date, '-', 3), '')::int) date_event
	from cte2),
group_bod_event as (
select t1.edition, t1.athlete, t1.medal, t1.date_birth, 
	t2.date_event, AGE(t2.date_event, t1.date_birth) age
from table1 t1 
left join cte_event t2 on t1.edition = t2.edition) 
select athlete oldest_athlete_gold_medal, 
	concat(date_part('year', age),' ','Years ',date_part('month', age),' Month') age
from group_bod_event
where age = (select MAX(age)from group_bod_event where medal='Gold')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 7. Youngest Gold Medalist --

with cte as (
	select athlete_id, 
		(case when born like 'in%' then null
		 when born = 'na' then null 
		 when born like '(%' then left(right(born, 5), 4)
		 when born is null then null
		 else born end) born
	from athlete_bio),
table1 as (
select ae.edition, ae.athlete, ae.medal,
	make_date(
	nullif(left(c.born, 4), '')::int, 
	nullif(split_part(c.born, '-', 2), '')::int,
	nullif(split_part(c.born, '-', 3), '')::int) date_birth
from athlete_event_results ae
left join cte c on ae.athlete_id = c.athlete_id
where sport='Badminton'),
cte2 as (
	select edition, 
		(case when start_date is null then null
		 when start_date = 'na' then left(edition, 4) else start_date 
		 end) start_date
	from games), 
cte_event as (
	select edition,
		make_date(
		nullif(left(start_date, 4), '')::int,
		nullif(split_part(start_date, '-', 2), '')::int,
		nullif(split_part(start_date, '-', 3), '')::int) date_event
	from cte2),
group_bod_event as (
	select t1.edition, t1.athlete, t1.medal, t1.date_birth, 
		t2.date_event, AGE(t2.date_event, t1.date_birth) age
	from table1 t1 
	left join cte_event t2 on t1.edition = t2.edition) 
select distinct athlete youngest_athlete_gold_medal, 
	concat(date_part('year', age),' ','Years ',date_part('month', age),' Month')
from group_bod_event
where medal = 'Gold' and age = (select MIN(age)from group_bod_event where medal='Gold')


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- 8. Leader for the Most Medalist --

with cte as (
	select athlete,
		sum(case when medal='Gold' then 1 else 0 end) Gold,
		sum(case when medal='Silver' then 1 else 0 end) Silver,
		sum(case when medal='Bronze' then 1 else 0 end) Bronze
	from athlete_event_results
	where medal!='na' and sport='Badminton'
	group by 1) 
select 
	athlete, sum(Gold) Gold, sum(Silver) Silver, 
	sum(Bronze) Bronze, sum(Gold+Silver+Bronze) Total
from cte
group by 1
order by 5 desc, 2 desc, 3 desc
limit 1

