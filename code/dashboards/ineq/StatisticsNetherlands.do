//settings
clear all

local source StatisticsNetherlands
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Gini_Statistics_Netherlands_2024.csv"
local results "`sourcef'/final_table/`source'"

//import - gini
qui import delimited "`rawdata'", delimiter(";") clear 

//clean
*qui replace periods = "2020" if periods == "2020*"
gen year = periods
rename ginicoefficient value
qui replace value = value * 100
drop periods

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "gin"
gen concept = "netwea"
gen specific = "ho"
gen percentile = "p0p100"
egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "NL"
gen source = "`source'"

//gen method of estimation -
//qui gen data_type = "" 

order area year value percentile varcode 

//export
qui export delimited "`results'", replace
