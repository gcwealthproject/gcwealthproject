//settings
clear all

local source MartinezToledano2022
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Wealth_Inequality_Spain.xlsx"
local results "`sourcef'/final_table/`source'"

//import 
qui import excel "`rawdata'", sheet("import") firstrow clear

//clean
keep year Bottom99 Bottom90 Bottom50 Middle40 Top10 Top5 Top1 Top01 Top001 ///
	Top10to1 Top10to5 Top5to1
rename (Top01 Top001 Middle40) (Top901 Top9001 Top940)
rename (Bottom99 Bottom90 Bottom50) (Top999 Top990 Top950)
rename (Top10to1 Top10to5 Top5to1) (Top101 Top105 Top51)
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p0p99" if percentiles==999
qui replace percentile = "p0p90" if percentiles==990
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p99" if percentiles==101
qui replace percentile = "p90p95" if percentiles==105
qui replace percentile = "p95p99" if percentiles==51
drop percentiles
//gen value
rename Top value
qui replace value = value * 100
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "es"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "ES"
gen source = "`source'"
//export
qui export delimited "`results'", replace 
