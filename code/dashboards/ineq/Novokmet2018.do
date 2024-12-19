//settings
clear all
local source Novokmet2018
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/WealthSeriesRussiaBenchmark.xlsx"
local results "`sourcef'/final_table/`source'"

//import - average, wealth shares, gini
qui import excel "`rawdata'", sheet("series") cellrange (C1:I22) firstrow clear

//clean
rename (Average Bottom50 Middle40 Gini) (Top999 Top950 Top940 Top555)
gen year = real(Year)
drop Year
gen Top909 = Top10 - Top1
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p90p99" if percentiles==909
qui replace percentile = "p0p100_gini" if percentiles==555
qui replace percentile = "p0p100_avg" if percentiles==999
drop percentiles
//gen value
rename Top value
qui replace value = value * 100
//attention with the average unit 
//drop missing
drop if missing(value)
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "gin" if percentile=="p0p100_gini"
qui replace percentile = "p0p100" if percentile=="p0p100_gini"
qui replace vartype = "avg" if percentile=="p0p100_avg"
qui replace percentile = "p0p100" if percentile=="p0p100_avg"

	// drop averages
	qui drop if vartype == "avg"
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "RU"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode
//export
qui export delimited "`results'", replace
