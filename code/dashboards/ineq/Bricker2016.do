//settings
clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Bricker2016
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Figures for BPEA 04.07.16.xlsx"
local results "`sourcef'/final_table/`source'"


//import - wealth shares - Top 1%
qui import excel "`rawdata'", ///
	sheet("Data Figure 1 (wealth shares)") cellrange(D3:F28) firstrow clear
//qui import excel "`rawdata'", sheet("Data Figure 1 (wealth shares)") cellrange(D3:F28) firstrow

//clean
drop SCFBulletinWealth
qui rename (D PreferredWealthMeasure) (year value)

qui replace value = value * 100
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ho"
gen percentile = "p99p100"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//save
tempfile tf_Bricker2016shares
qui save `tf_Bricker2016shares'

clear

//import - Top 0.1 
qui import excel "`rawdata'", ///
	sheet("Data Figure 1 (wealth shares)") cellrange(D34:F59) firstrow   clear
	
//clean
drop SCFBulletinWealth
qui rename (D PreferredWealthMeasure) (year value)

qui replace value = value * 100
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ho"
gen percentile = "p99.9p100"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"


//Append
qui append using `tf_Bricker2016shares'

order (area year value percentile varcode source)

//export
qui export delimited "`results'", replace 
