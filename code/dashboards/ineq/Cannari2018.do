clear all
local source Cannari2018
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Wealth inequality in Italy - Tables Cannari D Alessio 2018.xlsx"
local results "`sourcef'/final_table/`source'"


//import Table_10D.8 
qui import excel "`rawdata'", ///
	sheet("Wealth Transpose") cellrange(C1:R24) firstrow clear

//clean
drop P10Median P20Median P80Median P90Median

rename (C sttenth ndtenth) (year Top90010 Top91020)
rename (rdtenth thtenth H) (Top92030 Top93040 Top94050)
rename (I J K) (Top95060 Top96070 Top97080)
rename (L M Giniindex) (Top98090 Top10 Top999)

gen Top90020 = Top90010 + Top91020
gen Top90030 = Top90020 + Top92030
gen Top90040 = Top90030 + Top93040
gen Top90050 = Top90040 + Top94050
gen Top90060 = Top90050 + Top95060
gen Top90070 = Top90060 + Top96070
gen Top90080 = Top90070 + Top97080
gen Top90090 = Top90080 + Top98090

gen Top940 = Top95060 + Top96070 + Top97080 + Top98090

drop Top92030 Top93040 Top94050 ///
	Top95060 Top96070 Top97080 ///
	Top98090 Top91020
	
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p0p100" if percentiles == 999
qui replace percentile = "p0p10" if percentiles == 90010
qui replace percentile = "p0p20" if percentiles ==90020
qui replace percentile = "p0p30" if percentiles == 90030
qui replace percentile = "p0p40" if percentiles == 90040
qui replace percentile = "p0p50" if percentiles == 90050
qui replace percentile = "p0p60" if percentiles == 90060
qui replace percentile = "p0p70" if percentiles == 90070
qui replace percentile = "p0p80" if percentiles == 90080
qui replace percentile = "p0p90" if percentiles == 90090
qui replace percentile = "p90p100" if percentiles == 10
qui replace percentile = "p50p90" if percentiles == 940
drop percentiles

//gen value
rename Top value

//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "gin" if percentile == "p0p100"
qui replace value = value * 100 if vartype == "gin"
gen concept = "netwea"
gen specific = "ia"
//Note that the unit of analysis is "per capita" that is not defined in the metadata_and_sources, assumed to be individual adult

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "IT"
gen source = "Cannari2018"

//gen method of estimation - data_type
//qui gen data_type = "sy"
//qui replace data_type = "sa" if year <= 1975

//order
order area year value percentile varcode

//export
qui export delimited "`results'", replace 
