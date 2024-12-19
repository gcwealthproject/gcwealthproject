clear all



local source Jakobsen2020
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Top Wealth Shares_USDK.xlsx"
local results "`sourcef'/final_table/`source'"

//import - Sheet 1 - wealth shares
qui import excel "`rawdata'", ///
	sheet("Sheet 1") cellrange (A1:G34) firstrow clear
	
//rename
rename (Year BOTTOM50DK	MIDDLE40DK) (year Top950 Top940)
rename (TOP10DK	TOP1DK	TOP01DK TOP001DK) (Top10 Top1 Top901 Top9001)
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p50p90" if percentiles==940

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
gen area = "DK"
gen source = "Jakobsen2020"

//gen method of estimation - data_type
//qui gen data_type = "" - wealth administrative data

//order
order area year value percentile varcode 
//export
qui export delimited "`results'", replace 
