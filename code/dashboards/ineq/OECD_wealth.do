clear all
local source OECD_wealth
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/OECD.xlsx"
local results "`sourcef'/final_table/`source'"

///import
qui import excel "`rawdata'", ///
	firstrow clear
	
//clean
drop Population POPULATION TIME Flags FlagCodes
rename Time year

//drop missing
rename Value value
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = ""
	qui replace vartype = "avg" if VAR == "T1C5" | VAR == "MNWI"
	qui replace vartype = "dsh" if VAR == "ST1" | VAR == "ST10" ///
	| VAR == "ST5" | VAR == "SB40"
gen concept = "netwea"
gen specific = "ho"
	qui replace specific = "ia" if VAR == "MNWI"

drop if specific=="ia"	
//percentile
qui gen percentile = ""
	qui replace percentile = "p0p100" if vartype == "avg"
	qui replace percentile = "p0p40" if VAR == "SB40"
	qui replace percentile = "p90p100" if VAR == "ST10"
	qui replace percentile = "p99p100" if VAR == "ST1"
	qui replace percentile = "p5p100" if VAR == "ST5"
	
egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen source = "`source'"

//clean area names
ssc install kountry
kountry COUNTRY, from(iso3c) to(iso2c)
drop COUNTRY Country VAR Variable
rename _ISO2C_ area
	qui replace area = "UK" if area == "GB"

//order
order area year value percentile varcode
//export
qui export delimited "`results'", replace 
