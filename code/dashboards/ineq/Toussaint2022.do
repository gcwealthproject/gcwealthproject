clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Toussaint2022
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/WealthNLD_Tou.xlsx"
local results "`sourcef'/final_table/`source'"

//import 
qui import excel "`rawdata'", ///
	sheet("Wealth Shares")  firstrow clear

	

********************************************************************************		
/* 
What We Need:
	
	A)Wealth shares (top 0.1%, 1%, & 5%)
	--> both Raw and MA series
*/
********************************************************************************	

drop E F

ds *Unadj 
local varlist=r(varlist)

foreach var in `varlist' {
	preserve
		keep Year `var'
		rename Year year
		gen info="`var'"
		rename `var' value
		gen area="NL"
		drop if value==.
		tempfile a`var'
		save `a`var'', replace
	restore
}

clear
foreach var in `varlist' {
	append using `a`var''
}


	// varcode
		//generate code variables
		gen h_dashboard = "t"
		gen h_sector = "hs"
		gen h_vartype = "dsh"
		gen h_concept = "netwea"
		
		
		gen h_specific = "tu"			
		replace h_specific = "ho" if year>=1993
		// From Meth Tables:
		//1894 – 1993: Tax units ("the historical wealth tax did not apply to households, but to natural persons […] Married couples were treated as a single natural person for tax purposes," p. 10).
		//1993 – 2019: Households
		
		
		egen varcode = concat(h_dashboard h_sector h_vartype h_concept h_specific), ///
		punct ("-") 
		
		drop h_*

	
	// in percentage
	replace value= value*100 
	
	// percentile
	gen percentile=""
	replace percentile="p99.9p100" 	if info=="Top01Unadj"
	replace percentile="p99p100" 	if info=="Top1Unadj"
	replace percentile="p95p100" 	if info=="Top5Unadj"
	
	
	// source
	gen source = "`source'"
	
	
	//order
	order area year value percentile varcode source
	keep  area year value percentile varcode source
	

	
//export
qui export delimited "`results'", replace 
