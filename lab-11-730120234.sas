/*****************************************************************************
* Project           : BIOS 511 Lab 11
*
* Program name      : lab-11-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-11-15
*
* Purpose           :   
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/


libname echo 'C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo';

%let outputPath= C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab11 ;
%let task2FName= lab-11-730120234-Task-2-output ; 
%let task3FName= lab-11-730120234-Task-3-output ;


/*********************************************************************
 SAS Code for Task # 1 
*********************************************************************/

data dm;
	set echo.dm (keep = USUBJID ARMCD);
run;

proc sort data=dm;
	by USUBJID;
run;

data vs;
	merge echo.vs dm;
	by USUBJID;
run;


/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/


%macro tst(testcd=);

data &testcd.;

	/* The SET statement's end= option tells SAS to create a temporary numeric variable called last, 
	which is initialized to 0 and set to 1 only when the set statement reads the last observation 
	in the input data set */
	set vs end=last; 

	/* The UPCASE statement convert the parameter entry testcd to uppercase to ensure 
	it matches the actual vstestcd names where vstestcd = %upcase(%testcd.) */
	where vstestcd = "%upcase(&testcd.)";

	vstest = tranwrd(vstest,'Blood Pressure' ,'BP' );

	/* Before execution, the conditional statement checks if the current observation is associated with 
	the last visit (Week 32) of the current subject */
	if last = 1 then do;
	
		/* The function symput creates a macro variable lab that takes the value of the vstest variable 
		(Vital Signs Test Name) associated with the vital sign test that matches testcd 
		and is conducted at the last visit (Week 32)
		E.g. Q: What is the lab conducted at the last visit? A: (Insert Vital Signs Test Name) */
		call symput('lab',strip(vstest));

		/* The function symput creates a macro variable unit that takes the value of the vsstresu variable 
		(Standard Units) associated with the vital sign test that matches testcd
		and is conducted at the last visit (Week 32)
		E.g. Q: In what unit are the test results at the last visit listed? A: (Insert Standard Units) */
		call symput('unit',strip(vsstresu));
	end;

	drop vstestcd vstest vsstresu vsseq vsblfl vsstat vsreasnd studyid;

	/* Since we only include the result for one vital sign test (the test which matches &testcd) here, 
	we change variable name vsstresn (Numeric Result/Finding in Standard Units) 
	to the name of the vital sign test to make the data more reader-friendly */
 	rename vsstresn = &testcd.;
run;


/* The put statement writes text or macro variable information to the SAS log. It helps with debugging as it allows us check the log to see
if we have the correct standard units and vital signs test name that matches testcd by printing out macro variables lab and unit */
%put LAB=&lab. UNIT=&unit.;

data &testcd.;
	set &testcd.;
	
	/* The label of the macro variable testcd is set to contain the vital signs test name and standard units information. 
	E.g. "Diastolic Blood Pressure (mmHg)" */
	label &testcd. = "&lab. (&unit.)";
run;
%mend;


/* These macro program executions creates three datasets, each associated with one of the three different vital sign tests */
%tst(testcd=diabp);
%tst(testcd=sysbp);
%tst(testcd=hr);


data vs_horiz;
	merge diabp sysbp hr;
	by usubjid visitnum visit;
run;


/* Since the macro variable task2FName is followed text starting with a period (.pdf), we have two periods after the macro variable name. 
The first is the delimiter for the macro reference, and the second is part of the text */
ods pdf file="&outputPath./&task2FName..pdf" style=journal;
ods graphics / height=7.25in width=7in;
option nodate nonumber;
title1 "Scatter Plot Matrix for Distolic BP, Systolic BP, and Heart Rate";
title2 "Visit = Week 32";
proc sgscatter data = vs_horiz;
	where visitnum = 5;
 	matrix diabp sysbp hr / diagonal=(histogram) group=armcd;
run;
ods graphics / reset=all;
ods pdf close;


/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/


%macro scatMat(testcdList=,visitnum=,grp=);
/* The countw function counts the number of words in a character string. We can specify a delimiter that seperate the words.
Since there is no macro function (like %countw) that has the same functionality, 
we use %sysfunc(countw(<string><,delimiter>)) to perform countw on macro variables.
Because %sysfunc is a macro function, we do not need to enclose character values in quotation marks
as we do in data step functions */
%let testnum = %sysfunc(countw(&testcdList.,|));

/* Loop over the number of tests to include */
%do i = 1 %to &testNum;

/* The %scan(argument,n<,delimiters>) macro function search argument and return the nth word. 
A word is one or more characters separated by one or more delimiters. 
Because %scan is a macro function, we do not need to enclose character values in quotation marks
as we do in data step functions */
%let testcd = %scan(&testcdList.,&i,|);

data &testcd.;
 	set vs end=last;
 	where vstestcd = "%upcase(&testcd.)";
 	vstest = tranwrd(vstest,'Blood Pressure','BP');
 	if last=1 then do;
 		call symput('lab',strip(vstest));
 		call symput('unit',strip(vsstresu));
 	end;
 	drop vstestcd vstest vsstresu vsseq vsblfl vsstat vsreasnd studyid;
 	rename vsstresn = &testcd.;
 run;

data &testcd.; 
	set &testcd.;
	label &testcd. = "&lab. (&unit.)";
run;

/* For the first loop iteration, SAS needs to set up the vs_horiz dataset, 
which contains observations associated with the inital testcd
before it can be merged with the datasets associated with the other testcds in the testcdlist created in the future loops.
Failure to do so will lead to errors at the first loop, 
since the SAS would try to merge the dataset it creates in the lines above with a nonexisting dataset called vs_horiz*/
%if &i = 1 %then %do;
	data vs_horiz;
 		set &testcd.;
 		by usubjid visitnum visit;
 	run;
%end;
%else %do;
 	data vs_horiz;
 		merge vs_horiz &testcd.;
 		by usubjid visitnum visit;
 	run;
%end;

%end;

ods graphics / height=7in width=7in;
proc sgscatter data = vs_horiz;
	where visitnum = &visitnum.;
	matrix %sysfunc(tranwrd(&testcdList.,|, )) /
 		%if &grp^= %then %do; group=&grp. %end;
 		diagonal=(histogram);
run;

%mend;



ods pdf file="&outputPath./&task3FName..pdf" style=journal;
ods graphics / height=7.25in width=7in;
 title1 "Scatter Plot Matrix for Distolic BP, Systolic BP, and Weight";
 title2 "Visit = Week 0";
 %scatMat(testcdList=DIABP|SYSBP|WEIGHT,visitnum=1);
ods pdf close;
