** Set paths here
*run "Code/Stata/auxiliar/all_paths.do"
tempfile all

global origin "${topo_dir_raw}/FED_S3a_IMA/raw data"
global aux "${topo_dir_raw}/FED_S3a_IMA/auxiliary files"
global intermediate_to_erase "${topo_dir_raw}/FED_S3a_IMA/intermediate to erase"
global intermediate "${topo_dir_raw}/FED_S3a_IMA/intermediate"

import excel "${aux}/matched_grid_s3a.xlsx", firstrow clear

keep varname_source source_code na_code nacode_label 


preserve

	keep source_code na_code
	replace source_code = subinstr(source_code, ".", "", .)
	sxpose, clear

	drop _var10 _var20 _var30 _var36 _var39 // duplicate

	foreach var of varlist * {
		rename `var' `=`var'[1]'
	}
	drop in 1
	gen year = .
	order year, first
	
	export excel using "${intermediate}/code_translator.xls", firstrow(variables) replace

restore


keep if na_code != "" // keep matched ones

replace varname_source = strtrim(varname_source) // eliminate extra blanks in string
replace varname_source = substr(strproper(varname_source), 1,1)+substr(varname_source, 2,.) // capitalize first letter
replace source_code = subinstr(source_code, ".", "", .) 

export excel using "${intermediate}/grid.xls", firstrow(variables) replace
	
