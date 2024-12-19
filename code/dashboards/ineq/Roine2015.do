clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"


////DENMARK////
local source Roine2015
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdataDE "`sourcef'/raw data/Wealth Denmark - R&W.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares 
qui import excel "`rawdataDE'", ///
	sheet("Data") cellrange (A2:K99) firstrow clear

//clean
drop S1S10
rename A year 
//reshape
reshape long P, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p80p100" if percentiles==80100
qui replace percentile = "p90p100" if percentiles==90100
qui replace percentile = "p95p100" if percentiles==95100
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p99.99p100" if percentiles==9999100
qui replace percentile = "p95p99" if percentiles==9599
qui replace percentile = "p90p99" if percentiles==9099
qui replace percentile = "p90p95" if percentiles==9095

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
gen specific = "ho"
qui replace specific = "ia" if year==1789
//Note that the unit of analysis in 1789 is defined as males aged 19 or above

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "DK"
gen source = "Roine2015"

//gen method of estimation - data_type - historical wealth tax tabulations
//qui gen data_type = "wt"

//order
order area year value percentile varcode
//save
tempfile tf_denmark
qui save `tf_denmark'


////FINLAND////

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdataFI "`sourcef'/raw data/Wealth Finland - R&W.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares 
qui import excel "`rawdataFI'", ///
	sheet("Data") cellrange (A2:H112) firstrow clear

//clean
rename (A Top01) (year Top901)	
//addition
gen Top101 = Top10 - Top1
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p80p100" if percentiles==20
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p90p95" if percentiles==105
qui replace percentile = "p95p99" if percentiles==51
qui replace percentile = "p90p99" if percentiles==101

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
qui replace specific = "ho" if inlist(year, 1922, 1926, 1967)
// Note that for 1907-1909, 1914-15 the unit of analysis is not explicitly mentioned but the estate tax is collected at the individual level. Then, for 2009 the unit of analysis is not explicitly defined. 

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "FI"
gen source = "Roine2015"

//gen method of estimation - data_type - historical wealth tax tabulations
//qui gen data_type = "wt"

//order
order area year value percentile varcode
//save
tempfile tf_finland
qui save `tf_finland'


////NETHERLANDS////

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdataNE "`sourcef'/raw data/Wealth Netherlands - R&W.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares 
qui import excel "`rawdataNE'", ///
	sheet("Data") cellrange (A8:H130) firstrow clear

//clean
drop G E P95100
rename A year 
//addition
gen P95100 = P99100 + P9599
//reshape
reshape long P, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p95p100" if percentiles==95100
qui replace percentile = "p95p99" if percentiles==9599
qui replace percentile = "p99.5p100" if percentiles==995100
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
gen specific = ""
qui replace specific = "tu" if year>=1974
qui replace specific = "ho" if year<=1993

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "NL"
gen source = "Roine2015"

//gen method of estimation - data_type - historical wealth tax recrods
//qui gen data_type = "wt"
//save
tempfile tf_netherlands
qui save `tf_netherlands'

////NORWAY////

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdataNO "`sourcef'/raw data/Wealth Norway - R&W.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares 
qui import excel "`rawdataNO'", ///
	sheet("Data") cellrange (O3:W115) firstrow clear
//clean
rename O year 
//reshape
reshape long P, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==90100
qui replace percentile = "p95p100" if percentiles==95100
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p99.99p100" if percentiles==9999100
qui replace percentile = "p95p99" if percentiles==9599
qui replace percentile = "p90p99" if percentiles==9099
qui replace percentile = "p90p95" if percentiles==9095
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
gen specific = "ho"
qui replace specific = "tu" 
//Note that the unit of analysis is defined as "tax units (households)"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "NO"
gen source = "Roine2015"

//gen method of estimation - data_type - historical wealth tax tabulations
//qui gen data_type = "wt"

//save
tempfile tf_norway
qui save `tf_norway'

////SWEDEN////
//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdataSW "`sourcef'/raw data/Wealth Sweden - R&W.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares 
qui import excel "`rawdataSW'", ///
	sheet("Data") cellrange (A2:G110) firstrow clear

//clean
rename A year 
//addition
gen P9099 = P9095 + P9599
//reshape
reshape long P, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==90100
qui replace percentile = "p95p100" if percentiles==95100
qui replace percentile = "p99p100" if percentiles==99100
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p95p99" if percentiles==9599
qui replace percentile = "p90p99" if percentiles==9099
qui replace percentile = "p90p95" if percentiles==9095

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
gen specific = "ho"
qui replace specific = "ia" if inlist(year, 1800,1908)
//Note that the unit of analysis in 1800 and 1908 is defined as males aged 19 or above. Note that 1800 data point is not included in the excel document.

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "SE"
gen source = "Roine2015"

//gen method of estimation - data_type - historical wealth tax tabulations
//qui gen data_type = "wt"

//append
qui append using `tf_denmark' `tf_finland' `tf_netherlands' `tf_norway'

//export
qui export delimited "`results'", replace
