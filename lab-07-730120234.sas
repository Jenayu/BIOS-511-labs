/*****************************************************************************
* Project           : BIOS 511 Lab 7
*
* Program name      : lab-07-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-10-17
*
* Purpose           :   
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/



libname lab7 "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab7";



/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/

data work.genotype;
	infile "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab7\ECHO_GENOTYPE.dat" dlm=",";
	input SITE SUBJECT GENOTYPE :$8. REASON :$20.;
	length USUBJID $12.;

	USUBJID = catx("-","ECHO",put(SITE,z3.),put(SUBJECT,z3.));

	if SUBJECT = "." then delete;
run; 

/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/

data work.dm2;
	set lab7.dm (keep=USUBJID SEX);
run;

data work.vs_baseline_dbp;
	set lab7.vs (keep=USUBJID VSTESTCD VSSTRESN VSBLFL rename=(VSSTRESN = DIABP_F));
	if VSBLFL = "Y" and VSTESTCD = "DIABP";
run;

data work.vs_week32_dbp;
	set lab7.vs (keep=USUBJID VSTESTCD VSSTRESN VISIT rename=(VSSTRESN = DIABP_L));
	if VISIT = "Week 32" and VSTESTCD = "DIABP" ;
run;

data work.vs_baseline_sbp;
	set lab7.vs (keep=USUBJID VSTESTCD VSSTRESN VSBLFL rename=(VSSTRESN = SYSBP_F));
	if VSBLFL = "Y" and VSTESTCD = "SYSBP";
run;

data work.vs_week32_sbp;
	set lab7.vs (keep=USUBJID VSTESTCD VSSTRESN VISIT rename=(VSSTRESN = SYSBP_L));
	if VISIT = "Week 32" and VSTESTCD = "SYSBP" ;
run;

data work.vs2;
	merge vs_baseline_dbp vs_week32_dbp vs_baseline_sbp vs_week32_sbp;
	by USUBJID;
	drop VSTESTCD VSBLFL VISIT;

	CHANGE_DBP = DIABP_L-DIABP_F;
	CHANGE_SBP = SYSBP_L-SYSBP_F;
run;

data work.genotype2;
	merge dm2 vs2 genotype ;
	by USUBJID;
	drop SITE SUBJECT DIABP_L DIABP_F SYSBP_L SYSBP_F;
run;



/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/

title "Summary of Change from Baseline in Systolic and Diastolic Blood Pressure by Genotype";
proc means data=genotype2 missing maxdec=2;
	label CHANGE_DBP = "Change in Diastolic Blood Pressure at 32 weeks" 
		  CHANGE_SBP = "Change in Systolic Blood Pressure at 32 weeks";
	class genotype;
	output out = work.results mean(CHANGE_DBP)=dbp mean(CHANGE_SBP)=sbp;
run;

data results;
	set results (rename=(_FREQ_=N));
	where _TYPE_=1;
	drop _TYPE_;
	if genotype = "" then genotype = "U"; 
run;



/*********************************************************************
 SAS Code for Task # 4
*********************************************************************/

proc export data=genotype2 
			file="C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab7\ECHO_GENOTYPE.xlsx" 
			dbms=xlsx 
			replace; 
	sheet="ECHO";
run;



/*********************************************************************
 SAS Code for Task # 5
*********************************************************************/

proc export data=results 
			file="C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab7\ECHO_GENOTYPE.csv" 
			dbms=csv 
			replace; 
run;
