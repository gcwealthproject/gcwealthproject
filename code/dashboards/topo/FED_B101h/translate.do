
global origin "${topo_dir_raw}/FED_B101h/raw data"
global aux "${topo_dir_raw}/FED_B101h/auxiliary files"
global intermediate_to_erase "${topo_dir_raw}/FED_B101h/intermediate to erase"
global intermediate "${topo_dir_raw}/FED_B101h/intermediate"

	
* Import dates
import delimited "${origin}/FRB_Z1.csv", numericcols(1) delimiter(comma) clear

gen n = _n
order n, first

drop if n == 1 | n == 2 | n == 3 | n == 4 | n == 5 
	
drop v29-v38 // duplicate
	
// assing varname_source	
foreach var of varlist v2-v28{
	
	replace `var' = subinstr(`var', ".", "", .) if _n == 1

	rename `var' `=`var'[1]'
	
}

drop if n == 6
drop n	
rename v1 year


preserve

	import excel "${aux}/matched_grid_b101h.xls", firstrow clear
	keep varname_source source_code na_code nacode_label 

	gen n = _n
	order n, first
	drop if n >= 28
	
	keep source_code na_code
	replace source_code = subinstr(source_code, ".", "", .)
	sxpose, clear


	foreach var of varlist * {
		rename `var' `=`var'[1]'
	}
	drop in 1
	gen year = 1
	order year, first
	 
	tempfile code_translator
	save `code_translator'
	
restore

append using `code_translator', force


sort year

findname, all(missing(@[1]))
drop `r(varlist)'

ds year, not 
foreach v of var `r(varlist)' {
		rename `v' `=`v'[1]'
}

drop in 1

destring , replace
	
// from millions to units	
ds year, not 
foreach v of var `r(varlist)'{
	
	replace `v' = `v'*1000000
	
}

****


	
	
tempfile pre_pop
save `pre_pop'
	
	
	
use "${aux}/grid_a_stock.dta", clear 

* merge 

merge 1:1 year using `pre_pop', update 	

drop _merge

gen area = "US"
gen sector = "hs"
gen source = "FED_B101h"

order area sector source, after(year)

* save
save "${intermediate}/populated_grid.dta", replace





