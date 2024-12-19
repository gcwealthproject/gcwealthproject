

// Gen grid

global intermediate "${topo_dir_raw}/LWS_topo/intermediate"
global origin "${topo_dir_raw}/LWS_topo/raw data/data_download"


//import lissy output 
qui import delimited using ///
	"${origin}/lissy_output", varnames(1) delimiter(comma) clear

//summarize implicates 	
qui collapse (mean) value, by(country year variable vlabel)	
	
rename country area

replace vlabel = upper(substr(vlabel, 1, 1)) ///
		+ substr(vlabel, 2, length(vlabel))	

levelsof area, local(loc_area)


foreach c of local loc_area {
	
	preserve
	
		//build excel sheet referencing variable labels 
		keep if area == "`c'"
		di as result "`c'"
		

		replace value = . if value == 0
		drop if value == .
		
		drop if variable == "hpopwgt"

			
		drop year value area 
					
		duplicates drop

		rename variable source_code
		rename vlabel varname_source
		gen na_code = ""
		gen nacode_label = ""
		order na_code source_code nacode_label varname_source
		
		*qui export excel "${intermediate}/grid", ///
		*	sheet("`c'", replace) firstrow(variables)

		qui export delimited "${intermediate}/`c'", replace
	
	restore
		
}	
	
	
	
	
	
 

   	
