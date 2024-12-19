clear all



local source Saez2019
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/SaezZucman2019BPEAData.xlsx"
local results "`sourcef'/final_table/`source'"

///import
qui import excel "`rawdata'", ///
	sheet("DataFig2") cellrange (A2:Z106) firstrow clear

//clean
qui rename (A CapitalizationSZupdatedbyPS P) (year Top901 Top190)
qui rename (T Z) (Top1 Top9001)
gen Top10 = 1 - Top190
keep year Top901 Top190 Top1 Top9001 Top10

//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p90" if percentiles==190

drop percentiles

//gen value
rename Top values
gen value = values*100
drop values

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
gen source = "Saez2019"	

//gen method of estimation - data_type
//qui gen data_type = "cs"


//order
order area year value percentile varcode

//export
qui export delimited "`results'", replace 
