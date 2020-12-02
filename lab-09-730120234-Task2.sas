/*****************************************************************************
* Project           : BIOS 511 Lab 9 Task 2
*
* Program name      : lab-09-730120234-Task2.sas
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


libname echo ".\datasets\echo";
libname lab9 ".\labs\lab9";

ods pdf file=".\labs\lab9\lab-09-730120234-output.pdf";
options nodate nonumber;
option papersize = (10in 15in);


data adlb_alb;
	set lab9.adlb;
	if LBTESTCD ~= "ALB" then delete;
	if LBBLFL = "Y" then GRAPHCAT = "Baseline";
	else if VISIT = "Week 16" then GRAPHCAT = "Week 16";
	else if VISIT = "Week 32" then GRAPHCAT = "Week 32";
	if missing(PCT_CHANGE) or missing(GRAPHCAT) then delete;
run; 

proc means data=adlb_alb noprint;
	class COUNTRY ARMCD GRAPHCAT;
	var PCT_CHANGE;
	output out = input_1 mean(PCT_CHANGE)=MEAN_PCT lclm(PCT_CHANGE)=LCLM_PCT uclm(PCT_CHANGE)=UCLM_PCT;
run;

data input_alb;
	set input_1;
	if _TYPE_~=3 and _TYPE_~=7 then delete;
	if missing(COUNTRY) then COUNTRY = "ALL";
	drop _TYPE_;
run;


data adlb_ca;
	set lab9.adlb;
	length GRAPHCAT $20;
	if LBTESTCD ~= "CA" then delete;
	if LBBLFL = "Y" then GRAPHCAT = "Baseline";
	else if VISIT = "Week 16" then GRAPHCAT = "Week 16";
	else if VISIT = "Week 32" then GRAPHCAT = "Week 32";
	if missing(PCT_CHANGE) or missing(GRAPHCAT) then delete;
run; 

proc means data=adlb_ca noprint;
	class COUNTRY ARMCD GRAPHCAT;
	var PCT_CHANGE;
	output out = input_2 mean(PCT_CHANGE)=MEAN_PCT lclm(PCT_CHANGE)=LCLM_PCT uclm(PCT_CHANGE)=UCLM_PCT;
run;

data input_ca;
	set input_2;
	if _TYPE_~=3 and _TYPE_~=7 then delete;
	if missing(COUNTRY) then COUNTRY = "ALL";
	drop _TYPE_;
run;


data adlb_hct;
	set lab9.adlb;
	length GRAPHCAT $20;
	if LBTESTCD ~= "HCT" then delete;
	if LBBLFL = "Y" then GRAPHCAT = "Baseline";
	else if VISIT = "Week 16" then GRAPHCAT = "Week 16";
	else if VISIT = "Week 32" then GRAPHCAT = "Week 32";
	if missing(PCT_CHANGE) or missing(GRAPHCAT) then delete;
run; 

proc means data=adlb_hct noprint;
	class COUNTRY ARMCD GRAPHCAT;
	var PCT_CHANGE;
	output out = input_3 mean(PCT_CHANGE)=MEAN_PCT lclm(PCT_CHANGE)=LCLM_PCT uclm(PCT_CHANGE)=UCLM_PCT;
run;

data input_hct;
	set input_3;
	if _TYPE_~=3 and _TYPE_~=7 then delete;
	if missing(COUNTRY) then COUNTRY = "ALL";
	drop _TYPE_;
run;


proc format;
 value $countryfmt
 "ALL" = "Overall"
 "CAN" = "Canada"
 "MEX" = "Mexico"
 "USA" = "United States";
run;


ods graphics / height=4.5in width=8in;
title1 "Plot of Percent Change in Albumin by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
proc sgpanel data = input_alb;
	format COUNTRY $countryfmt.;
	panelby COUNTRY / columns= 4 layout = COLUMNLATTICE;

	highlow x=GRAPHCAT low=LCLM_PCT high=UCLM_PCT / group=ARMCD highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;
	series x=GRAPHCAT y=MEAN_PCT / markers markerattrs=(symbol=CircleFilled) group=ARMCD groupdisplay=cluster clusterwidth=0.2;

	rowaxis label = "Percent Change from Baseline";
  	colaxis label = 'Visit Name' type=discrete values=('Baseline' 'Week 16' 'Week 32');

	colaxistable _FREQ_ / class = ARMCD;
run;


title1 "Plot of Percent Change in Calcium by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
proc sgpanel data = input_ca;
	format COUNTRY $countryfmt.;
	panelby COUNTRY / columns= 4 layout = COLUMNLATTICE;

	highlow x=GRAPHCAT low=LCLM_PCT high=UCLM_PCT / group=ARMCD highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;
	series x=GRAPHCAT y=MEAN_PCT / markers markerattrs=(symbol=CircleFilled) group=ARMCD groupdisplay=cluster clusterwidth=0.2;

	rowaxis label = "Percent Change from Baseline";
  	colaxis label = 'Visit Name' type=discrete values=('Baseline' 'Week 16' 'Week 32');

	colaxistable _FREQ_ / class = ARMCD;
run;


title1 "Plot of Percent Change in Hematocrit by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
proc sgpanel data = input_hct;
	format COUNTRY $countryfmt.;
	panelby COUNTRY / columns= 4 layout = COLUMNLATTICE;

	highlow x=GRAPHCAT low=LCLM_PCT high=UCLM_PCT / group=ARMCD highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;
	series x=GRAPHCAT y=MEAN_PCT / markers markerattrs=(symbol=CircleFilled) group=ARMCD groupdisplay=cluster clusterwidth=0.2;

	rowaxis label = "Percent Change from Baseline";
  	colaxis label = 'Visit Name' type=discrete values=('Baseline' 'Week 16' 'Week 32');

	colaxistable _FREQ_ / class = ARMCD;
run;
ods graphics / reset=all;


ods pdf close;
