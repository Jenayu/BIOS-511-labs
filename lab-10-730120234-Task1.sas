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


libname echo "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo";
libname lab10 "C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab10";


proc print data=echo.pc;
	where USUBJID in ("ECHO-011-001", "ECHO-019-018");
run;

