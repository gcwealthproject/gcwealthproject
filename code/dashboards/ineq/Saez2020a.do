//settings
clear all
local source Saez2020a
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Saez_&_Zucman_2020_A.xlsx"
local results "`sourcef'/final_table/`source'"

//import - data Fig. 1
qui import excel "`rawdata'", sheet("DataF1-F2(Wealth)") ///
	cellrange (A9:J119) firstrow clear
	
//clean
keep A H I J
rename (A H I J) (year Top10 Top1 Top901)
gen Top909 = Top10 - Top1
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p90p99" if percentiles==909
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
gen specific = "tu"
egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
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
//import - Top 0.0025%
qui import excel "`rawdata'", sheet("DataF1(Forbes)") cellrange (A7:I62) ///
	firstrow clear
//clean

keep A Top00025wealthshare
rename (A Top00025wealthshare) (year value)
qui replace value = value * 100
//attention with the average unit 
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "tu"
gen percentile = "p99.99975p100"
egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  

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
