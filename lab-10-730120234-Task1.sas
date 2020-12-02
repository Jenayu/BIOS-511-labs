/*****************************************************************************
* Project           : BIOS 511 Lab 10 Task 1
*
* Program name      : lab-10-730120234-Task1.sas
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


proc print data=echo.pc;
	where USUBJID in ("ECHO-011-001", "ECHO-019-018");
run;

