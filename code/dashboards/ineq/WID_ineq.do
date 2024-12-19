//settings
clear all
local source WID_ineq

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/`source'.csv"
local results "`sourcef'/final_table/`source'"
local clear_c "`sourcef'/raw data"
di "`clear_c'"


//file with countries to keep
import excel "`clear_c'/data_quality_table.xlsx", sheet("keep") firstrow clear
drop if missing(area)
keep area
tempfile geo_file_b
save `geo_file_b'

//save inflation rates in memory 
qui import delimited "${supvar_wid_dwld}/supvars_wide_4Nov2022.csv", clear 
qui keep country year inyixx 
qui keep if !missing(inyixx)
tempfile tf_infl 
qui rename country area 
qui save `tf_infl'

//import
import delimited "`rawdata'", clear

//clean
drop if missing(value)
drop age

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = ""
	qui replace vartype = "thr" if strpos(variable, "th")
	qui replace vartype = "avg" if strpos(variable, "ah")
	qui replace vartype = "gin" if strpos(variable, "gh")
	qui replace vartype = "dsh" if strpos(variable, "sh")
gen concept = "netwea"
gen specific = ""
	qui replace specific = "es" if  pop=="j"
	qui replace specific = "tu" if  pop=="t"
	qui replace specific = "ia" if  pop=="i"
	
drop variable pop
drop if missing(specific)
drop if specific == "tu"
drop if specific == "ia"
//1 160 obs deleted (labeled as m (male) or f (female)

//changing gini and dsh values
qui replace value = value * 100 if vartype=="gin" | vartype=="dsh"

//concatenate and drop auxiliar variables
egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
drop dashboard sector vartype concept specific
gen source = "`source'"

//adjust geo variables
rename country area
qui replace area = "UK" if area == "GB"
	drop if strpos(area,"OA")
	drop if strpos(area,"OB")
	drop if strpos(area,"OC")
	drop if strpos(area,"OD")
	drop if strpos(area,"OE")
	drop if strpos(area,"OI")
	drop if strpos(area,"OJ")
	qui replace area = "PROCESS" if area == "QA"
	drop if strpos(area,"Q")
	qui replace area = "QA" if area == "PROCESS"
	drop if strpos(area,"WO")
	drop if strpos(area,"X")
	
merge m:1 area using `geo_file_b'
keep if _merge==3
drop _merge
	
count if missing(area) 
count if missing(percentile)
count if missing(varcode)
count if missing(value)
count if missing(year)
	
//from real to nominal 
qui merge m:1 area year using `tf_infl', keep(1 3) nogen 
qui replace value = value * inyixx if ///
	inlist(substr(varcode, 6, 3), "avg", "thr") & ///
	!missing(inyixx)
qui drop inyixx	
	
//order
order area year value percentile source varcode



// Keep relevant Info
*********************************************************

drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p10" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p20" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p30" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p40" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p50" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p60" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p70" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p80" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p90" 
drop if varcode=="t-hs-thr-netwea-es" & percentile=="p0p99" 



//export
qui export delimited "`results'", replace
