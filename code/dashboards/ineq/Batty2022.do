//settings
clear all
local source Batty2022
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/DFA_Batty_et_al_2020_Q3.xlsx"
local results "`sourcef'/final_table/`source'"

//import and clean  - wealth shares - quarters averages
qui import excel "`rawdata'", ///
	sheet("year-avg-dsh") cellrange (M3:T35) firstrow clear
qui rename (Bottom90 Middle40 Bottom50) (Top990 Top940 Top950)
qui rename (Next9 Bottom99) (Top909 Top999)
reshape long Top, i(year) j(percentiles)

//rename percentiles 
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p90p99" if percentiles==909
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p0p90" if percentiles==990
qui replace percentile = "p0p99" if percentiles==999
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
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
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
