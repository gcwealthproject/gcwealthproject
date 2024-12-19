//settings
clear all

local source Smith2023
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/TotalWealthShare.xlsx"
local results "`sourcef'/final_table/`source'"

//import 
qui import excel "`rawdata'", ///
	sheet("Baseline") cellrange (A2:F53) firstrow clear
//clean
rename (Year Bottom90 Top01 Top001) (year Top990 Top901 Top9001)
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p90" if percentiles==990
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
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
gen specific = "es"
//Note that the unit of analysis is assumed to be the same as Smith2020
egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//export
qui export delimited "`results'", replace 
