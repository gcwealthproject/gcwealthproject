//settings
clear all

local source ABS
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/ABS_SIH_ASNA_13_12_2022.xlsx"
local results "`sourcef'/final_table/`source'"

//import - average wealth
qui import excel "`rawdata'", cellrange (B1:G12) firstrow clear

//clean
drop if missing(year)

// From string to numbers
gen P0p20 = real(p0p20)
gen P20p40 = real(p20p40)
gen P40p60 = real(p40p60)
gen P60p80 = real(p60p80)
gen P80p100 = real(p80p100)

drop (p0p20 p20p40 p40p60 p60p80 p80p100)
//generate correct percentiles (defined on the warehouse)
gen Top40 = P0p20 + P20p40
gen Top60 = Top40 + P40p60
gen Top80 = Top60 + P60p80

drop (P20p40 P40p60 P60p80)
//rename to reshape
qui rename (P0p20 P80p100) (Top20 Top100)

//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly 
rename Top value
//percentile
gen percentile = ""
qui replace percentile = "p0p20" if percentiles == 20
	qui replace percentile = "p0p40" if percentiles == 40
	qui replace percentile = "p0p60" if percentiles == 60
	qui replace percentile = "p0p80" if percentiles == 80
	qui replace percentile = "p80p100" if percentiles == 100
	drop percentiles
	//generate code variables
	gen dashboard = "t"
	gen sector = "hs"
	gen vartype = "dsh"
	gen concept = "netwea"
	gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "AU"
gen source = "`source'"

//export
qui export delimited "`results'", replace 

