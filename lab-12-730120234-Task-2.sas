/*****************************************************************************
* Project           : BIOS 511 Lab 12 Task 2 
*
* Program name      : lab-12-730120234-Task-2.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-11-25
*
* Purpose           :   
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/


%let root = C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\labs\lab12;
%let echoDat = C:\Users\Jennifer Chen\Documents\course documents\fall 2018\bios 511\datasets\echo;
%let analysisDat = &root.\data;
%let outputPath = &root.\output;
%let macroPath = &root.\macros;

libname out "&analysisDat." access=read;
libname echo "&echoDat." access=read;

option mprint mlogic;

ods noptitle; option nonumber nodate;
%include "&macroPath.\codebook-730120234.sas";

ods pdf file="&outputPath.\ADSL_CODEBOOK.pdf" style=sasweb;
	%codebook(lib=out,ds=adsl,maxVal=15);
ods pdf close;

ods pdf file="&outputPath.\DM_CODEBOOK.pdf" style=sasweb;
 	%codebook(lib=echo,ds=dm);
ods pdf close;
