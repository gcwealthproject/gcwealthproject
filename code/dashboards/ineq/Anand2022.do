clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Anand2022
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Anand_&_Kumar_SupplementaryData.xlsx"
local results "`sourcef'/final_table/`source'"

qui import excel "`rawdata'", ///
	sheet("Wealth series") cellrange (A2:C58) firstrow clear

//clean
qui rename (class shares) (percentile value)
drop if percentile=="0-10" 
drop if percentile=="10-20"
drop if percentile=="20-30" 
drop if percentile=="30-40" 
drop if percentile=="40-50"  
drop if percentile=="50-60"
drop if percentile=="60-70"  
drop if percentile=="70-80" 
drop if percentile=="80-90" 
drop if percentile=="90-99" 
drop if percentile=="99-99.9"
drop if percentile=="99.9-99.99"
drop if percentile=="99.99-99.999"
drop if percentile=="99.999-100"


//drop missing
drop if missing(value)
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "es"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "IN"
gen source = "Anand2022"

//gen method of estimation - data_type
//qui gen data_type = "sa"

//order
order area year value percentile varcode

//export
qui export delimited "`results'", replace




exit
//dropped due to the currency valuation

//save
tempfile Anandshares
qui save `Anandshares'

//import
qui import excel "`rawdata'", /// 
sheet("Wealth series") cellrange (A2:D58) firstrow clear

//clean
drop shares

qui rename (class meanwealth) (percentile value)
drop if percentile=="0-10" 
drop if percentile=="10-20"
drop if percentile=="20-30" 
drop if percentile=="30-40" 
drop if percentile=="40-50"  
drop if percentile=="50-60"
drop if percentile=="60-70"  
drop if percentile=="70-80" 
drop if percentile=="80-90" 
drop if percentile=="90-99" 
drop if percentile=="99-99.9"
drop if percentile=="99.9-99.99"
drop if percentile=="99.99-99.999"
drop if percentile=="99.999-100"

qui replace value = value*1000000
//drop missing
drop if missing(value)
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "avg"
gen concept = "netwea"
gen specific = "es"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "IN"
gen source = "Anand2022"

//gen method of estimation - data_type
//qui gen data_type = "sa"

//order
order area year value percentile varcode 

//Append
qui append using `Anandshares'

//export
qui export delimited "`results'", replace
