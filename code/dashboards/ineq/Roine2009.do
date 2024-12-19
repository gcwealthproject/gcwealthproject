//settings 
clear all

run "code/mainstream/auxiliar/all_paths.do"
local source Roine2009

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Roine & Waldenström 2009 - Wealth.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares & Gini 
qui import excel "`rawdata'", sheet("shares") cellrange (A2:F41) firstrow clear

//clean
drop if missing(Year)
rename Year year


//reshape
reshape long P, i(year) j(percentiles)

//replace values 
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p90p100" if percentiles==90100
qui replace percentile = "p95p100" if percentiles==95100
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
gen specific = "tu"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "SE"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode
//save
tempfile tf_Roine2009_dsh
qui save `tf_Roine2009_dsh'
//import - wealth shares & Gini 
qui import excel using "`rawdata'", ///
	sheet("shares") cellrange (A2:L41) firstrow clear

//clean
keep Year H K J I L
drop if missing(Year)
drop if missing(H)
drop if missing(Year)
rename Year year

//rename
rename (H I J K L) (P90100 P95100 P99100 P999100 P9999100)
//reshape
reshape long P, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p90p100" if percentiles==90100
qui replace percentile = "p95p100" if percentiles==95100
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
gen specific = "tu"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "SE"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = ""
//Append
qui append using `tf_Roine2009_dsh'
//export
qui export delimited "`results'", replace
	
