clear all

local source Davies2021
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Appendix_A_Davies_Di_Matteo_2020.xlsx"
local results "`sourcef'/final_table/`source'"

//import Table 2 
///qui import excel ///
qui import excel "`rawdata'", ///
	sheet("Table 2") cellrange(A2:J29) firstrow clear

//reshape
//rename to reshape
drop if A==.
rename (A Top01 Top05) (year Top901 Top905)
rename (Bottom40 GiniCoeff Mean2016s) (Top940 Top907 Top916)

reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p80p100" if percentiles==20

qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.5p100" if percentiles==905
qui replace percentile = "p0p40" if percentiles==940
qui replace percentile = "p0p100_gini" if percentiles==907
qui replace percentile = "p0p100_mean" if percentiles==916
drop percentiles

//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"

gen vartype = "dsh"
qui replace vartype = "gin" if strpos(percentile, "gini")
qui replace vartype = "avg" if strpos(percentile, "mean")
//rename correctly
qui replace percentile = "p0p100" if strpos(percentile, "gini")
qui replace percentile = "p0p100" if strpos(percentile, "mean")

gen concept = "netwea"

gen specific = "ia"
qui replace specific = "ho" if year <= 1902 | year >= 1970

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

//correct gini
qui replace value = value *100 if vartype=="gin"	
	
drop dashboard sector vartype concept specific

//correct value
qui replace value = value * 100 if year==1892

//drop varcodes currently not in warehouse
drop if varcode == "x-hs-cat-eigfir-00"
drop if varcode == "x-hs-cat-esttax-00"
drop if varcode == "x-hs-cat-eigsta-00"
drop if varcode == "x-hs-cat-ieexem-00"
drop if varcode == "x-hs-cat-inhtax-00"
drop if varcode == "x-hs-cat-itaxre-00"
drop if varcode == "x-hs-rat-etopra-00"
drop if varcode == "x-hs-rat-itopra-00"
drop if varcode == "x-hs-rat-toprat-00"
drop if varcode == "x-hs-str-curren-00"
drop if varcode == "x-hs-thr-cl1exe-00"
drop if varcode == "x-hs-thr-torac1-00"


//gen warehouse variables	
gen area = "CA"
gen source = "Davies2021"

//gen method of estimation - data_type
//qui gen data_type = ""
//qui replace data_type = "et" if year <= 1968 
//qui replace data_type = "sr" if year >= 1970

//generate longname 1-2 
//run $fill_longname 

//export
qui export delimited "`results'", replace 
