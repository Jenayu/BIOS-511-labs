/*****************************************************************************
* Project           : BIOS 511 Lab 4
*
* Program name      : lab-04-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-09-20
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

ods html file='.\labs\lab4\lab-04-730120234-output.html';

libname echo ".\datasets\echo";

footnote "ECHO Data Extract Date: 2018-09-20";



/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/

ods trace on;
ods select Position;
title1 'Task 1: Variables Contained in the AE Dataset';
proc contents data=echo.ae varnum;
run;



/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/


proc sort data=echo.dm out=dm_sorted;
	by USUBJID;
run;

title1 'Task 2 / Part 1: First 5 Observations in the DM Dataset';
proc print data=dm_sorted (obs=5);
run;


proc sort data=echo.ae out=ae_sorted;
	by USUBJID;
run;

title1 'Task 2 / Part 2: First 5 Observations in the AE Dataset';
proc print data=dm_sorted (obs=5);
run;



/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/


data work.ae2;
	merge work.dm_sorted(keep=USUBJID ARMCD SEX RACE COUNTRY RFXSTDTC RFXENDTC) work.ae_sorted;
	by usubjid;
 	if (aeterm > '');
	drop studyid;
run;

title1 'Task 3 / Part 1: First 15 Observations in the AE2 Dataset';
proc print data=ae2 (obs=15);
run;


data work.adem;
	merge work.dm_sorted(keep=USUBJID ARMCD SEX RACE COUNTRY RFXSTDTC RFXENDTC) work.ae_sorted;
	by usubjid;
	/*
 	if (aeterm > '');
	*/
 	drop studyid;
run;

title1 'Task 3 / Part 2: First 15 Observations in the AEDM Dataset';
proc print data=adem (obs=15);
run;



/*********************************************************************
 SAS Code for Task # 4
*********************************************************************/


data work.teaefn;

	set ae2;

	label AESTDTI = 'Imputed AE Onset Date (Numeric)'
		  TRTSTDTN = 'Treatment Start Date (Numeric)';
	format AESTDTI TRTSTDTN date9.;

	AESTYR = scan(AESTDTC,1,'-');
	AESTMN = scan(AESTDTC,2,'-');
	AESTDY = scan(AESTDTC,3,'-');
	if AESTDY = '' then AESTDY = 28;

	TRTSTYR = scan(RFXSTDTC,1,'-');
	TRTSTMN = scan(RFXSTDTC,2,'-');
	TRTSTDY = scan(RFXSTDTC,3,'-');
	if TRTSTDY = '' then TRTSTDY = 28;

	AESTDTI = MDY(AESTMN,AESTDY,AESTYR);
	TRTSTDTN = MDY(TRTSTMN,TRTSTDY,TRTSTYR);

	if AESTDTI<TRTSTDTN then TEAEFN = 0;
 	else TEAEFN = 1;

	drop AESTYR AESTMN AESTDY TRTSTYR TRTSTMN TRTSTDY;

run;



/*********************************************************************
 SAS Code for Task # 5
*********************************************************************/


title1 'Task 5: Listing of Treatment Emergment AEs with Date Imputation by Country';
title2 'System Organ Class = Infections and Infestations';
proc print data = teaefn noobs label;
	where upcase(AESOC) = 'INFECTIONS AND INFESTATIONS' and scan(AESTDTC,3,'-') ='' ;
	var USUBJID AETERM AEDECOD AESTDTC AESTDTI TRTSTDTN;
run;
