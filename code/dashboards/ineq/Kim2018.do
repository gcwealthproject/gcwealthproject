clear all

local source Kim2018
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Kim 2018 - Wealth Inequality in Korea.xlsx"
local results "`sourcef'/final_table/`source'"

/// import
qui import excel "`rawdata'", ///
	sheet("Table 4 & 5 (shares)") cellrange (A19:G33) firstrow clear

//clean
rename A year
drop if year==2008
drop if year==2009
rename (Top01 Top05) (Top999100 Top995100)

//gen Middle 40%
gen Top40 = Top50 - Top10
drop Top50

//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p50p90" if percentiles==40
qui replace percentile = "p99.5p100" if percentiles==995100
qui replace percentile = "p99.9p100" if percentiles==999100

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
gen area = "KR"
gen source = "Kim2018"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode

//export//export
qui export delimited "`results'", replace 


exit

//save
tempfile tf_Kimshares
qui save `tf_Kimshares'

////////////////////////////////////////////////////////////
///// Average and thresholds that are not yet included ////
///////////////////////////////////////////////////////////

//import - averages
qui import excel "`rawdata'", /// 
	sheet("Table 4 & 5 (shares)") cellrange (A2:G16) firstrow clear

/// Note that the average unit is KRW million but it is not explicitly mentioned if it is valued at nominal or real termns 

//clean
rename A year
drop if year==2008
drop if year==2009
rename (Top01 Top05) (Top999100 Top995100)

//gen Middle 40%
drop Top50

//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p99.5p100" if percentiles==995100
qui replace percentile = "p99.9p100" if percentiles==999100

drop percentiles

//gen value
rename Top value
qui replace value = value * 1000000
//drop missing
drop if missing(value)

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
gen area = "KR"
gen source = "Kim2018"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode

//save
tempfile tf_Kimavg
qui save `tf_Kimavg'

//import - thr
qui import excel "`rawdata'", /// 
	sheet("Table 2 & 3") cellrange (A21:K35) firstrow clear

//clean
drop if year==2008
drop if year==2009
drop D F H J Top50
rename (Top05 Top01) (Top905 Top901)
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p99.5p100" if percentiles==905
qui replace percentile = "p99.9p100" if percentiles==901
drop percentiles

//gen value
rename Top value
qui replace value = value * 1000000
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "thr"
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "KR"
gen source = "Kim2018"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode
//Append
qui append using `tf_Kimshares' `tf_Kimavg'

//export
qui export delimited "`results'", replace 
