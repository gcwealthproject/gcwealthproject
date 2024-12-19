clear all



local source StatisticsFinland
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Stats_Fin_Wealth_deciles_2019.xlsx"
local results "`sourcef'/final_table/`source'"

//import - Table Top10 
qui import excel "`rawdata'", ///
	sheet("Top10") cellrange (A1:B10) firstrow clear

//clean
qui replace value = value *100	
// gen percentile
gen percentile = "p90p100"
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific


//gen warehouse variables	
destring year , replace

gen area = "FI"
gen source = "StatisticsFinland"

//gen method of estimation - data_type
//qui gen data_type = "sy"

//order
order area year value percentile varcode

//export
qui export delimited "`results'", replace 


/*

exit
//dropped due to the currency valuation
//save
tempfile tf_StatsFI
qui save `tf_StatsFI'

//import - Table Average
qui import excel "`rawdata'", ///
	sheet("Avg Transpose") cellrange (A1:L10) firstrow clear

//rename
rename (A Allhouseholds Ileastwealthy II) (year avg100 avg1 avg2)
rename (III IV V VI) (avg3 avg4 avg5 avg6)
rename (VII VIII IX Xwealthiest) (avg7 avg8 avg9 avg10)
//reshape
reshape long avg, i(year) j(percentiles)
//rename correctly
gen percentile = ""
qui replace percentile = "p0p100" if percentiles==100
qui replace percentile = "p0p10" if percentiles==1
qui replace percentile = "p10p20" if percentiles==2
qui replace percentile = "p20p30" if percentiles==3
qui replace percentile = "p30p40" if percentiles==4
qui replace percentile = "p40p50" if percentiles==5
qui replace percentile = "p50p60" if percentiles==6
qui replace percentile = "p60p70" if percentiles==7
qui replace percentile = "p70p80" if percentiles==8
qui replace percentile = "p80p90" if percentiles==9
qui replace percentile = "p90p100" if percentiles==10
drop percentiles
//gen value
rename avg value
//drop missing
drop if missing(value)
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "avg"
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific
//gen warehouse variables	
gen area = "FI"
gen source = "StatisticsFinland"

//gen method of estimation - data_type
//qui gen data_type = "sy"


//order
order area year value percentile varcode
//Append
qui append using `tf_StatsFI'
//export
qui export delimited "`results'", replace 

*/
