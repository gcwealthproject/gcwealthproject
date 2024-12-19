//settings
clear all

local source Chatterjee2022
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/WID_Data_26092022.csv"
local results "`sourcef'/final_table/`source'"

//import - wealth shares
qui import delimited "`rawdata'",  delimiter(";") varnames(1) clear

//clean
drop if year > 2017

rename shweal_z_za value
qui replace value = value * 100

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "ZA"
gen source = "`source'"

//export
qui export delimited "`results'", replace 
