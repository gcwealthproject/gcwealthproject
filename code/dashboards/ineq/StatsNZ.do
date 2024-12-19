//settings
clear all

local source StatsNZ
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Stats_NZ_used.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares & Gini - households
qui import excel "`rawdata'", sheet("Inequality_indicators") ///
	cellrange (L2:Q5) firstrow clear
	
//rename 
rename (Top50percent3 Top10percent4 Top5percent5) (Top50 Top10 Top5)
rename (Top1percent Giniindex6 Households) (Top1 Top555 year)
//gen new variables
gen Top950 = 100 - Top50
gen Top940 = Top50 - Top10
gen Top990 = 100 - Top10
gen Top905 = Top5 - Top1
gen Top909 = Top10 - Top1	
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p90p99" if percentiles==909
qui replace percentile = "p95p99" if percentiles==905
qui replace percentile = "p0p100" if percentiles==555
qui replace percentile = "p50p100" if percentiles==50
qui replace percentile = "p90p100" if percentiles==90
qui replace percentile = "p0p90" if percentiles==990
drop percentiles
//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "gin" if percentile=="p0p100"
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "NZ"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode 
//save
tempfile tf_StatsNZ
qui save `tf_StatsNZ'

//import - wealth shares & Gini - individuals 
qui import excel "`rawdata'", sheet("Inequality_indicators") ///
	cellrange (L7:Q10) firstrow clear

//rename 
rename (Top50percent3 Top10percent4 Top5percent5) (Top50 Top10 Top5)
rename (Top1percent Giniindex6 Individuals) (Top1 Top555 year)

//gen new variables
gen Top950 = 100 - Top50
gen Top940 = Top50 - Top10
gen Top990 = 100 - Top10
gen Top905 = Top5 - Top1
gen Top909 = Top10 - Top1	
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p90p99" if percentiles==909
qui replace percentile = "p95p99" if percentiles==905
qui replace percentile = "p0p100" if percentiles==555
qui replace percentile = "p50p100" if percentiles==50
qui replace percentile = "p90p100" if percentiles==90
qui replace percentile = "p0p90" if percentiles==990
drop percentiles
//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "gin" if percentile=="p0p100"
gen concept = "netwea"
gen specific = "ia"
drop if specific == "ia"
egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "NZ"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 

//order
order area year value percentile varcode 
//append
qui append using `tf_StatsNZ'
//export
qui export delimited "`results'", replace
