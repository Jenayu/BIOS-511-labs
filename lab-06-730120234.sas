/*****************************************************************************
* Project           : BIOS 511 Lab 6
*
* Program name      : lab-06-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-10-02
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
libname lab6 ".\labs\lab6";



/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/



proc print data=echo.vs;
	where USUBJID="ECHO-011-001";
run;



/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/



data work.diabp;
	set echo.vs (rename = (VSSTRESN = DIABP));
	where VSTESTCD = "DIABP";
run;

proc sort data = diabp; by USUBJID VISITNUM; run;

data work.sysbp;
	set echo.vs (rename = (VSSTRESN = SYSBP));
	where VSTESTCD = "SYSBP";
run;

proc sort data = sysbp; by USUBJID VISITNUM; run;

data work.bp1;
	merge diabp sysbp;
 	by USUBJID VISITNUM;
 	keep USUBJID VISITNUM VISIT SYSBP DIABP;
run;



proc sort data = echo.vs out = work.VS;
	by USUBJID VISITNUM VISIT VSTESTCD;
	where  VSTESTCD = "DIABP" or "SYSBP";
run;

data bp2;
	set work.vs;
	by USUBJID VISITNUM;
	retain SYSBP DIABP;
	if FIRST.USUBJID and FIRST.VISITNUM then do;
 		SYSBP = .;
 		DIABP = .;
	end;
	if VSTESTCD = 'SYSBP' then SYSBP = VSSTRESN;
	if VSTESTCD = 'DIABP' then DIABP = VSSTRESN;
	if LAST.VISITNUM then output;
	keep USUBJID VISITNUM VISIT SYSBP DIABP;
run;



proc sort data = echo.vs out = vs;
	by USUBJID VISITNUM VISIT VSTESTCD;
run;

proc transpose data = vs out = bp3 (drop= _NAME_ _LABEL_ HEIGHT HR WEIGHT);
by usubjid visitnum visit;
where VSTESTCD = "DIABP" or "SYSBP";
 id vstestcd;
 idlabel vstest;
 var vsstresn;
run;



/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/



data work.vs;
	set echo.vs;
	where VSTESTCD in ('DIABP' 'SYSBP');
run;

proc sort data = work.vs; 
	by USUBJID VISITNUM VISIT VSTESTCD; 
run;


data lab6.bp4;
	set work.vs;
	by USUBJID VISITNUM VISIT VSTESTCD;
	retain DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32 SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;
	array bp[2,6] DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32 SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;

	if first.usubjid then do;
		dbp_scr=.; dbp_wk00=.; dbp_wk08=.; dbp_wk16=.; dbp_wk24=.; dbp_wk32=.;
		sbp_scr=.; sbp_wk00=.; sbp_wk08=.; sbp_wk16=.; sbp_wk24=.; sbp_wk32=.;
	end;

	if vstestcd = 'DIABP' then array_row = 1;
	else if vstestcd = 'SYSBP' then array_row = 2;

	if VISITNUM = -1 then array_col = 1;
	else                  array_col = VISITNUM + 1;

	bp[array_row,array_col] = VSSTRESN;

	if last.usubjid then output;

	keep USUBJID VISITNUM VISIT DBP: SBP: ;
run;



/*********************************************************************
 SAS Code for Task # 4
*********************************************************************/



data work.bp5;
	set echo.vs;
	where VSTESTCD in ('DIABP' 'SYSBP');
	length VARNAME $20.;

	if VSTESTCD='DIABP' then VARNAME='DBP_';
	else VARNAME='SBP_';	
		
	if VISITNUM=-1 then varName=cats(varName,'SCR');
	else if VISITNUM = 1 then varName=cats(varName,'WK00');
	else if VISITNUM = 2 then varName=cats(varName,'WK08');
	else if VISITNUM = 3 then varName=cats(varName,'WK16');
	else if VISITNUM = 4 then varName=cats(varName,'WK24');
	else if VISITNUM = 5 then varName=cats(varName,'WK32');

run; 

proc sort data=bp5;
	by USUBJID VISITNUM VISIT VSTESTCD; 
run;

proc transpose data=bp5 out=lab6.bp5 (drop=_NAME_ _LABEL_);
	by USUBJID;
	id VARNAME;
	var VSSTRESN;
run;


