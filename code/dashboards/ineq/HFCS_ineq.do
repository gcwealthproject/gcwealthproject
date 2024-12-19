//settings
clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source HFCS_ineq
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels


//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata1 "`sourcef'/raw data/ineq_wave1_hfcs.dta"
local rawdata2 "`sourcef'/raw data/ineq_wave2_hfcs.dta"
local rawdata3 "`sourcef'/raw data/ineq_wave3_hfcs.dta"
local rawdata4 "`sourcef'/raw data/ineq_wave4_hfcs.dta"
local results "`sourcef'/final_table/`source'"



clear
forvalues v=1(1)4{
	append using "`rawdata`v''"
}

drop value_*
gen source = "HFCS_ineq"


// 
replace value=value*100 if varcode=="t-hs-dsh-netwea-ho"
replace value=value*100 if varcode=="t-hs-gin-netwea-ho"

drop if area=="E1"

//export
qui export delimited "`results'", replace
