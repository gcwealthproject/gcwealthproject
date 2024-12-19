clear all

local source Wolff2021
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Wolff_2021.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares - quarters averages
qui import excel "`rawdata'", ///
	sheet("Table 2") cellrange (A3:K14) firstrow clear

//clean
drop if A=="Year"
drop if A=="A. Net Worth"
gen year = real(A)
drop A

rename (Gini Top Next) (Top800 Top1 Top9599)
rename (E F G) (Top9095 Top8090 Top20)
rename (th rd nd Bottom) (Top6080 Top4060 Top2040 Top120)

gen Top801 = real(Top800)
gen Top802 = Top801*100
drop Top800 Top801

gen Top10 = Top1 + Top9599 + Top9095
gen Top140 = Top2040 + Top120
gen Top160 = Top140 + Top4060
gen Top180 = Top160 + Top6080
drop Top8090 Top6080 Top4060 Top2040

//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p0p100" if percentiles==802
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p95p99" if percentiles==9599
qui replace percentile = "p90p95" if percentiles==9095
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p80p100" if percentiles==20
qui replace percentile = "p0p80" if percentiles==180
qui replace percentile = "p0p60" if percentiles==160
qui replace percentile = "p0p40" if percentiles==140
qui replace percentile = "p0p20" if percentiles==120

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
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  
	

//drop
drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "US"
gen source = "Wolff2021"

//gen method of estimation - data_type
//qui gen data_type = "sy"
//qui replace data_type = "sn" if year<1992

//order
order area year value percentile varcode

//export
qui export delimited "`results'", replace 
