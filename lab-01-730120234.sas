/*****************************************************************************
* Project           : BIOS 511 Lab 1
*
* Program name      : lab-01-730120234.sas
*
* Author            : Jennifer Chen
*
* Date created      : 2018-08-28
*
* Purpose           : This program helps me learn about the Out Put Delivery System    
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
******************************************************************************/



ods noproctitle;

libname orion ".\datasets";



proc print data=orion.employee_payroll (obs=10);
	title 'First 10 Observations of Employee Payroll Data Set';
run;

proc univariate data=orion.employee_payroll;
	var salary;
	title 'Descriptive Statistics for Salary';
run;



*This section turns on the traces of the output objects in the log;
ods trace on;

proc print data=orion.employee_payroll (obs=10);
	title 'First 10 Observations of Employee Payroll Data Set';
run;

proc univariate data=orion.employee_payroll;
	var salary;
	title 'Descriptive Statistics for Salary';
run;

ods trace off;



*This section leaves no output destination (for the temporary html output file) active
*And thus no result is printed;
ods html close;

proc print data=orion.employee_payroll (obs=10);
	title 'First 10 Observations of Employee Payroll Data Set';
run;

proc univariate data=orion.employee_payroll;
	var salary;
	title 'Descriptive Statistics for Salary';
run;


*This section creates a PDF output file;
ods pdf file=".\labs\outputs\output1\freq9.pdf";

proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;

ods pdf close;


*This section creates an RTF output file;
ods rtf file =".\labs\outputs\output1\freq10.rtf";

proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;

ods rtf close;


*This section creates an RTF output file with its title plugged the body;
ods rtf file =".\labs\outputs\output1\freq10_bodytitle.rtf" bodytitle;

proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;

ods rtf close;



*This section creates an HTML output file;
ods html file = ".\labs\outputs\output1\freq11.html";

proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;

ods html close;



*This section selects which results include in the output;
ods pdf file = ".\labs\outputs\output1\select_exclude13.pdf";

title "Moment and Extreme Observations";
ods select moments extremeobs;
proc univariate data=orion.employee_payroll;
	var salary;
run;

title "Basic Measures, Tests for Location, and Quantiles";
ods exclude moments extremeobs;
proc univariate data=orion.employee_payroll;
	var salary;
run;

title "All Univariate Procedure Output";
proc univariate data=orion.employee_payroll;
	var salary;
run;

ods pdf close;


*This section creates a new temporary dataset with an object;
ods pdf file=".\labs\outputs\output1\ods_output_15.pdf";

* A new temporary dataset work.salary_quant is made from the "Quantiles" ODS object;
ods pdf select quantiles;
ods output quantiles = salary_quant;
proc univariate data=orion.employee_payroll;
	var salary;
run;

title "Quantiles for Salary Variable";
proc print data = salary_quant; run;

ods pdf close;



*This section selects the text styles for the output;
ods pdf file =".\labs\outputs\output1\fav_style17.pdf" style=journal;

proc freq data=orion.customer;
	tables country gender country*gender;
	title "Frequency Distributions and Cross tabulations";
run;

ods pdf close; 



*This section select whether to insert a new page at the beginning of each procedure's output;
ods pdf file = ".\labs\outputs\output1\start_page18.pdf"
	style = journal
	startpage = no;

title1 'Descriptive Statistics for Price Variable';
proc means data=orion.employee_payroll;
	class employee_gender;
	var salary;
run;

ods pdf startpage=now;

ods select extremeobs;
proc univariate data=orion.employee_payroll;
	var salary;
run;

ods pdf close;




ods pdf file =".\labs\outputs\output1\contents19.pdf";

ods select variables;
proc contents data=orion.employee_payroll;
run;

ods select variables;
proc contents data=orion.employee_addresses;
run;

ods select variables;
proc contents data=orion.employee_donations;
run;

ods pdf close; 
