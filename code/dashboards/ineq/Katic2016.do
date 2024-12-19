clear all

local source Katic2016
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Top Wealth Shares in Australia - Katic and Leigh 2016 - Supporting Information.xlsx"
local results "`sourcef'/final_table/`source'"

//import - Table 1 - inheritance tax data (1954-1979)
qui import excel "`rawdata'", ///
	sheet("Table 1") cellrange (A3:E29) firstrow clear
	
//clean
split Year, p(-)
drop Year Year1
gen year = real(Year2)
drop Year2 
//rename to reshape
rename (Top01share Top05share Top1share) (Top999100 Top995100 Top1)
rename (Top2share) (Top2)
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p98p100" if percentiles==2
qui replace percentile = "p90p99" if percentiles==910
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p99.5p100" if percentiles==995100

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
//The unit of analysis is not explicitly mentioned

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "AU"
gen source = "Katic2016"

//gen method of estimation - data_type
//qui gen data_type = "et"

//order
order area year value percentile varcode
//save
tempfile tf_Katicinhe
qui save `tf_Katicinhe'

//import - Table 2 - survey (1915, 1987, 2002, 2006, 2010)
qui import excel "`rawdata'", ///
	sheet("Table 2 & 3") cellrange (A2:E7) firstrow clear
	
//clean
rename Year year
//rename to reshape
rename (Top01share Top05share Top1share) (Top999100 Top995100 Top1)
rename (Top2share) (Top2)
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p98p100" if percentiles==2
qui replace percentile = "p90p99" if percentiles==910
qui replace percentile = "p99.9p100" if percentiles==999100
qui replace percentile = "p99.5p100" if percentiles==995100

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
gen specific = "ho"
qui replace specific = "ia" if inlist(year, 2002, 2006, 2010) 
//The unit of analysis is not explicitly mentioned
drop if specific == "ho" & year==1987
egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "AU"
gen source = "Katic2016"

//gen method of estimation - data_type
//qui gen data_type = "sy"

//order
order area year value percentile varcode

//save
tempfile tf_Katicsy
qui save `tf_Katicsy'


//import - Table 2 - Rich list (1984-2012)
qui import excel "`rawdata'", ///
	sheet("Table 2 & 3") cellrange (A10:c39) firstrow clear

//clean
rename Year year
//rename to reshape
rename (Top0001share Top00001share) (Top1 Top10)
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99.999p100" if percentiles==1
qui replace percentile = "p99.9999p100" if percentiles==10

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
//The unit of analysis is individual adults very likely derived from a variety of units

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "AU"
gen source = "Katic2016"

//gen method of estimation - data_type
//qui gen data_type = "rl"

//order
order area year value percentile varcode

//Append
qui append using `tf_Katicinhe' `tf_Katicsy'

//export
qui export delimited "`results'", replace 
