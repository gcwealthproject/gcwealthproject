//settings 
clear all
run "code/mainstream/auxiliar/all_paths.do"
local source Zucman2019

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Zucman2019Data.xlsx"
local results "`sourcef'/final_table/`source'"

//import - data Fig. A1 - Top 0.01% only for tax units, the other inequality indicators are also presented based on equal split units 
//Note: series are based on mixed method to account for capital gains
qui import excel "`rawdata'", ///
	sheet("DataFA1") cellrange(A4:V108) firstrow clear
//clean
keep A Equalsplitadultsmixedmethod Taxunitsmixedmethodforcapi G H N O T
rename (A Equalsplitadultsmixedmethod Taxunitsmixedmethodforcapi) ///
	(year Top102 Top10)
rename (G H N O T) (Top12 Top1 Top9012 Top901 Top9001)
gen Top909 = Top10 - Top1
gen Top9092 = Top102 - Top12

//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
//tax units
qui replace percentile = "p99p100" if percentiles==1 
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p90p99" if percentiles==909
//equal split
qui replace percentile = "p99p100_es" if percentiles==12 
qui replace percentile = "p99.9p100_es" if percentiles==9012
qui replace percentile = "p99.99p100_es" if percentiles==90012
qui replace percentile = "p90p100_es" if percentiles==102
qui replace percentile = "p90p99_es" if percentiles==9092
drop percentiles
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
qui replace specific = "es" if strpos(percentile, "_es")
drop if specific=="tu"
//rename correctly
qui replace percentile = "p99p100" if percentile=="p99p100_es" 
qui replace percentile = "p99.9p100" if percentile=="p99.9p100_es"
qui replace percentile = "p90p100" if percentile=="p90p100_es"
qui replace percentile = "p90p99" if percentile=="p90p99_es"
egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode
//export
qui export delimited "`results'", replace
