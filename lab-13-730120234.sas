/*****************************************************************************
* Project           : BIOS 511 Lab 13
*
* Program name      : lab-13-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-11-29
*
* Purpose           :   
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/



%let root = C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab13;
%let echoDat = C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo;
%let analysisDat = &root.\data;
%let outputPath = &root.\output;

libname echo "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo";
libname outDat "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab13\data";


data ranges;
	infile "&analysisDat\qc_dates.csv" dlm=',';
	input Country $ Site Start_date:date9. End_date:date9. Period;
	format Start_date End_date date9.;
	if missing(Site) then delete;
run; 




data _null_;
	set ranges;
	by Country Site;
	retain site_count 0;
	if first.Site then do;
		site_count+1;
		call symputx('NUMSITES', site_count);
		call symputx('SITE'||left(site_count), Site);
	end;
run;




proc sql;
	create table outDat.subjects as
	select USUBJID, ranges.Country, Site, Period
		from echo.dm as dm, ranges as ranges
		where dm.COUNTRY = ranges.COUNTRY
			and input(substr(dm.USUBJID,7,2), 8.) = ranges.Site
			and ranges.Start_date <= mdy(input(scan(dm.RFICDTC,2,'-'), 8.),input(scan(dm.RFICDTC,3,'-'), 8.),input(scan(dm.RFICDTC,1,'-'),8.)) <= ranges.End_date;
quit;



ods noptitle; option nonumber nodate;
%macro gen_report;
	%do j = 1 %to &NUMSITES.;

		data temp;
			set outDat.subjects;
			where Site = &&SITE&J.;
			call symputx('CNT', Country);
			call symputx('SITE', Site);
		run;

		proc sql;
			create table temp2 as
				select Country, Site, Period, temp.USUBJID, VISIT, VISITNUM, VSTEST, VSSTRESN
					from temp as temp, echo.vs as vs
						where input(substr(vs.USUBJID,7,2), 8.) = temp.Site
							and vs.USUBJID = temp.USUBJID
						order by Country, Site, USUBJID, VISITNUM, Period;
		quit;


		proc transpose data = temp2 out = temp3;
			by Country Site USUBJID VISITNUM VISIT Period;
			id VSTEST;
			var VSSTRESN;
		run;

		data temp4;
			set temp3;
			label Diastolic_Blood_Pressure = 'Diastolic Blood Pressure' Height = 'Height'
					Heart_Rate = 'Heart Rate' Systolic_Blood_Pressure = 'Systolic Blood Pressure' 
					Weight = 'Weight' ID = 'Subject Number';
			ID = substr(USUBJID,10,3);
		run;

		ods pdf file="&outputPath.\&CNT._0&SITE._vital_signs.pdf"; 
		title1 "Site 0&SITE. Vital Sign Data for Select Subjects";
		proc print data = temp4 label;
			by ID;
			var VISIT Diastolic_Blood_Pressure Height Heart_Rate Systolic_Blood_Pressure Weight;
		run;
		ods pdf close;

	%end;
%mend;

%gen_report;



