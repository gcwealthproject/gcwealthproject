clear all
local source vonFintel2020
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/vonFintel.xlsx"
local results "`sourcef'/final_table/`source'"

///import - shares 
qui import excel "`rawdata'", ///
	sheet("shares") firstrow clear
	
//clean
drop G α15
qui rename (Middle40 Bottom50 Gini) (Top940 Top950 Top555)
//reshape 
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p0p100" if percentiles==555

drop percentiles

//gen value
rename Top value
qui replace value = value*100
//drop missing
drop if missing(value)
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
	qui replace vartype = "gin" if percentile =="p0p100"
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "ZA"
gen source = "vonFintel2020"
//order
order area year value percentile varcode
//export
qui export delimited "`results'", replace 
