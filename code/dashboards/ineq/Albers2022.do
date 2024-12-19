//settings
clear all
local source Albers2022
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Wealth_LuisFilip.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares 
qui import excel "`rawdata'", ///
	sheet("Top wealth shares") cellrange (A1:E34) firstrow clear
//clean
gen Top900 = 100 - topsh9000
gen Top9099 = topsh9000 - topsh9900
gen Top9095 = topsh9000 - topsh9500
gen Top9599 = topsh9500 - topsh9900

qui rename (topsh9000 topsh9500 topsh9900 topsh9990) (Top10 Top5 Top1 Top9001)
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p90" if percentiles==900
qui replace percentile = "p99.9p100" if percentiles==9001
qui replace percentile = "p90p95" if percentiles==9095
qui replace percentile = "p90p99" if percentiles==9099
qui replace percentile = "p95p99" if percentiles==9599
drop percentiles
//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = ""
qui replace specific = "ho" if year >= 1993
qui replace specific = "tu" if year < 1993

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "DE"
gen source = "`source'"

//export
qui export delimited "`results'", replace 
