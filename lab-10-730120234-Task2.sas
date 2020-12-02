/*****************************************************************************
* Project           : BIOS 511 Lab 10 Task 2
*
* Program name      : lab-10-730120234-Task2.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-11-09
*
* Purpose           :   
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/


libname echo "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo";
libname lab10 "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab10";
option nonumber nodate;
ods noptitle;


data pc_0;
	set echo.pc;
	label HOURS = 'Hours Post Dose';
	if scan(PCSTRESC,1,"0") = "<" then PCSTRESN = input(scan(PCSTRESC,1,"<"),best.);
	HOURS = input(scan(PCTPT,1," "),best.);
run;


proc sort data = pc_0 out = pc_0;
 	by USUBJID;
run;


proc sort data = echo.dm out = dm(keep=USUBJID ARMCD SEX);
 	by USUBJID;
run;


data pc_1;
 	merge pc_0(in=PC_IN) dm(in=DM_IN);
 	by USUBJID;
 	if PC_IN;

 	label  SEXGROUP = 'Sex Group';
 	length SEXGROUP $8.;

 	if SEX = 'M' then SEXGROUP = 'Male';
 	if SEX = 'F' then SEXGROUP = 'Female';
 	output;
 	SEXGROUP = 'Overall';
 	output;
run;


proc means data = pc_1 noprint nway;
 	class SEXGROUP HOURS;
 	var PCSTRESN;
 	output out = summary_0 nmiss=NMISS n=N mean=MEAN std=STD median=MEDIAN;
run;


data summary_1;
	set summary_0;
	label NMISS = 'Number missing' N = 'Number non-missing' MEAN = 'Mean' STD = 'Standard deviation' MEDIAN = 'Median';
	drop _TYPE_ _FREQ_;
run;


ods pdf file="C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab10\lab-10-730120234-Task2.pdf";;
title "Descriptive Summary of PK Concentrations by Gender";
proc print data=summary_1 label;
run;


ods pdf close;
