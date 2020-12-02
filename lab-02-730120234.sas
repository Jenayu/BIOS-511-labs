/*****************************************************************************
* Project           : BIOS 511 Lab 2
*
* Program name      : lab-02-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-09-04
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
libname echo "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo";
footnote "ECHO Data Extract Date: 2018-09-04";

ods pdf file="C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab2\ lab-02-730120234-output.pdf";
options nodate nonumber;


/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/

proc print data = echo.dm (obs=10) label noobs;
	title 'Task1: Demographics Data for Select ECHO Trial Subjects';
	var USUBJID RFXSTDTC AGE SEX RACE ARMCD ARM COUNTRY; 
	run;


/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/

proc freq data = echo.dm;
	title 'Task2: Number and Percent of ECHO Trial Subjects by Treatment Group';
	table ARMCD / crosslist nocum nocol norow;
	run;


/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/

proc freq data = echo.dm;
	title 'Task3: Number and Percent of ECHO Trial Subjects by Treatment Group and Country';
	tables COUNTRY*ARMCD / norow nopercent;
	run;
 

/*********************************************************************
 SAS Code for Task # 4
*********************************************************************/

data dm;
	set echo.dm;
	length ageCat $10;
	if not missing(age) and age <65 then ageCat = '1: <65';
	else if age >= 65 then ageCat = '2: >= 65';
	run;

proc freq data = dm;
	title 'Task4: Number and Percent of ECHO Trial Subjects by Treatment Group and Age Category';
	tables AGECAT*ARMCD / norow nopercent missprint;
	label AGECAT = 'Age Category';
	run;


/*********************************************************************
 SAS Code for Task # 5
*********************************************************************/

proc means data = echo.dm n nmiss mean std min max;
	title 'Task5: Summary of Age for ECHO Trial Subjects';
	var AGE;
	run;


/*********************************************************************
 SAS Code for Task # 6
*********************************************************************/

proc means data = echo.dm n nmiss mean std min max fw=5;
	title 'Task6: Summary of Age for ECHO Trial Subjects by Treatment Group ';
	var AGE;
	class ARMCD;
	run;


/*********************************************************************
 SAS Code for Task # 7
*********************************************************************/

ods select Univariate.AGE.Histogram.Histogram;


proc univariate data = echo.dm;
	title 'Task7: Distribution of Age for ECHO Trial Subjects by Treatment Group';
	var AGE;
	class ARMCD;
	histogram / normal(noprint) odstitle = ' ';
	inset mean std / format=5.2;
	run;



ods pdf close;
