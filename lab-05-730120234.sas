/*****************************************************************************
* Project           : BIOS 511 Lab 5
*
* Program name      : lab-03-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-09-25
*
* Purpose           :   
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/



ods noproctitle;
ods html file='C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab5\lab-05-730120234-output.html';

libname echo "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo";

footnote "ECHO Data Extract Date: 2018-09-25";



/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/


proc format;
value AGECAT
	. = 'Missing'
	low-<50 = '<50'
	50-<65 = '<65'
    65-high = '>=65';
run;


data work.dm1;
	set echo.dm;
	format AGE AGECAT.;
	label AGECATEGORY = ÅgAge CategoryÅh;
	AGECATEGORY = put(AGE,AGECAT.);
run;


/*
proc contents data=dm1;
run;
*/


title1 "Task 1 / Step 3: One-Way Analysis of Age Categories (Using Formatted AGE Variable)";
proc freq data=dm1;
	label AGE = ÅgAge CategoryÅh;
	table AGE;
run;


title1 "Task 1 / Step 4: One-Way Analysis of Age Categories (Using AGECATEGORY Variable)";
proc freq data=dm1;
	table AGECATEGORY;
run;


/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/


proc format;
	invalue SEXN
 		"M" = 1
 		"F" = 2
 		other = .;
run;


data dm2;
	set dm1;
	format TRTSTDTN TRTENDTN date9.;
	SEXNUM = input(SEX,SEXN.);
	TRTSTDTN = input(RFXSTDTC,yymmdd10.);
	TRTENDTN = input(RFXENDTC,yymmdd10.);
	TRTDUR = (TRTENDTN - TRTSTDTN + 1)/7;
run;


proc means data=dm2 n mean stddev min max noprint;
	var TRTDUR;
	class AGECATEGORY ARMCD;
	ways 1;
	output out = trtdur_summary n= mean= std= min= max= / autoname;
run;

title1 "Task 2 / Part 5: Summary of Treatment Duration by Treatment Group";
proc print data=trtdur_summary split="/" noobs label;
	where _TYPE_=1;
	format  TRTDUR_MEAN TRTDUR_MIN TRTDUR_MAX 6.2 TRTDUR_STDDEV 7.3;
	label TRTDUR_MEAN = "Mean" TRTDUR_MIN = "Minimum" TRTDUR_MAX = "Maximum" TRTDUR_STDDEV = "Standard/Deviation" TRTDUR_N = "Sample/Size";
	var ARMCD TRTDUR_N TRTDUR_MEAN TRTDUR_STDDEV TRTDUR_MIN TRTDUR_MAX;
run;


title1 "Task 2 / Part 5: Summary of Treatment Duration by Age Category";
proc print data=trtdur_summary split="/" noobs label;
	where _TYPE_=2;
	format  TRTDUR_MEAN TRTDUR_MIN TRTDUR_MAX 6.2 TRTDUR_STDDEV 7.3;
	label TRTDUR_MEAN = "Mean" TRTDUR_MIN = "Minimum" TRTDUR_MAX = "Maximum" TRTDUR_STDDEV = "Standard/Deviation" TRTDUR_N = "Sample/Size";
	var AGECATEGORY TRTDUR_N TRTDUR_MEAN TRTDUR_STDDEV TRTDUR_MIN TRTDUR_MAX;
run;
