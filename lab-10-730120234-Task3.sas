/*****************************************************************************
* Project           : BIOS 511 Lab 10 Task 3
*
* Program name      : lab-10-730120234-Task3.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-11-09
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
libname lab10 ".\labs\lab10";
option nonumber nodate;
ods noptitle;


data pc_0;
	set echo.pc;
	by USUBJID;
	label HOURS = 'Hours Post Dose';
	if scan(PCSTRESC,1,"0") = "<" then PCSTRESN = input(scan(PCSTRESC,1,"<"),best.);
	HOURS = input(scan(PCTPT,1," "),best.);

	retain AUC12;

  	PREVHOURS = lag(HOURS);
  	PREVVALUE  = lag(PCSTRESN);

  	if first.USUBJID then AUC12 = 0;
  	else AUC12 = AUC12 + 0.5*(PCSTRESN+PREVVALUE)*(HOURS-PREVHOURS);

  	if last.USUBJID and AUC12>.;

  	keep USUBJID AUC12;

	file ".\labs\lab10\ECHO_AUC.csv" dlm=",";
	put USUBJID AUC12;
run;
