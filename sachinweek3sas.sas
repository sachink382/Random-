/*1. Import dataset in the SAS environment and check top 10 record of import dataset (2 Mark)*/

FILENAME REFFILE '/home/u58915800/sasuser.v94/Week 3/Life+Insurance+Dataset.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.lifeinsurancedata;
	GETNAMES=YES;
RUN;

proc print data=work.lifeinsurancedata (obs=10);
run;


/*2. Check variable type of the import dataset (2 Mark)*/
PROC CONTENTS DATA=WORK.lifeinsurancedata; 
RUN;

/*3. Checks if any variables have missing values, if yes then do treatment? (3 Mark)*/
proc means data=work.lifeinsurancedata nmiss;
run;

/* No missing values*/


/*4. Check summary and percentile distribution of all numerical variables for churners and non-churners? (5 Marks)*/
proc summary data=work.lifeinsurancedata printall;
class churn;
var   age  Agent_Tenure CC_Satisfation_score Complaint 
 Existing_policy_count  Miss_due_date_cnt Overall_cust_satisfation_score  
 YTD_contact_cnt Cust_Income Cust_Tenure Due_date_day_cnt;
run;

proc means data=work.lifeinsurancedata 
print n min max p1 p5 p10 p25 p50 p75 p90 p95 p99;
class churn;
var   age  Agent_Tenure CC_Satisfation_score  
 Existing_policy_count  Miss_due_date_cnt Overall_cust_satisfation_score  
 YTD_contact_cnt Cust_Income Cust_Tenure Due_date_day_cnt;
run;


/*5. Check for outlier, if yes then do treatment? (3 Mark)*/
proc univariate data=LifeInsuranceData;
var Age Cust_Tenure Overall_cust_satisfation_score 
CC_Satisfation_score Cust_Income Agent_Tenure
YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;
run;

/* treatment */
data LifeInsuranceData;
set LifeInsuranceData;
if Cust_Income> 35999 then Cust_Income = 35999;
if Due_date_day_cnt> 38 then Due_date_day_cnt = 38;
run;

/*6. Check the proportion of all categorical variables and extract percentage contribution of each class in respective
variables? (5 Marks)*/
proc freq data=LifeInsuranceData;
table Payment_Period Product EducationField Gender 
Cust_Designation Cust_MaritalStatus / nocum;
run;


/*7. Customer service management want you to create a macro where they will just put mobile number and they will
get all the important information like Age, Education, Gender, Income and CustID (6 Marks)*/
%macro cust_info();
proc sql;
select Age,  EducationField, Gender, cust_Income , CustID
from work.lifeinsurancedata
where  Mobile_num = &mobilenumber;
quit;  
%mend;

%let mobilenumber=9926913118;
%cust_info;


/*8. Check correlation of all numerical variables before building model, because we cannot add correlated variables in
model? (4 Marks)*/
proc corr data=work.lifeinsurancedata noprob nosimple ;
var   age  Agent_Tenure CC_Satisfation_score  
 Existing_policy_count  Miss_due_date_cnt Overall_cust_satisfation_score  
 YTD_contact_cnt Cust_Income Cust_Tenure Due_date_day_cnt;
run;


/*9. Create train and test (70:30) dataset from the existing data set. Put seed 1234? (4 Marks)*/
proc freq data=work.lifeinsurancedata;
table churn /nocum;
run;

proc surveyselect data= work.lifeinsurancedata method = srs rep=1 
sampsize=577 seed=1234 out=work.test;
run;

proc sql;
create table train as select temp.* from work.lifeinsurancedata temp
where CustID not in (select CustID from test);
quit;


/*10. Develop linear regression model first on the target variable to extract VIF information to check multicollinearity?
(6 Marks)*/
proc reg data=train;
model churn = age  Agent_Tenure CC_Satisfation_score  
 Existing_policy_count  Miss_due_date_cnt Overall_cust_satisfation_score  
 YTD_contact_cnt Cust_Income Cust_Tenure Due_date_day_cnt /vif collin;
run;

/*11. Create clean logistic model on the target variables? (4 Marks)*/
%let var= Age Cust_Tenure Overall_cust_satisfation_score CC_Satisfation_score Cust_Income Agent_Tenure
YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;
proc logistic data=train descending outmodel=model;
model Churn = &var / lackfit;
output out = train_output xbeta = coeff stdxbeta = stdcoeff predicted = prob;
run;

/* 12. KS Statistics*/
Proc npar1way data=train edf;
class churn;
var Age Cust_Tenure Overall_cust_satisfation_score CC_Satisfation_score Cust_Income Agent_Tenure
YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;
run;



/*13. Predict test dataset using created model? (2 Marks)*/
proc reg data=train outest=trainout;
model Churn=Age Cust_Tenure Overall_cust_satisfation_score CC_Satisfation_score Cust_Income Agent_Tenure
YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;
run;

proc score data=test score=trainout type=parms predict out=testout;
var Age Cust_Tenure Overall_cust_satisfation_score CC_Satisfation_score Cust_Income Agent_Tenure
YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;
run;