clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Kuhn2020
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Khun, Schularick, & Steins (2018) Appendices II and III, Tables F & G.xls"
local results "`sourcef'/final_table/`source'"

///import - wealth shares and gini coefficients
qui import excel "`rawdata'", ///
	sheet("Sheet1") cellrange (A2:G22) firstrow clear
	
//clean
rename A year
//rename to reshape
rename (Bottom50 Middle40 All) (Top950 Top940 Top100)
rename (Bottom99 Bottom90) (Top999 Top900)
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p0p100_gini" if percentiles==100
qui replace percentile = "p0p99_gini" if percentiles==999
qui replace percentile = "p0p90_gini" if percentiles==900
drop percentiles
//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "gin" if strpos(percentile, "gini")
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//rename correctly
qui replace percentile = "p0p100" if percentile=="p0p100_gini"
qui replace percentile = "p0p99" if percentile=="p0p99_gini"
qui replace percentile = "p0p90" if percentile=="p0p90_gini"

//gen warehouse variables	
gen area = "US"
gen source = "Kuhn2020"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode 
//export
qui export delimited "`results'", replace
