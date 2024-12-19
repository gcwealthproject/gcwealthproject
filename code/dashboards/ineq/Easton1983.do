//settings


clear all
local source Easton1983
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Easton_Table_7_3.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares & Gini 
qui import excel "`rawdata'", sheet("Adults") cellrange (F2:N4) firstrow clear
//rename 
rename (F Ginicoefficient Top5ofdistribution) (year Top555 Top5)
rename (Bottom50ofdistribution) (Top950)
drop Top2
gen Top909 = Top10 - Top1
gen Top940 = Top50 - Top10
gen Top905 = Top5 - Top1
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p80p100" if percentiles==20
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p50p90" if percentiles==940
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p90p99" if percentiles==909
qui replace percentile = "p95p99" if percentiles==905
qui replace percentile = "p0p100" if percentiles==555
qui replace percentile = "p50p100" if percentiles==50
drop percentiles
//gen value
rename Top value
qui replace value = value * 100 if percentile=="p0p100"
//drop missing
drop if missing(value)
//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "gin" if percentile=="p0p100"
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific

//drop if varcodes are wrong: 
drop if varcode == "x-hs-agg-eitrev-00"
drop if varcode == "x-hs-str-curren-00"
drop if varcode == "x-hs-thr-cl1exe-00"

//gen warehouse variables	
gen area = "NZ"
gen source = "`source'"

//gen method of estimation - data_type 
//qui gen data_type = "" 
//order
order area year value percentile varcode
//export
qui export delimited "`results'", replace
