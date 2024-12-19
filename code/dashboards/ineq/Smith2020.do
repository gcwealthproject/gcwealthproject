//settings
clear all
local source Smith2020
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/smithetal2020_wealth_agg_percentiles.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares - quarters averages
qui import excel "`rawdata'", sheet("wealth-shares") cellrange (M1:U52) ///
	firstrow clear
	
//clean
qui rename (P090) (P409)
drop P9999999 P99999
//reshape
reshape long P, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p0p90" if percentiles==409
qui replace percentile = "p90p99" if percentiles==9099
qui replace percentile = "p90p100" if percentiles==90100
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p99.99p100" if percentiles==9999100
drop percentiles
//gen value
rename P value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "es"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//gen method of estimation - data_type - survey adjusted
//qui gen data_type = "sa" 

//generate longname 1-2 
//run $fill_longname 

//export
qui export delimited "`results'", replace 
