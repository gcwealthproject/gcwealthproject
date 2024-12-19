clear all



local source Saez2016
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/AppendixTables(Distributions).xlsx"
local results "`sourcef'/final_table/`source'"

///import Table B1 - Wealth thresholds - current dolars 
qui import excel "`rawdata'", ///
	sheet("TableB2") cellrange(A58:G108) firstrow clear

//reshape
//rename to reshape
rename (E F G) (Top905 Top901 Top9001)
rename (A B C D) (year Top10 Top5 Top1)

reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99p100" if percentiles==1

qui replace percentile = "p99.5p100" if percentiles==905
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001

drop percentiles

//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "thr"
gen concept = "netwea"
gen specific = "tu"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "Saez2016"

//gen method of estimation - data_type
//qui gen data_type = "cs"

//order
order area year value percentile varcode
//save
tempfile tf_Saezthr
qui save `tf_Saezthr'

///import - Table B1 - tax units shares
qui import excel "`rawdata'", ///
	sheet("TableB1") cellrange(A8:K108) firstrow clear

//reshape
//rename to reshape
rename (Top05 Top01 Top001) (Top905 Top901 Top9001)
rename (Top10to1 Top10to5 Top5to1) (Top9 Top95 Top94)
rename (Bottom90 A) (Top90 year)

reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p0p90" if percentiles==90

qui replace percentile = "p99.5p100" if percentiles==905
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001

qui replace percentile = "p90p99" if percentiles==9
qui replace percentile = "p90p95" if percentiles==95
qui replace percentile = "p95p99" if percentiles==94

drop percentiles

//gen value
gen value_100 = Top*100
rename value_100 value 
drop Top
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "tu"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "Saez2016"

//gen method of estimation - data_type
//qui gen data_type = "cs"

//order
order area year value percentile varcode 
//Append
qui append using `tf_Saezthr'

//export
qui export delimited "`results'", replace 
