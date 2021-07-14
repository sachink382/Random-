
/*1. Import all the 4 files in SAS data environment (8 Mark)*/

FILENAME REFFILE '/home/u58837170/week2assignment/Agent_Score.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.agentscore;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/home/u58837170/week2assignment/Online.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.online;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/home/u58837170/week2assignment/Roll_Agent.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.rollagent;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/home/u58837170/week2assignment/Third_Party.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.thirdparty;
	GETNAMES=YES;
RUN;



/* 2. Create one dataset from all the 4 dataset? (8 Mark) */
data week2;
set  WORK.AGENTSCORE WORK.ONLINE WORK.ROLLAGENT WORK.THIRDPARTY;
run;


/* for our purpose we need only 3 dataset */
data week2;
set  WORK.ONLINE WORK.ROLLAGENT WORK.THIRDPARTY;
run;



/*3. Remove all unwanted ID variables? (2 Mark)*/
data week2(Drop= hhid custid);
set  WORK.ONLINE WORK.ROLLAGENT WORK.THIRDPARTY;
run;



/*4. Calculate annual premium for all customers? (4 Mark)*/
data week2_2;
set week2;
if payment_mode='Monthly' then annual_premium = (premium*12);
else if payment_mode='Quaterly' then annual_premium = (premium*4);
else if payment_mode='Semi Annual' then annual_premium = (premium*2);
else annual_premium = (premium*1);
run;



/*5. Calculate age and tenure as of 31 July 2020 for all customers? (4 Marks)*/
data week2_3;
set week2_2;
age = intck ('year',dob,'31JUL2020'd);
tenure=intck ('month',policy_date,'31JUL2020'd);
run;



/*6. Create a product name by using both level of product information. And product name should be representable
i.e. no code should be present in final product name? (4 Marks)*/
data week2_4;
set week2_3;
product_name=catx("",product_lvl1,substr(product_lvl2,6,15));
run;



/*7. After doing clean up in your data, you have to calculate the distribution of customers across product and policy
status and interpret the result (4+1 Marks)*/
proc freq data= week2_4;
tables product_name*policy_status /norow nocol  ;
run;



/*8. Calculate Average annual premium for different payment mode and interpret the result? (4+1 Marks)*/
proc sql;
select payment_mode, avg(annual_premium) as avg_annual_premium
from work.week2_4
group by payment_mode;
quit;


/*9. Calculate Average persistency score, no fraud score and tenure of customers across product and policy status,
and interpret the result? (4+1 Marks)*/
proc sql;
select a.product_name, a.policy_status, avg(a.tenure) as avg_tenure, 
avg(b.NoFraud_Score) as avg_nofraud_score,
avg(b.Persistency_Score) as avg_persistency_score
from work.week2_4 a left join work.agentscore b
on b.agentid=a. agentid
group by a.product_name, a.policy_status;
quit;



/*10. Calculate Average age of customer across acquisition channel and policy status, and interpret the result? (4+1
Marks)*/
proc sql;
select  acq_chnl, policy_status, avg ( age) as avg_age_of_customer
from work.week2_4
group by acq_chnl,policy_status; 
quit;




