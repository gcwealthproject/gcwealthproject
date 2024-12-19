//settings
clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Bricker2018
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Bricker2018.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares - Top 1%
qui import excel "`rawdata'", ///
	sheet("Figure_5") cellrange(A1:C6) firstrow clear

//clean
keep (SCFDBForbes Year)
qui rename (SCFDBForbes Year) (value year)

//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ho"
// Authors refer to families however not adjustments from the SCF unit is mentioned
gen percentile = "p99p100"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//save
tempfile tf_Bricker2018shares
qui save `tf_Bricker2018shares'

clear


//import - Top 0.1 
qui import excel "`rawdata'", ///
	sheet("Figure_14") cellrange(A1:B14) firstrow 
	
//clean


gen value = real(SCFinclDBForbestaxunits)
drop SCFinclDBForbestaxunits
qui rename (Year) (year)

//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "tu"
gen percentile = "p99.9p100"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"


//Append
qui append using `tf_Bricker2018shares'

order (area year value percentile varcode source)

//export
qui export delimited "`results'", replace 
