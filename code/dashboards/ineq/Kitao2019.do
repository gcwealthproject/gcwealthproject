//settings
clear all
local source Kitao2019
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Kitao_Yamada_2019.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares
qui import excel "`rawdata'", sheet("Wealth Share") firstrow clear
//clean
rename (Year Bottom20) (year Top920)
drop if missing(year)
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p0p20" if percentiles==920
qui replace percentile = "p80p100" if percentiles==20
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
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "JP"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode
//save
tempfile tf_Kitao_dsh
qui save `tf_Kitao_dsh'

//import -  Gini 
qui import excel "`rawdata'", sheet("Gini") cellrange(A2:J9) firstrow clear
//clean
keep Year H
rename (Year H) (year value)
qui replace value = value * 100

//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "gin"
gen concept = "netwea"
gen specific = "ho"
gen percentile = "p0p100"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "JP"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode
//Append
qui append using `tf_Kitao_dsh'

//export
qui export delimited "`results'", replace
