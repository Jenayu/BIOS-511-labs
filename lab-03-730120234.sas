/*****************************************************************************
* Project           : BIOS 511 Lab 3
*
* Program name      : lab-03-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-09-13
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
ods html file='C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab3\lab-03-730120234-output.html';

libname echo "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo";

footnote "ECHO Data Extract Date: 2018-09-13";

/*ods pdf file="C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab3\lab-03-730120234-output.pdf";
/*options nodate nonumber;



/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/


data DM_TASK1;

	set echo.dm_invnam;
	if AGE ^= '.';

	length AGECAT $5;

	if AGE='.' then AGECAT = '.';
	else if AGE<65 then AGECAT = "<65";
	else if AGE>=65 then AGECAT = ">=65";

	if AGE='.' then AGECATN = 99;
	else AGECATN = 1+(AGE>=65);

run;


/*
proc freq data = DM_TASK1;
 table age*agecatn*ageCat / list missing nocum nopercent;
run;
*/


proc format; 
	value $fmt 'ECHOMAX' = 'Intervention'
			   'PLACEBO' = 'Placebo';
run;

ods select CrossTabFreqs ChiSq;
title 'Task 1 / Step 4: Two-Way Frequency Analysis of Treatment Group by Age Category';

proc freq data = DM_TASK1;
	label AGECAT = 'Age Category'
		  ARMCD = 'Treatment Group';
	tables AGECAT*ARMCD / norow nopercent chisq;
	format ARMCD $fmt.;

run;



/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/


proc sort data = echo.dm_invnam out = INVESTIGATORS1(keep = COUNTRY SITEID INVNAM) nodupkey;
	by SITEID INVNAM;
run;


data INVESTIGATORS2;

	set INVESTIGATORS1;

	length FIRSTNAME LASTNAME $30 COUNTRY_LONG $10; 
	
	label FIRSTNAME = 'Investigator First Name'
		  LASTNAME = 'Investigator Last Name'
		  COUNTRY_LONG = 'Country Name';

	LASTNAME = strip(propcase(scan(INVNAM ,1,',')));
	FIRSTNAME = strip(propcase(scan(INVNAM,2,',')));

	if COUNTRY = 'USA' then do; COUNTRY_ORDER = 1; COUNTRY_LONG = "USA"; end;
	else if COUNTRY = 'MEX' then do; COUNTRY_ORDER = 2; COUNTRY_LONG = "Mexico"; end;
	else if COUNTRY = 'CAN' then do; COUNTRY_ORDER = 3; COUNTRY_LONG = "Canada"; end;

run;


proc sort data = INVESTIGATORS2;
	by COUNTRY_ORDER COUNTRY_LONG;
run;


title1 "Task 2 / Step 4: Listing of ECHO Trial Investigators";
title2 "Country = #byval(COUNTRY_LONG)";
options nobyline;
proc print data = INVESTIGATORS2 label noobs;
	label SITEID = 'Study Site Identifier';
	by COUNTRY_ORDER COUNTRY_LONG;
	var SITEID LASTNAME FIRSTNAME;
run;



/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/


data DM_TASK3;
	
	set echo.DM_INVNAM;

	length FIRSTNAME LASTNAME $30 ICYEAR ICMONTH ICDAY $5 RFICDTC3 RFICDTC4 RFICDTC5 $20 RACECAT $30;;

	COMMA_SPOT=index(invnam,',');
	LASTNAME=propcase(substr(invnam,1,COMMA_SPOT-1));
	FIRSTNAME=propcase(substr(invnam,COMMA_SPOT+1));

	ICYEAR=scan(RFICDTC,1);
	ICMONTH=scan(RFICDTC,2);
	ICDAY=scan(RFICDTC,3);

	RFICDTC3=strip(ICYEAR) || '-' || strip(ICMONTH) || '-' || strip(ICDAY);
	RFICDTC4=cats(ICYEAR,'-', ICMONTH,'-', ICDAY);
	RFICDTC5=catx('-',ICYEAR,ICMONTH,ICDAY);

	if RACE='WHITE' then RACECAT='White';
	else if RACE='BLACK OR AFRICAN AMERICAN' then racecat='Black or African American';
	else RACECAT='Other';	
		
	RACECAT=tranwrd(propcase(RACE),'Or','or');
	if RACECAT~='White' and RACECAT~='Black or African American' then RACECAT='Other';

	drop comma_spot;

run; 


title 'Task 3 / Step 2: Print Out of Derived Variables for Site 011';
proc print data=DM_TASK3 (obs=10) noobs;
	where SITEID='011';
	var INVNAM FIRSTNAME LASTNAME RFICDTC ICYEAR ICMONTH ICDAY RFICDTC3 RFICDTC4 RFICDTC5 RACE RACECAT;
run;

ods html close;
