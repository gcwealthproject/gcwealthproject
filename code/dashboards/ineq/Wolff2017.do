//settings
clear all
local source Wolff2017
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Wolff (2017) HOUSEHOLD WEALTH TRENDS IN THE UNITED STATES.xlsx"
local results "`sourcef'/final_table/`source'"

//import  
qui import excel "`rawdata'", sheet("Share Net Worth") cellrange(A4:T18) ///
	firstrow clear
	
//clean
drop if Year=="A. Net Worth"
rename (Coefficient E) (Top900 Top1)
rename (F H L) (Top9599 Top9095 Top20)
rename (N P R T) (Top6080 Top4060 Top2040 Top920)
gen year = real(Year)
drop C D G I J K M O Q S Year

qui replace Top900 = Top900*100
gen Top10 = Top1 + Top9599 + Top9095
gen Top980 = Top6080 + Top4060 + Top2040 + Top920
gen Top960 = Top4060 + Top2040 + Top920
gen Top940 = Top2040 + Top920
drop Top6080 Top4060 Top2040
//reshape
reshape long Top, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p95p99" if percentiles==9599
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p90p95" if percentiles==9095
qui replace percentile = "p80p100" if percentiles==20
qui replace percentile = "p0p80" if percentiles==980
qui replace percentile = "p0p60" if percentiles==960
qui replace percentile = "p0p40" if percentiles==940
qui replace percentile = "p0p20" if percentiles==920
qui replace percentile = "p0p100" if percentiles==900
drop percentiles

//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "gin" if strpos(percentile, "p0p100")
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "`source'"

//gen method of estimation - data_type
//qui gen data_type = "sy"

//generate longname 1-2 
//run $fill_longname 

//export
qui export delimited using "`results'", replace 
