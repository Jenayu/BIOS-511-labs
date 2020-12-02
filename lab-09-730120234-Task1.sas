/*****************************************************************************
* Project           : BIOS 511 Lab 9 Task 1
*
* Program name      : lab-09-730120234-Task1.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-11-02
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
libname lab9 "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab9";


/* Create a temporary dm dataset that only retains the desirable variables. */
data dm;
	set echo.dm (keep = STUDYID USUBJID AGE SEX RACE COUNTRY ARMCD ARM RFXSTDTC);
run;


/* Create adlb_0 dataset by merging dm and lb datasets. */
data adlb_0;
	merge dm echo.lb ;
	by USUBJID;
run;


/* Sort adlb_0 according to the following variables. */
proc sort data=adlb_0;
	by USUBJID LBTESTCD LBTEST VISITNUM VISIT LBDTC;
run;


/* Create adlb_1 dataset by adding variable LBSEQ and LBNRIND to adlb_0 dataset.
   The values of LBSEQ start at 1 for each subject and increment by 1 for each successive observation for the subject. 
   The values of LBNRIND is derived using the LBSTRESN variable: ÅgLÅh for low, ÅgNÅh for normal, ÅgHÅh for high; 
   if LBSTRESN is missing, then LBNRIND will also be missing. */
data adlb_1;
	set adlb_0;
	length LBNRIND $5;

	LBSEQ + 1;
	by USUBJID;
	if first.USUBJID then LBSEQ = 0;

	if missing(SEX) or missing(LBSTRESN) then LBNRIND = " ";
	else if LBTESTCD = "ALB" then do;
		if LBSTRESN < 35 then LBNRIND = "L";
		else if LBSTRESN > 55 then LBNRIND = "H";
		else LBNRIND = "N";
	end;
	else if LBTESTCD = "CA" then do;
		if LBSTRESN < 2.1 then LBNRIND = "L";
		else if LBSTRESN > 2.7 then LBNRIND = "H";
		else LBNRIND = "N";
	end;
	else if LBTESTCD = "HCT" then do;
		if SEX = "F" and LBSTRESN < 0.349 then LBNRIND = "L";
		else if SEX = "F" and LBSTRESN > 0.445 then LBNRIND = "H";
		else if SEX = "M" and LBSTRESN < 0.388 then LBNRIND = "L";
		else if SEX = "M" and LBSTRESN > 0.500 then LBNRIND = "H";
		else LBNRIND = "N";
	end;
run;


/* Create adlb_2 dataset from adlb_1; it only includes observations based on the conditions
   "non-missing test result" and "specimens collected on or before the date of first dose". */
data adlb_2;
	set adlb_1;

	TRTSTYR=scan(RFXSTDTC,1,'-');
	TRTSTMN=scan(RFXSTDTC,2,'-');
	TRTSTDY=scan(RFXSTDTC,3,'-');
	TRTSTDTN=MDY(TRTSTMN,TRTSTDY,TRTSTYR);

	LBSTYR=scan(LBDTC,1,'-');
	LBSTMN=scan(LBDTC,2,'-');
	LBSTDY=scan(LBDTC,3,'-');
	LBSTDY=scan(LBSTDY,1,'T');
	LBSTDTN=MDY(LBSTMN,LBSTDY,LBSTYR);

	if missing(LBSTRESN) or LBSTDTN > TRTSTDTN then delete;
	drop TRTSTYR TRTSTMN TRTSTDY LBSTYR LBSTMN LBSTDY;
run;


/* Sort adlb_2 according to the following variables. */
proc sort data=adlb_2;
	by USUBJID LBTESTCD LBTEST VISITNUM VISIT LBDTC;
run;


/*  Create adlb_3 dataset from adlb_2; it only includes 
	the latest observation for each test conducted on each subject, whose LBBLBL = "Y". */
data adlb_3;
	set adlb_2;
	by USUBJID LBTESTCD;
	length LBBLFL $1;
	if not last.LBTESTCD then delete;
	LBBLFL = "Y";
	drop LBSTDTN TRTSTDTN;
run;


/* Create adlb_4 dataset by merging adlb_1 and adlb_3. */
data adlb_4;
	merge adlb_1 adlb_3;
	by USUBJID LBTESTCD LBTEST VISITNUM VISIT LBDTC;
run;


/* Create adlb_5 dataset from adlb_3; it only includes 
	the latest observation for each test conducted on each subject
	as well as the desirable variables. */
data adlb_5;
	set adlb_3 (keep = USUBJID LBTESTCD LBSTRESN LBNRIND);
	length BASE 8 BASECAT $1;
	BASE = LBSTRESN;
	BASECAT = LBNRIND;
run;


/* Create adlb_6 dataset by merging adlb_5 and adlb_4 
   and by adding the variable BASE and BASECAT for each test conducted on each subject, 
   which is set to the value of LBSTRESN and LBNRIND from the observation where LBBLFL = ÅY */
data adlb_6;
	merge adlb_5 adlb_4;
	by USUBJID LBTESTCD;
	length CHANGE 8 PCT_CHANGE 8;
	CHANGE = LBSTRESN-BASE;
	PCT_CHANGE = (LBSTRESN-BASE)/BASE*100;
run;


/* Reorder and label the variables and create the permanent dataset adlb. */
data lab9.adlb;
	retain STUDYID USUBJID AGE SEX RACE COUNTRY ARMCD ARM LBSEQ LBTESTCD LBTEST LBCAT
		  LBSTRESN LBSTRESU LBNRIND LBSTAT LBREASND LBBLFL BASE BASECAT CHANGE PCT_CHANGE
		  VISITNUM VISIT LBDTC;
	label LBSEQ = "Sequence Number" LBNRIND = "Reference Range Indicator" LBBLFL = "Baseline Flag" 
		  BASE = "Baseline Lab Test Value" BASECAT = "Baseline Reference Range Indicator"
		  CHANGE = "Change from Baseline " PCT_CHANGE = "Percent Change from Baseline";
	set adlb_6;
run;


