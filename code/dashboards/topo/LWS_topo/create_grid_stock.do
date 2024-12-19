
** Set paths here
global intermediate "${topo_dir_raw}/LWS_topo/intermediate"
global origin "${topo_dir_raw}/LWS_topo/raw data/data_download"


//import lissy output 
qui import delimited using ///
	"${origin}/lissy_output", varnames(1) delimiter(comma) clear 

*summarize implicates 
qui collapse (mean) value, by(country year variable vlabel)		

drop if variable == "hpopwgt"

levelsof variable, local(loc_var)


// extract dates

qui collapse (count) ct = value , by(year)
duplicates tag year, gen(dupi)
assert dupi == 0 
cap drop ct dupi 

// fill grid 
foreach v of local loc_var {
	gen `v' = .
}


save "${topo_dir_raw}/LWS_topo/auxiliary files/grid_a_stock", replace



