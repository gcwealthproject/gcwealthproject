//settings
clear all
local source vanBavel2017
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/vanBavel2017.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares - CBS
qui import excel "`rawdata'", ///
	sheet("Table 2") cellrange (I5:K19) firstrow clear
//clean
rename (Bottom10) (Top910)
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p10" if percentiles==910
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
gen area = "NL"
gen source = "`source'"


replace value = value * 100
//export
qui export delimited "`results'", replace 
