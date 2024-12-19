clear all



local source Advani2021
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/AdvaniBanghamLeslie2021_TheUKWealthDistribution.xlsx"
local results "`sourcef'/final_table/`source'"

///import Figure A1
qui import excel "`rawdata'", ///
	sheet("A1") cellrange(B4:H127) firstrow clear

//clean
keep Year percentshareAdjusted H	
rename (Year percentshareAdjusted H) (year Top1 Top10)
//drop missing
drop if missing(Top1)
//reshape
reshape long Top, i(year) j(percentiles)
//rename
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10

drop percentiles

//gen value
rename Top value

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ho"
//note that the unit of analysis is defined as family

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "UK"
gen source = "`source'"

//order
order area year value percentile varcode
//export
qui export delimited "`results'", replace
