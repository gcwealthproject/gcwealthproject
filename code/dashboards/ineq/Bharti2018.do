//settings
clear all
local source Bharti2018
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Bharti 2018.xlsx"
local results "`sourcef'/final_table/`source'"

//import and clean  - wealth shares - quarters averages
qui import excel "`rawdata'", ///
	sheet("Table 8") cellrange (P4:V6) firstrow clear
//clean
qui rename (Q R V) (Top10 Top5 Top91000)
qui rename (S T U) (Top1 Top910 Top9100)
//reshape
reshape long Top, i(year) j(percentiles)

//rename percentiles 
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99.9p100" if percentiles==910
qui replace percentile = "p99.99p100" if percentiles==9100
qui replace percentile = "p99.999p100" if percentiles==91000
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
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "IN"
gen source = "`source'"

//export
qui export delimited "`results'", replace 
