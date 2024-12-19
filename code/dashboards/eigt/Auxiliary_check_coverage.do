// Scatterplot by country with info (y axis) and time (x axis) coverage of the data
// Estate, Inheritance and Gift Tax

	cd "$dir"
		
// Add continent to EIG data
	use "$intfile\world_stata", clear
	drop if GEO == "-99" | name == "Ashmore and Cartier Is." | name == "Indian Ocean Ter."
	tempfile continents
	save "`continents'", replace
	
	use "$intfile\eigt_data_coverage.dta", clear	
	merge m:1 GEO using "`continents'", keep(1 3)
	tab GEO_l if _m == 1 // Gibraltar and Tokelau
	replace continent = "Europe" if GEO_l == "Gibraltar"
	replace continent = "Oceania" if GEO_l == "Tokelau"	
	replace continent = "South_America" if continent == "South America"
	replace continent = "North_America" if continent == "North America"
	replace continent = "Asia" if GEO_l == "Maldives"
	replace continent = "Africa" if GEO_l == "Mauritius"
	replace continent = "Africa" if GEO_l == "Seychelles"

	drop name _merge

	drop source percentile longname note

	keep if inlist(substr(varcode, 4, 1), "e", "c", "u")
	
	preserve 
		gen concept = substr(varcode, 10,6)	 
		* Generate the brackets for the reshape
		gen bracket = substr(varcode, -2, 2)		
		replace varcode = substr(varcode, 3,1) 

		* Reshapes 
		reshape wide value, i(GEO year concept bracket continent) j(varcode) string  
		reshape wide value*, i(GEO year bracket continent) j(concept) string 
		reshape wide value*, i(GEO year continent) j(bracket) string 
		

		* Rename the variables 
		rename value* * 
		
		foreach var in e i g t {
			rename `var'* *_`var'
		}
		
		* Select the full schedules 	
		foreach var in e i g t {
			gen full_schedule_`var' = (adjmrt01_`var' != . & exempt00_`var' != .) 
			replace full_schedule_`var' = 0 if (adjmrt01_`var' == 0 & adjubo01_`var' < 0)
			replace full_schedule_`var' = 1 if exempt00_`var' == -998 // full-exemption as knowing the exemption 
		}
		keep GEO* year full_schedule* continent
		duplicates drop 
		tempfile sched 
		save "`sched'", replace
	restore
				
	foreach tax in e i g t {

		gen status_`tax' = 1 if substr(varcode, 3, 1) == "`tax'" & ///
				substr(varcode, 10, 6) == "status" & value == 1
				
		replace status_`tax' = 0 if substr(varcode, 3, 1) == "`tax'" & ///
				substr(varcode, 10, 6) == "status" & value == 0
		
		gen first_`tax' = value if substr(varcode, 3, 1) == "`tax'" & ///
				substr(varcode, 10, 6) == "firsty"
				
		gen exempt_`tax' = value if substr(varcode, 3, 1) == "`tax'" & ///
				substr(varcode, 10, 6) == "exempt" & value == -997
		
		gen whether_exempt_`tax' = 1 if substr(varcode, 3, 1) == "`tax'" & ///
				substr(varcode, 10, 6) == "exempt"	

		gen whether_toprat_`tax' = 1 if substr(varcode, 3, 1) == "`tax'" & ///
				substr(varcode, 10, 6) == "toprat"	
	}		
	merge m:1 GEO year using "`sched'", nogen 
	
	keep GEO* year *_i *_e *_g *_t continent
	duplicates drop 
	collapse (min) *_i *_e *_g *_t, by(GEO* year continent)
	sort GEO year		   

	* Reshape
	reshape long status whether_exempt whether_toprat full_schedule, i(GEO* year continent) j(tax) string 
	replace tax = substr(tax, 2, 1)
	
	foreach tax in e i g t {
		foreach var in status whether_exempt whether_toprat full_schedule {
			preserve
				keep GEO* year tax `var' exempt_`tax' first_`tax' continent
				keep if tax == "`tax'"
				gen variable = "`tax'_`var'"
				rename `var' value
				tempfile `tax'_`var'
				save "``tax'_`var''", replace
			restore
		}
	}
	clear 
	foreach tax in e i g t {
		foreach var in status whether_exempt whether_toprat full_schedule {
			append using "``tax'_`var''"
		}
	}
	sort GEO year tax
	
	gen vars = 1 if variable == "i_status"
	replace vars = 2 if variable == "i_whether_exempt"
	replace vars = 3 if variable == "i_whether_toprat"
	replace vars = 4 if variable == "i_full_schedule"
	replace vars = 5 if variable == "e_status"
	replace vars = 6 if variable == "e_whether_exempt"
	replace vars = 7 if variable == "e_whether_toprat"
	replace vars = 8 if variable == "e_full_schedule"
	replace vars = 9 if variable == "g_status"
	replace vars = 10 if variable == "g_whether_exempt"
	replace vars = 11 if variable == "g_whether_toprat"
	replace vars = 12 if variable == "g_full_schedule"
	replace vars = 13 if variable == "t_status"
	replace vars = 14 if variable == "t_whether_exempt"
	replace vars = 15 if variable == "t_whether_toprat"
	replace vars = 16 if variable == "t_full_schedule"
	
	replace variable = "Inheritance Status" if variable == "i_status"
	replace variable = "Inheritance Exemption" if variable == "i_whether_exempt"
	replace variable = "Inheritance Top Rate" if variable == "i_whether_toprat"
	replace variable = "Inheritance Schedule" if variable == "i_full_schedule"
	replace variable = "Estate Status" if variable == "e_status"
	replace variable = "Estate Exemption" if variable == "e_whether_exempt"
	replace variable = "Estate Top Rate" if variable == "e_whether_toprat"
	replace variable = "Estate Schedule" if variable == "e_full_schedule"
	replace variable = "Gift Status" if variable == "g_status"
	replace variable = "Gift Exemption" if variable == "g_whether_exempt"
	replace variable = "Gift Top Rate" if variable == "g_whether_toprat"
	replace variable = "Gift Schedule" if variable == "g_full_schedule"
	replace variable = "Unknown EIG Status" if variable == "t_status"
	replace variable = "Unknown EIG Exemption" if variable == "t_whether_exempt"
	replace variable = "Unknown EIG Top Rate" if variable == "t_whether_toprat"
	replace variable = "Unknown EIG Schedule" if variable == "t_full_schedule"
	
	labmask vars, values(variable)

	global opt legend(order(1 "Introduction" 2 "Status Yes" 3 "Status No" 4 "Status Yes but full exemption for children" 5 "Inoformation available") rows(2) pos(6) size(vsmall) bmar(zero) region(lcolor(white))) plotreg(lcol(black) lpatt(solid) lalig(outside))

	keep if substr(GEO, 3, 1) != ","
	sort GEO year
	
cd "$hmade\taxsched_input\Data Coverage"

foreach cont in Africa Asia Europe North_America Oceania South_America {

	preserve 
		serset clear
		keep if continent == "`cont'"
		display "`cont'"
		levelsof GEO, local(levels)
		foreach l of local levels {
			
			qui count if GEO == "`l'" & year != year[_n-1]
			local n = `r(N)'
			if (`n' > 50) local n = 50
			
			tw (scatter vars year if GEO == "`l'" & vars == 1 & year == first_i, msy(dh) msize(medium) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 1 & value == 1, msy(o) msize(vsmall) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 1 & value == 0 & exempt_i != -997, msy(oh) msize(vsmall)  mlw(vthin) col(teal)) ///
			   (scatter vars year if GEO == "`l'" & vars == 1 & value == 0 & exempt_i == -997, msy(o) msize(vsmall)  mlw(vthin) col(teal)) ///
			   (scatter vars year if GEO == "`l'" & vars == 2 & value == 1, msy(x) col(purple)) ///	 
			   (scatter vars year if GEO == "`l'" & vars == 3 & value == 1, msy(x) col(purple)) ///	
			   (scatter vars year if GEO == "`l'" & vars == 4 & value == 1, msy(x) col(purple)) ///	   	   
			   (scatter vars year if GEO == "`l'" & vars == 5 & year == first_e, msy(dh) msize(medium) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 5 & value == 1, msy(o)  msize(vsmall)  col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 5 & value == 0 & exempt_e != -997, msy(oh) msize(vsmall)  mlw(vthin) col(teal)) ///
			   (scatter vars year if GEO == "`l'" & vars == 5 & value == 0 & exempt_e == -997, msy(o) msize(vsmall)  mlw(vthin) col(teal)) ///
			   (scatter vars year if GEO == "`l'" & vars == 6 & value == 1, msy(x) col(purple)) ///	 
			   (scatter vars year if GEO == "`l'" & vars == 7 & value == 1, msy(x) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 8 & value == 1, msy(x) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 9 & year == first_g, msy(dh) msize(medium) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 9 & value == 1, msy(o)  msize(vsmall)  col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 9 & value == 0 & exempt_g != -997, msy(oh) msize(vsmall)  mlw(vthin) col(teal)) ///
			   (scatter vars year if GEO == "`l'" & vars == 9 & value == 0 & exempt_g == -997, msy(o) msize(vsmall)  mlw(vthin) col(teal)) ///
			   (scatter vars year if GEO == "`l'" & vars == 10 & value == 1, msy(x) col(purple)) ///	 
			   (scatter vars year if GEO == "`l'" & vars == 11 & value == 1, msy(x) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 12 & value == 1, msy(x) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 13 & year == first_t, msy(dh) msize(medium) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 13 & value == 1, msy(o)  msize(vsmall)  col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 13 & value == 0 & exempt_t != -997, msy(oh) msize(vsmall)  mlw(vthin) col(teal)) ///
			   (scatter vars year if GEO == "`l'" & vars == 13 & value == 0 & exempt_t == -997, msy(o) msize(vsmall)  mlw(vthin) col(teal)) ///
			   (scatter vars year if GEO == "`l'" & vars == 14 & value == 1, msy(x) col(purple)) ///	 
			   (scatter vars year if GEO == "`l'" & vars == 15 & value == 1, msy(x) col(purple)) ///
			   (scatter vars year if GEO == "`l'" & vars == 16 & value == 1, msy(x) col(purple)), ///
			   xtick(#`n', grid glpattern(solid)) ///
			   ylab(1(1)16, valuelabel labsize(tiny) grid glpattern(solid)) ysc(reverse) ///
			   yscale(noextend) xscale(noextend) ysize(30) xsize(50) xtitle("") ytitle("") ///
			   xlabel(#`n', angle(90) nogrid labsize(tiny)) $opt ///
			   name(`l', replace) title("`l'", size(medsmall)) ///
			   yline(4.5, lpatt(solid)) yline(8.5, lpatt(solid)) ///
			   yline(12.5, lpatt(solid))
	   
			qui graph export `cont'/data_`l'.pdf, as(pdf) name("`l'") replace
		}
		restore
	}