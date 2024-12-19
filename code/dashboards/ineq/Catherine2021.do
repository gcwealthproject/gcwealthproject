//settings
clear all

local source Catherine2021
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/allShares.dta"
local results "`sourcef'/final_table/`source'"

//import
use "`rawdata'", clear 
//clean
keep year ss_t10_shr_s1 ss_t1_shr_s1 ss_t01_shr_s1 ss_t001_shr_s1
rename (ss_t10_shr_s1 ss_t1_shr_s1) (Top10 Top1)
rename (ss_t01_shr_s1 ss_t001_shr_s1) (Top901 Top9001)

gen Top9099 = Top10 - Top1 
gen Top900 = 1 - Top10
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
qui replace percentile = "p90p99" if percentiles==9099
qui replace percentile = "p0p90" if percentiles==900

drop percentiles
//gen value
rename Top value
replace value = value * 100
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//export
qui export delimited "`results'", replace 
