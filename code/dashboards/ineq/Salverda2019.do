//settings
clear all
local source Salverda2019
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Salverda 2019 - Top Incomes, Income and Wealth Inequality in the Netherlands.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares & Gini
qui import excel "`rawdata'", sheet("Table 11 (Wealth Shares)") ///
	cellrange (A3:L12) firstrow clear
	
//clean
qui rename (Totalbln Gini Bottom50) (year Top555 Top950)
qui rename (Middle40 Top01 G) (Top940 Top901s Top6080)
rename Second10 Top8090
qui drop if Top901=="n.a."
gen Top901 = real(Top901s)
drop B D Top901s
//generate new variables
gen Top20 = Top10 + Top8090
gen Top909 = Top10 - Top1
gen Top905 = Top5 - Top1
drop Top6080 Top8090
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p80p100" if percentiles==20
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p90p99" if percentiles==909
qui replace percentile = "p95p99" if percentiles==905
qui replace percentile = "p0p100" if percentiles==555
drop percentiles
//gen value
rename Top value
qui replace value = value * 100 if percentile=="p0p100"
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
gen area = "NL"
gen source = "`source'"

//gen method of estimation - data_type - sample-based microdata
//qui gen data_type = "" 

order area year value percentile varcode 
//export
qui export delimited "`results'", replace
