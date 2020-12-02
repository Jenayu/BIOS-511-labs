%macro codebook(lib,ds,maxVal=10);


	proc contents data = &lib..&ds. out = contents varnum noprint; run;


	proc sort data=contents;
		by varnum;
	run;


	data _null_;
 		set contents;
		put _n_=;

 		call symput('var'||strip(put(_n_,best.)), strip(name));
 		call symput('label'||strip(put(_n_,best.)), strip(label));
 		call symput('type'||strip(put(_n_,best.)), type);
    	call symput('numVars',strip(put(_n_,best.)));
	run;


	%do i = 1 %to &numVars.;

		%put &&var&i &&label&i &&type&i;


		/** Character Variables -- Use PROC FREQ **/
		%if &&type&i = 2 %then %do;


			proc freq data = &lib..&ds. noprint order=freq;
				table &&var&i /nocum out = info&&var&i.;
			run;
      			

      		data _null_;
      			set info&&var&i.;
      			id=_n_;
      			call symputx('unival',id);
      		run;

			%if &unival.>&maxVal. %then %do;
	
				title1 "&maxVal. Most Frequent Values of Variable &&var&i. (&&label&i.)";
				proc print data = info&&var&i. (obs=&maxVal.) noobs label ;  
					label count = "Frequency Count" percent = "Percent of Total Frequency"; 
					format percent 6.5; 
					var &&var&i count percent;
				run;

			%end;


			%else %do;

				title1 "Frequency Analysis of Variable = &&var&i. (&&label&i.)";
				proc print data = info&&var&i. noobs label; 
					label count = "Frequency Count" percent = "Percent of Total Frequency"; 
					format percent 6.5; 
					var &&var&i count percent; 
				run;

			%end;

		%end;
		
	
     	/** Numeric Variables -- Use PROC MEANS **/
		%if &&type&i = 1 %then %do;

			title1 "Frequency Analysis of Variable = &&var&i. (&&label&i.)";
			proc means data = &lib..&ds. n nmiss mean stddev median min max maxdec=5;
				var &&var&i;
			run;

		%end;

	%end;


%mend;
