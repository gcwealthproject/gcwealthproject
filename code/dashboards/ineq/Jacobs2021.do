//settings
clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Jacobs2021
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels


//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Jacobs_Wealth_shares.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares 
qui import excel "`rawdata'", ///
	sheet("Wealth_Shares") cellrange(A1:Z12) firstrow clear

//clean
drop Top5
qui rename (ExpWealth Z) (Top10 Top5)
keep year Top10 Top5
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
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

//save
tempfile tf_Jacobsshares
qui save `tf_Jacobsshares'

//import - Gini 
qui import excel "`rawdata'", ///
	sheet("Gini") cellrange(A1:B5) firstrow clear
	
// clean
rename (gin Year) (value year)
replace value = value * 100

//percentile
gen percentile = ""
qui replace percentile = "p0p100"

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "gin"
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"


//Append
qui append using `tf_Jacobsshares'

order (area year value percentile varcode source)

//export
qui export delimited "`results'", replace 
