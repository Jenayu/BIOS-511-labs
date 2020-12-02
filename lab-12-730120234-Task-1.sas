/*****************************************************************************
* Project           : BIOS 511 Lab 12 Task 1
*
* Program name      : lab-12-730120234-Task-1.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-11-25
*
* Purpose           :   
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/

%let root = .\labs\lab12;
%let echoDat = .\datasets\echo;
%let analysisDat = &root.\data;


libname out "&analysisDat.";
libname echo "&echoDat." access=read;


data dm; set echo.dm (keep = USUBJID ARMCD ARM AGE COUNTRY); run;


data pc;
	set echo.pc (keep = USUBJID PCSTRESN);
	by USUBJID;

	retain PCMAX;
	if first.USUBJID then PCMAX = 0;
	if PCSTRESN > PCMAX then PCMAX = PCSTRESN;

	keep USUBJID PCMAX;
  	if last.USUBJID and PCMAX>. then output;
run;


data vs_0; set echo.vs; by USUBJID; if VISITNUM>1 then delete; run;
data vs_1; set echo.vs; by USUBJID; if VISITNUM<=1 then delete; run;


proc means data=vs_0 noprint;
	by USUBJID;
	class VSTESTCD;
	var VSSTRESN;
	output out=before_w1 mean=X;
run;


proc means data=vs_1 noprint;
	by USUBJID;
	class VSTESTCD;
	var VSSTRESN;
	output out=after_w1 mean=Y;
run;


proc sort data=before_w1; by USUBJID VSTESTCD; run;
proc sort data=after_w1; by USUBJID VSTESTCD; run;


data diabp_c sysbp_c hr_c wgt_c;
	merge before_w1 after_w1;
	by USUBJID VSTESTCD;

	drop _TYPE_ _FREQ_;

	if VSTESTCD="DIABP" then do;
		DIABP_CHANGE = Y-X;
		drop VSTESTCD;
		output diabp_c;
	end;
	if VSTESTCD="SYSBP" then do;
		SYSBP_CHANGE = Y-X;
		drop VSTESTCD;
		output sysbp_c;
	end;
	if VSTESTCD="HR" then do;
		HR_CHANGE = Y-X;
		drop VSTESTCD;
		output hr_c;
	end;
	if VSTESTCD="WEIGHT" then do;
		WGT_CHANGE = Y-X;
		drop VSTESTCD;
		output wgt_c;
	end;
run;


data diabp_c; set diabp_c(keep=USUBJID DIABP_CHANGE);run;
data sysbp_c; set sysbp_c(keep=USUBJID SYSBP_CHANGE);run;
data hr_c; set hr_c(keep=USUBJID HR_CHANGE);run;
data wgt_c; set wgt_c(keep=USUBJID WGT_CHANGE);run;

proc sort data=diabp_c; by USUBJID; run;
proc sort data=sysbp_c; by USUBJID; run;
proc sort data=hr_c; by USUBJID; run;
proc sort data=wgt_c; by USUBJID; run;


data adsl_0;
	merge dm pc;
	by USUBJID;
	length AGECAT $8;

	if missing(AGE) then AGECAT = " ";
	else if AGE<45 then AGECAT = "<45";
	else if 45<=AGE<55 then AGECAT = "45-55";
	else if AGE>=55 then AGECAT = ">=55";
run;


data adsl_1;
	merge adsl_0 diabp_c sysbp_c hr_c wgt_c;
	by USUBJID;
run;


data out.adsl;
	retain USUBJID ARMCD ARM AGE AGECAT COUNTRY PCMAX DIABP_CHANGE SYSBP_CHANGE HR_CHANGE WGT_CHANGE;
	label USUBJID="Unique Subject Identifier" ARMCD="Planned Arm Code" ARM="Description of Planned Arm" 
		  AGE="Age" AGECAT="Age Category" COUNTRY="Country" PCMAX="Maximum Plasma Concentration" 
		  DIABP_CHANGE="Change in Diastolic Blood Pressure" SYSBP_CHANGE="Change in Systolic Blood Pressure" 
		  HR_CHANGE="Change in Heart Rate" WGT_CHANGE="Change in Weight";
	set adsl_1;
run;


