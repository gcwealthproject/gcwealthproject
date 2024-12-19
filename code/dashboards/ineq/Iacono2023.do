//settings
clear all

local source Iacono2023
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Wealth - 2010-2018.xlsx"
local results "`sourcef'/final_table/`source'"

//import and clean  - wealth shares - quarters averages
qui import excel "`rawdata'", ///
	sheet("wealth shares") firstrow clear

//clean
keep year percentile value

keep if percentile== "10" | percentile== "20" | percentile== "25" | ///
	percentile== "30" | percentile== "40" | percentile== "50" | ///
	percentile== "60" | percentile== "70" | percentile== "80" | ///
	percentile== "90" | percentile== "95" | percentile== "99" | ///
	percentile== "p50p90"| percentile== "p95p99" | percentile== "p90-p99" | ///
	percentile== "p99p100" 
	
qui replace value = 1 - value if percentile== "95" | percentile== "90"

qui replace percentile="p0p10" if percentile== "10"
qui replace percentile="p0p20" if percentile== "20"
qui replace percentile="p0p25" if percentile== "25"
qui replace percentile="p0p30" if percentile== "30"
qui replace percentile="p0p40" if percentile== "40"
qui replace percentile="p0p50" if percentile== "50"
qui replace percentile="p0p60" if percentile== "60"
qui replace percentile="p0p70" if percentile== "70"
qui replace percentile="p0p80" if percentile== "80" 
qui replace percentile="p0p90" if percentile== "90" 
qui replace percentile="p90p100" if percentile== "90"
qui replace percentile="p95p100" if percentile== "95"
//qui replace percentile="p99p100" if percentile== "99"
qui replace percentile="p90p99" if percentile== "p90-p99"
drop if percentile=="99"
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

replace value = 100 * value

//gen warehouse variables	
gen area = "NO"
gen source = "`source'"
//order
order area year value percentile varcode
//export
qui export delimited "`results'", replace 
