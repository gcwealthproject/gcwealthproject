clear all



local source Garbinti2021
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/GGP2016Wealth_Appendix_Figures_JEEA_final_nolink.xlsx"
local results "`sourcef'/final_table/`source'"

//import - shares
qui import excel "`rawdata'", ///
	sheet("Wealth shares") cellrange (A2:H47) firstrow clear
	
//rename to reshape
rename (P050 P5090 P90100) (Top850 Top840 Top10)
rename (P99100 P9099 P999100) (Top1 Top910 Top999)
rename (P0P90) (Top900)
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p0p50" if percentiles==850
qui replace percentile = "p50p90" if percentiles==840
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p99" if percentiles==910
qui replace percentile = "p99.9p100" if percentiles==999
qui replace percentile = "p0p90" if percentiles==900

drop percentiles

//gen value
rename Top values
gen value = values * 100 
drop values
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "es"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "FR"
gen source = "Garbinti2021"

//gen method of estimation - data_type
//qui gen data_type = "cs"

//order
order area year value percentile varcode

//save
tempfile tf_Garbintishares
qui save `tf_Garbintishares'

//import - average
qui import excel "`rawdata'", ///
	sheet("Average") cellrange (A3:H48) firstrow clear

//rename to reshape
rename (P050 P5090 P90100) (Avg850 Avg840 Avg10)
rename (P99100 P9099 P999100) (Avg1 Avg910 Avg999)
rename P0P100 Avg100
//reshape
reshape long Avg, i(year) j(averages)
//rename correctly
gen average = ""
qui replace average = "p0p50" if averages==850
qui replace average = "p50p90" if averages==840
qui replace average = "p90p100" if averages==10
qui replace average = "p99p100" if averages==1
qui replace average = "p90p99" if averages==910
qui replace average = "p99.9p100" if averages==999
qui replace average = "p0p100" if averages==100
rename average percentile

drop averages
//gen value
rename Avg value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "avg"
gen concept = "netwea"
gen specific = "es"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "FR"
gen source = "Garbinti2021"

//gen method of estimation - data_type
//qui gen data_type = "cs"

//order
order area year value percentile varcode

//Append
qui append using `tf_Garbintishares'

//export
qui export delimited "`results'", replace 
