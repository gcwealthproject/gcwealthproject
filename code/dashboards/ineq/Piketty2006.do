clear all



local source Piketty2006
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/PikettyPostelVinayRosenthal2006.xls"
local results "`sourcef'/final_table/`source'"

//import - Table A3 - thresholds at death in France (//to TableA2 that refers to Paris)
qui import excel "`rawdata'", ///
	sheet("TableA3") cellrange (A6:H22) firstrow clear
	
//clean
rename A year
drop B
//reshape
reshape long P, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==90
qui replace percentile = "p95p100" if percentiles==95
qui replace percentile = "p99p100" if percentiles==99
qui replace percentile = "p99.5p100" if percentiles==995
qui replace percentile = "p99.9p100" if percentiles==999
qui replace percentile = "p99.99p100" if percentiles==9999
drop percentiles
//gen value
rename P value
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
gen area = "FR"
gen source = "Piketty2006"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode
//save
tempfile tf_thrdeathA2
qui save `tf_thrdeathA2'


//import - Table A3 - average at death in France (//to TableA2 that refers to Paris)
qui import excel "`rawdata'", ///
	sheet("TableA3") cellrange (A24:H40) firstrow clear
	
//clean
rename (A P0100) (year P100)
//reshape
reshape long P, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==90100
qui replace percentile = "p95p100" if percentiles==95100
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p99.5p100" if percentiles==995100
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p99.99p100" if percentiles==9999100
qui replace percentile = "p0p100" if percentiles==100
drop percentiles
//gen value
rename P value
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
gen area = "FR"
gen source = "Piketty2006"

//gen method of estimation - data_type
//qui gen data_type = "et"
 
//order
order area year value percentile varcode
//save
tempfile tf_avgdeathA2
qui save `tf_avgdeathA2'


///Table A3 - shares at death in France //to TableA2 that refers to Paris)
qui import excel "`rawdata'", ///
	sheet("TableA3") cellrange (A42:H58) firstrow clear
	
//clean
rename (A) (year)
drop P0100
//reshape
reshape long P, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==90100
qui replace percentile = "p95p100" if percentiles==95100
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p99.5p100" if percentiles==995100
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p99.99p100" if percentiles==9999100
qui replace percentile = "p0p100" if percentiles==100
drop percentiles
//gen value
rename P value
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
gen area = "FR"
gen source = "Piketty2006"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode
//save
tempfile tf_dshdeathA2
qui save `tf_dshdeathA2'


//Append
qui append using `tf_thrdeathA2' `tf_avgdeathA2' 

//export
qui export delimited "`results'", replace 
