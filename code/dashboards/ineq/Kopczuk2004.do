clear all



local source Kopczuk2004
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/K_&_S_2004_shares_average_thr.xlsx"
local results "`sourcef'/final_table/`source'"

//import - Table 3 - wealth shares 
qui import excel "`rawdata'", ///
	sheet("Table 3") cellrange (A3:H67) firstrow clear
	
//clean
rename (A B C H) (year Top2 Top1 Top9001)
rename (D F G) (Top905 Top901 Top9005)
drop E
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p98p100" if percentiles==2
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
qui replace percentile = "p99.5p100" if percentiles==905
qui replace percentile = "p99.95p100" if percentiles==9005

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
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "Kopczuk2004"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode
//save
//tempfile tf_KS2004dsh
//qui save `tf_KS2004dsh'

//order
order area year value percentile varcode 
//export
qui export delimited "`results'", replace

exit
//////////////////
// Note that avg and thr are presented at 2000 US dollars, and then not included

///import - Table 1 - average wealth (p0p100)
qui import excel "`rawdata'", ///
	sheet("Table 1") cellrange (A8:F95) firstrow clear
	
//clean
keep A F
rename (A F) (year value)
//drop missing
drop if missing(value)
// gen percentile
gen percentile = "p0p100"
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "avg"
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "Kopczuk2004"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode 
//save
tempfile tf_KS2004avg
qui save `tf_KS2004avg'

//import - Table 4 - avg and thr for top groups
qui import excel "`rawdata'", ///
	sheet("Table 4") cellrange(A2:U66) firstrow clear

// clean
drop I J K L M N E R
rename (A B C D) (year Top2 Top1 Top905)
rename (F G H) (Top901 Top9005 Top9001)
rename (O P Q) (Top22 Top21 Top2905)
rename (S T U)(Top2901 Top29005 Top29001)
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p98p100" if percentiles==2
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
qui replace percentile = "p99.5p100" if percentiles==905
qui replace percentile = "p99.95p100" if percentiles==9005

qui replace percentile = "p99p100_thr" if percentiles==21
qui replace percentile = "p98p100_thr" if percentiles==22
qui replace percentile = "p99.9p100_thr" if percentiles==2901
qui replace percentile = "p99.99p100_thr" if percentiles==29001
qui replace percentile = "p99.5p100_thr" if percentiles==2905
qui replace percentile = "p99.95p100_thr" if percentiles==29005

drop percentiles
//gen value
rename Top value
//drop missing
drop if missing(value)
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "avg"
qui replace vartype = "thr" if strpos(percentile, "thr")
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific
//rename correctly
qui replace percentile = "p99p100" if percentile=="p99p100_thr"
qui replace percentile = "p98p100" if percentile=="p98p100_thr"
qui replace percentile = "p99.9p100" if percentile=="p99.9p100_thr"
qui replace percentile = "p99.99p100" if percentile=="p99.99p100_thr"
qui replace percentile = "p99.5p100" if percentile=="p99.5p100_thr"
qui replace percentile = "p99.95p100" if percentile=="p99.95p100_thr"

//gen warehouse variables	
gen area = "US"
gen source = "Kopczuk2004"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode 
//Append
qui append using `tf_KS2004avg' `tf_KS2004dsh'
//export
qui export delimited "`results'", replace
