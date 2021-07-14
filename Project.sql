-- Sachin Kumar - Graded Project on SQL

-- Q1 Write a query to calculate what % of the customers have made a claim in the current exposure period[i.e. in the given dataset]?

select ((select count() 
         from Auto
         where ClaimNb >0)*100 / (Select count()
                                  From Auto) ) 
as percent_Customer from Auto;

-- Ans - 5%


-- Q2.1. Create a new column as 'claim_flag' in the table 'auto_insurance_risk' as integer datatype.

Alter table Auto add claim_flag INT(5);


-- Q2.2 Set the value to 1 when ClaimNb is greater than 0 and set the value to 0 otherwise.

Update Auto
set claim_flag = (case when ClaimNb>0 then 1
					   when ClaimNb<=0 then 0 end);
					   
-- 3.1. What is the average exposure period for those who have claimed?

SELECT avg(Exposure) from Auto
where claim_flag = 1;

-- ANs = 0.64249


-- 3.2 What do you infer from the result?

Select claim_flag, avg(Exposure) FROM Auto
group by claim_flag;

--Ans - Those who have claimed have an average exposure of 0.642, which is greater than those who have not claimed i.e 0.5227


-- 4.1. If we create an exposure bucket where buckets are like below, what is the % of total claims by these buckets?

Alter table Auto add Bucket Varchar(5);

-- making bucket 
Update Auto set Bucket = (case 
when Exposure>=0 and Exposure<=0.25 then "E1" when Exposure>=0.26 and Exposure<=0.5 then "E2" when Exposure>=0.51 and Exposure<=0.75 then "E3"
when Exposure>0.75 then "E4" end);

Select sum(ClaimNb) as E1 from Auto where Bucket='E1';
-- ANs - 7131  -  19.7%
Select sum(ClaimNb) as E2 from Auto where Bucket='E2';
-- ANs - 6481  -  17.9%
Select sum(ClaimNb) as E3 from Auto where Bucket='E3';
-- ANs - 5968  -  16.5%
Select sum(ClaimNb) as E4 from Auto where Bucket='E4';
-- ANs - 16522  -  45.7%


-- 4.2What do you infer from the summary?

-- We infer that when exposure bucket was 0 to 0.25 that is E1, percentage of Claims were 19.7%. Similarly for E2 and E3, percentage of claims
-- are 17.9% and 16.9%. For E, that is the with Exposure above 0.75 has heighest claim with 45.7%.


-- 5. Which area has the higest number of average claims? Show the data in percentage w.r.t. the number of policies in corresponding Area.

Select Area, sum(ClaimNb) as Total_Claims, avg(ClaimNb) as Avg_Claims, count(ClaimNb) as Total_Pol,
(sum(ClaimNb)*100)/count(ClaimNb) as Percent
from Auto
group by Area
order by avg(ClaimNb) DESC;

-- Ans - Area F has the  higest number of average claims


-- 6. If we use these exposure bucket along with Area i.e. 
--group Area and Exposure Buckets together and look at the claim rate, an interesting pattern could be seen in the data. What is that?

Select Area, sum(Exposure), ( (Select count() From Auto Where claimNb>0)*100 / (Select count() From Auto)) as claim_Rate
From Auto
Group By Area;

-- ANs - we will get the same Claim Rate for all the Area.

--7.1. If we look at average Vehicle Age for those who claimed vs those who didn't claim, what do you see in the summary?

Select avg(VehAge)
from Auto
where claim_flag=1;

-- ANS- 6.50

select avg(VehAge)
from Auto
where claim_flag=0;

-- ANS- 7.07

-- We infer that the average vehicle  age are nearly equal for both groups



--7.2. Now if we calculate the average Vehicle Age for those who claimed and 
--group them by Area, what do you see in the summary? Any particular pattern you see in the data?

Select Area,avg(DrivAge)
from Auto
where claim_flag=1
group by Area;

-- Group A have highest average of driving Age.


-- 8. If we calculate the average vehicle age by exposure bucket(as mentioned above), 
--we see an interesting trend between those who claimed vs those who didn't. What is that?

Select Bucket, avg(VehAge)
from Auto
where claim_flag=1
group by Bucket;

--E1	4.89699570815451
--E2	6.22187448525778
--E3	6.18439842913245
--E4	7.41964171465131


Select Bucket, avg(VehAge)
from Auto
where claim_flag=0
group by Bucket;

--Those who have not claimed have higher average of Vehicle Age as compared to who have claimed


--9.1. Create a Claim_Ct flag on the ClaimNb field as below, and take average of the BonusMalus by Claim_Ct.

Alter table Auto
add Claim_Ct Varchar(15);

Update AUTO
set Claim_Ct = (case 
				when ClaimNb=0 then "No_Claim"
				when ClaimNb=1 then "1_Claim"
				when ClaimNb>1 then "MT_1_Claim" end);

Select Claim_Ct ,avg(BonusMalus)
from Auto
group by Claim_Ct;

--1_Claim	62.8371558207471
--MT_1_Claim	67.5531349628055
--No_Claim	59.5850411443071


-- 9.2. What is the inference from the summary?

-- Those who do not claim have lowest average of BonusMalus and those who made more than one claim have high average


--10. Using the same Claim_Ct logic created above, if we aggregate the Density column 
--(take average) by Claim_Ct, what inference can we make from the summary data?

Select Claim_Ct,avg(Density)
from Auto
group by Claim_Ct;

-- No claims have lowest density whereas more than one clain has heighest density meaning cities have more claim than smaller towms and villages


--11. Which Vehicle Brand & Vehicle Gas combination have the highest number of Average Claims (use ClaimNb field for aggregation)?

Select VehBrand, VehGas, avg(ClaimNb)
from Auto
group by VehBrand, VehGas
order by avg(ClaimNb) DESC;

-- Ans - B12 , Regular


--12. List the Top 5 Regions & Exposure[use the buckets created above] Combination 
--from Claim Rate's perspective. Use claim_flag to calculate the claim rate.

Select Region, Exposure
from Auto
group by VehBrand, VehGas
order by avg(ClaimNb) DESC LIMIT 5;

-- ANs -

--R82	0.1
--R11	0.69
--R82	0.85
--R93	0.86
--R11	0.79

-- 13.1. Are there any cases of illegal driving i.e. underaged folks driving and committing accidents?

select count(*) from Auto where DrivAge<18;

-- ANs -NO 


-- 13.2 Create a bucket on DrivAge and then take average of BonusMalus by this Age Group Category. WHat do you infer from the summary?

Alter table Auto add DrivBucket Varchar(10);
Update Auto set DrivBucket = (case 
when DrivAge=18 then "Begineer"
when DrivAge BETWEEN 18 and 29 then "Junior"
when DrivAge BETWEEN 29 and 44 then "MiddleAge"
when DrivAge BETWEEN 44 and 60 then "MidSenior"
when DrivAge>60 then "Senior" end);
select DrivBucket, avg(BonusMalus) from Auto GROUP by DrivBucket;

--  Who have Age less than 18 have highest average of BonusMalus and those age greater than 60 have lowest average of BonusMalus. It is in decreasing ORDER


-- 14. Mention one major difference between unique constraint and primary key? 

-- There can be only one Primary Key and it cannot be null 
-- Whereas there can be more than one unique constraint in a table and it can be NULL.


-- 15. If there are 5 records in table A and 10 records in table B and we cross-join these two tables, how many records will be there in the result set?

-- There be 50 records in the table.



-- 16. What is the difference between inner join and left outer join? 

-- Inner join will only show the rows which are common in both the tables.
-- Left outer join will show all the rows of left table and the common rows for right table and the uncommon rows of right table will have null values



-- 17. Consider a scenario where Table A has 5 records and Table B has 5 records. Now while inner joining Table A and Table B, 
--there is one duplicate on the joining column in Table B (i.e. Table A has 5 unique records, but Table B has 4 unique values 
--and one redundant value). What will be record count of the output?

-- The record count is 25.

-- 18. What is the difference between WHERE clause and HAVING clause?

-- Where clause can not be used on aggregated data but on row’s data and Having clause can be used with aggregates



