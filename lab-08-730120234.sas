/*****************************************************************************
* Project           : BIOS 511 Lab 8
*
* Program name      : lab-08-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-10-23
*
* Purpose           :   
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/



libname echo ".\datasets\echo";
libname lab8 ".\labs\lab8";

ods pdf file =".\labs\lab8\lab-08-730120234.pdf"; 
options nodate nonumber;



/*********************************************************************
 SAS Code for Task # 1 / Step # 1
*********************************************************************/

title "Task 1 - Step 1: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd;
run;



/*********************************************************************
 SAS Code for Task # 1 / Step # 2
*********************************************************************/

title "Task 1 - Step 2: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd / fillattrs=(color=lightRed) transparency=0.5;
run;



/*********************************************************************
 SAS Code for Task # 1 / Step # 3
*********************************************************************/

title "Task 1 - Step 3: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd / fillattrs=(color=lightRed) dataskin=pressed;
run;



/*********************************************************************
 SAS Code for Task # 1 / Step # 4
*********************************************************************/

title "Task 1 - Step 4: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd / fillattrs=(color=lightRed) dataskin=pressed stat=percent;
	xaxis label ='Treatment Group';
	yaxis label = 'Percent(%)';
run;



/*********************************************************************
 SAS Code for Task # 1 / Step # 5
*********************************************************************/

ods pdf nogtitle;
title "Task 1 - Step 5: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd / fillattrs=(color=lightRed) dataskin=pressed stat=percent;
	xaxis label ='Treatment Group';
	yaxis label = 'Percent(%)';
run;
ods pdf gtitle;


/*********************************************************************
 SAS Code for Task # 2 / Step # 1
*********************************************************************/

title1 "Task 2 - Step 1: Number of Subjects by Sex and Treatment Group";
proc sgplot data = echo.DM;
	vbar sex / group=armcd stat=percent;
	label armcd = 'Treatment Group';
	keylegend / position=right;
run;



/*********************************************************************
 SAS Code for Task # 2 / Step # 2
*********************************************************************/

title1 "Task 2 - Step 2: Number of Subjects by Sex and Treatment Group";
proc sgplot data = echo.DM;
	vbar sex / group=armcd groupdisplay=cluster stat=percent;
	label armcd = 'Treatment Group';
run;



/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/

data work.DM_0;
	set echo.DM;
	where country = 'USA';
	keep usubjid armcd sex age;
run;

data work.VS_0;
	set echo.vs;
	where visit = 'Screening';
run;


proc transpose data = VS_0 out = VS_1 (drop= _NAME_ _LABEL_);
	by usubjid visit;
	where vstestcd = 'DIABP' or 'SYSBP' or 'WEIGHT' or 'HEIGHT' or 'HR';
 	id vstestcd;
 	idlabel vstest;
 	var vsstresn;
run;

data work.DM_USA;
	merge DM_0 (in=indm) VS_1 (in=invs);
  	by usubjid;
	if indm and invs;
	format bmi 6.2;
	label bmi = 'Body Mass Index';
	bmi = weight/(height/100)**2;
	drop visit indm invs;
run;

/*
proc print data=DM_USA label;
run;
*/



/*********************************************************************
 SAS Code for Task # 4 / Step # 1
*********************************************************************/

title1 "Task 4 - Step 1: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	scatter x=height y=BMI;
run;



/*********************************************************************
 SAS Code for Task # 4 / Step # 2
*********************************************************************/

title1 "Task 4 - Step 2: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	scatter x=height y=BMI / markerattrs=(symbol=circleFilled color=darkBlue);
	xaxis label="Height (cm)" values=(150 to 210 by 10);
	yaxis values=(5 to 35 by 5);
run;



/*********************************************************************
 SAS Code for Task # 4 / Step # 3
*********************************************************************/

proc format;
	value $gend 'M'='Male' 'F'='Female';
run;

title1 "Task 4 - Step 3: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	format sex $gend.;
	scatter x=height y=BMI / markerattrs=(symbol=circleFilled) group=sex;
	xaxis label="Height (cm)" values=(150 to 210 by 10);
	yaxis values=(5 to 35 by 5);
run;



/*********************************************************************
 SAS Code for Task # 5 / Step # 1
*********************************************************************/

title1 "Task 5 - Step 1: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	scatter x=height y=BMI;
run;



/*********************************************************************
 SAS Code for Task # 5 / Step # 2
*********************************************************************/

ods graphics / height=4in width=4in noborder;
title1 "Task 5 - Step 2: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	scatter x=height y=BMI;
run;
ods graphics / reset=all;



/*********************************************************************
 SAS Code for Task # 6
*********************************************************************/

proc format;
	value $ trt
 	"ECHOMAX" = "Investigational Treatment"
 	"PLACEBO" = "Placebo";
run;

proc sort data = DM_USA out = DM_USA2;
	by armcd;
run;

option nobyline;
title1 "Task 6: Scatter plot of Height by Body Mass Index";
title2 "Treatment Group = #byval(armcd)";
proc sgplot data = DM_USA2 noautolegend;
	by armcd;
	format armcd $trt.;
	reg x=height y=BMI / markerattrs=(size=4 symbol=diamondFilled color=Blue) lineattrs=(pattern=2 thickness=2 color=darkRed);
run;
option byline;

ods pdf close;
