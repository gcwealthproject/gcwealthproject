 // translate



** Set paths here
global intermediate "${topo_dir_raw}/LWS_topo/intermediate"
global origin "${topo_dir_raw}/LWS_topo/raw data/data_download"


//import lissy output 
qui import delimited using ///
	"${origin}/lissy_output.csv", ///
	varnames(1) delimiter(comma) clear 

*summarize implicates 	
qui collapse (mean) value, by(country year variable vlabel)		

drop if variable == "hpopwgt"
rename country area
drop vlabel

// transpose the dataset, country-by-country
levelsof area, local(loc_area)
foreach c of local loc_area {
	
	preserve
	
		keep if area == "`c'"
		levelsof variable, local(loc_var)
		foreach n of local loc_var {
			gen `n' = .
			replace `n' = value if variable == "`n'"
		}	
		drop variable
		drop value
		
		collapse `loc_var' , by(year)
		
		gen area = "`c'"
		order area, first 
		
		tempfile pre_pop_`c'
		save `pre_pop_`c''
		*save "${topo_dir_raw}/LWS/auxiliary files/pre_pop_`c'", replace
 
	restore
	
}

drop _all

// append all country-level dataset
foreach c of local loc_area {
	append using `pre_pop_`c''
}


// replace 0 with missing
*foreach v of varlist ha-hlrp {
*	replace `v' = . if `v' == 0
*}

************************** INCLUDE  (hannb02) hannb08
gen hannb02=hannb*0.2
gen hannb08=hannb*0.8

save "${intermediate}/populated_grid.dta", replace

	
	
	
	
	
	
	
	
	
	
	


