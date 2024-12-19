//settings 
clear all
run "code/mainstream/auxiliar/all_paths.do"
local source Saez2020b

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Saez_&_Zucman_2020_B_Data.xlsx"
local results "`sourcef'/final_table/`source'"

//import - Top 0.1% tax units
qui import excel "`rawdata'", ///
	sheet("DataF1") cellrange (A2:C111) firstrow clear

//clean
keep A September2020update
rename (A September2020update) (year value)
qui replace value = value * 100
//drop missing
drop if missing(value)
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "tu"
drop if specific == "tu"
gen percentile = "p99.9p100"
egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode
//save
tempfile tf_`source'
qui save `tf_`source''

//import - Top 1% equal split adults
qui import excel "`rawdata'", ///
	sheet("DataF26") cellrange (A2:B113) firstrow clear
	//clean
keep A UpdatedSZ
rename (A UpdatedSZ) (year value)
qui replace value = value * 100
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "es"
gen percentile = "p99p100"
egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode
//append
qui append using `tf_`source''
//export
qui export delimited "`results'", replace
