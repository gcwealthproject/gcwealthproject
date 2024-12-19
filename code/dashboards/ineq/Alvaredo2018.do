//settings
clear all
local source Alvaredo2018
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/wealth_shares.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares
qui import excel "`rawdata'", sheet("Friedman Interpolated results") ///
	cellrange (A3:N121) firstrow clear

//clean
drop G H I J K L
qui rename (Bottom90 Top10Top1) (Top990 Top101)
qui rename (Top01 Top05) (Top901 Top905)
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p90p99" if percentiles==101
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.5p100" if percentiles==905
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
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "UK"
gen source = "`source'"

//gen method of estimation - data_type
//qui gen data_type = "et"

//generate longname 1-2 
run $fill_longname 

//export
drop longname
qui export delimited "`results'", replace 
