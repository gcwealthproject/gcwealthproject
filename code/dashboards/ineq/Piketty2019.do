clear all



local source Piketty2019
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/PYZ2017MainFiguresTables.xlsx"
local results "`sourcef'/final_table/`source'"

//import - Table Data_wealth - wealth shares (Bottom 50, Middle 40, Top 10, Top 1)
qui import excel "`rawdata'", ///
	sheet("Data_Wealth") cellrange (A1:E39) firstrow clear

//clean
rename A year
//rename to reshape
rename (Bottom50 Middle40) (Top950 Top940)

//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
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
//The unit of analysis is not explicitly mentioned

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "CN"
gen source = "Piketty2019"

//gen method of estimation - data_type - survey adjusted (rich list + gpinter)
//qui gen data_type = "sa"

//order
order area year value percentile varcode
//export
qui export delimited "`results'", replace 
