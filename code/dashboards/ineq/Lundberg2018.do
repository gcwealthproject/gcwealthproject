//settings
clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"


local source Lundberg2018
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Sweden_Wealth_Inequality_2000-2012 - Lundberg and Waldenstrom 2016.xlsx"
local results "`sourcef'/final_table/`source'"

//import - gini
qui import excel "`rawdata'", sheet("Sweden Gini") cellrange (A5:C18) ///
	firstrow clear

//clean
drop upperCI
rename G value
qui replace value = value * 100
//generate code variables
gen percentile = "p0p100"
gen dashboard = "t"
gen sector = "hs"
gen vartype = "gin"
gen concept = "netwea"
gen specific = "es"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "SE"
gen source = "`source'"

//gen method of estimation - data_type - survey adjusted
//qui gen data_type = "sa" 

//generate longname 1-2 
//run $fill_longname 

//save
tempfile tf_LundbergGini
qui save `tf_LundbergGini'

//import - wealth shares 
qui import excel "`rawdata'", sheet("Sweden top shares") cellrange (A2:E15) ///
	firstrow clear
	
//clean
rename Top01 Top901
gen Top990 = 100 - Top10
gen Top999 = 100- Top10
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p90p99" if percentiles==101
qui replace percentile = "p0p90" if percentiles==990
qui replace percentile = "p0p99" if percentiles==999
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
gen specific = "es"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "SE"
gen source = "`source'"

//gen method of estimation - data_type - survey adjusted
//qui gen data_type = "sa" 

//generate longname 1-2 
run $fill_longname 

//Append
qui append using `tf_LundbergGini'

//export
drop longname
qui export delimited "`results'", replace 

	
