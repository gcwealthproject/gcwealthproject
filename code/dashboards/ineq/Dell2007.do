//settings
clear all
local source Dell2007
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/wealth_shares.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares
qui import excel "`rawdata'", sheet("wealth shares") cellrange (A1:J23) ///
	firstrow clear
	
//clean
rename (A Top05 Top01 Top001) (year Top905 Top901 Top9001)
drop H

//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p90p95" if percentiles==105
qui replace percentile = "p95p99" if percentiles==51
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
qui replace percentile = "p99.5p100" if percentiles==905
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
gen specific = "tu"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "CH"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode 

//export
qui export delimited "`results'", replace
