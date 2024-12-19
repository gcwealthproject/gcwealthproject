//settings
clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Bricker2021
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Accessible_version_of_figures.xlsx"
local results "`sourcef'/final_table/`source'"






// Recover top 0.1%
********************************************************************************
// Import
import excel "`rawdata'", sheet("Table 4") clear

drop if _n<=3

rename A year 
rename B top0_1

keep year top0_1

destring year top0_1, replace
list


// Clean		
		gen area="US"
		rename top0_1 value 
		replace value=value*100
		gen percentile="p99.9p100"
		gen varcode="t-hs-dsh-netwea-ia"
		gen source="`source'"
		
		tempfile atop0_1
		save `atop0_1', replace






// Recover top Others Wealth shares
********************************************************************************
// Import
import excel "`rawdata'", sheet("Table 7") clear


// Clean
foreach var in A B C D E F G {
	levelsof `var' if _n==3 , c local(xx)
	rename `var' `xx'
}
drop if _n<=3
drop H
list

destring  year bot50 nxt40 top1 top1_UB top1_LB nxt9, replace


foreach var in bot50 nxt40 top1 nxt9 {
	preserve
		keep year `var'
		
		gen area="US"
		rename `var' value 
		replace value=value*100
		gen percentile="`var'"
		gen varcode="t-hs-dsh-netwea-ia"
		gen source="`source'"
		
		if "`var'"=="bot50" {
			replace percentile="p0p50"
		}
		
		
		if "`var'"=="nxt40" {
			replace percentile="p50p90"
		}
		
		if "`var'"=="top1" {
			replace percentile="p99p100"
		}
		
		if "`var'"=="nxt9" {
			replace percentile="p90p99"
		}
		
		tempfile a`var'
		save `a`var'', replace
		
	restore	
}



// Append Everything
********************************************************************************	
clear
foreach var in bot50 nxt40 top1 nxt9  top0_1{
	append using `a`var''
}

order area year value percentile varcode source

order (area year value percentile varcode source)

drop if value==.

//export
qui export delimited "`results'", replace 

