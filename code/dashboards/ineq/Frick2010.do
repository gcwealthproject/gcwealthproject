//settings
clear all
local source Frick2010
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Frick_et_al_2010.xlsx"
local results "`sourcef'/final_table/`source'"

//import and clean  - wealth shares - quarters averages
qui import excel "`rawdata'", ///
	sheet("translate") firstrow clear

 qui rename (average Gini Top10 Bottom50) (Top111 Top222 Top555 Top950)	
//clean

reshape long Top, i(year) j(percentiles)

//rename percentiles 
gen percentile = ""
qui replace percentile = "p1p100" if percentiles==111
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p90p100" if percentiles==555
qui replace percentile = "p0p100" if percentiles==222
drop percentiles

//reshape

//gen value
rename Top value
//drop missing
drop if missing(value)
qui replace value = value*1000 if percentile== "p1p100"
qui replace value = value*100 if percentile== "p0p100"

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ia"

qui replace vartype = "gin" if percentile=="p0p100"
qui replace vartype = "avg" if percentile=="p1p100"
qui replace percentile = "p0p100" if percentile == "p0p100"

drop if vartype == "avg"
egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "DE"
gen source = "`source'"

//generate longname 1-2 
//run $fill_longname 

//export
qui export delimited "`results'", replace 
