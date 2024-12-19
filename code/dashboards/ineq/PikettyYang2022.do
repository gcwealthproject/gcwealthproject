clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source PikettyYang2022
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Appendix.xlsx"
local results "`sourcef'/final_table/`source'"

//import - Table Data_wealth - wealth shares (Bottom 50, Middle 40, Top 10, Top 1)
qui import excel "`rawdata'", ///
	sheet("T2")  firstrow clear

	
	// rename 
	rename Table2TopWealthShareWealt area
	rename C year
	rename D value
	
	keep area year value
	
	// Keep onlz HK row
	keep if area=="Hong Kong"
	replace area="HK"
	
	
	// Destring
	destring value , replace
	destring year, replace
	

	// varcode
		//generate code variables
		gen dashboard = "t"
		gen sector = "hs"
		gen vartype = "dsh"
		gen concept = "netwea"
		gen specific = "ia"		
	
	egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
	
	
	// in percentage
	replace value= value*100 if vartype=="dsh"
	
	// percentile
	gen percentile="p99.999p100"
	
	
	// source
	gen source = "`source'"
	
	
	//order
	order area year value percentile varcode source
	keep  area year value percentile varcode source
	
	
	//export
	qui export delimited "`results'", replace 
