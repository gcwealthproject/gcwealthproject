// WID


** Set paths here
global intermediate_to_erase "${topo_dir_raw}/WID_topo/intermediate to erase"
global origin "${topo_dir_raw}/WID_topo/raw data"
global aux "${topo_dir_raw}/WID_topo/auxiliary files"
global intermediate "${topo_dir_raw}/WID_topo/intermediate"


//import raw data

use "${origin}/raw_data.dta", clear


* drop regions
drop if strpos(country, "-") != 0 



// generate sector variable
gen sector = substr(variable, 1, 2)
order sector, after(variable)
levelsof sector

keep if sector == "mh" | sector == "mi" | sector == "mp"
replace sector = "hs" if sector == "mh" // households
replace sector = "np" if sector == "mi" // npish
replace sector = "hn" if sector == "mp" // households and npish

// the next to lines make the variable names the same to those on WID website
replace variable = substr(variable, 2, .)
replace variable = substr(variable, 1, strlen(variable)-4)

// harmonize country names (iso2c) and drop aggregation of economic areas
replace countryname = "Cape Verde" if countryname == "Cabo Verde"
replace countryname = "Macedonia" if countryname == "North Macedonia"
replace countryname = "Democratic Republic of Congo" if countryname == "DR Congo"


// drop combined countries and regions
preserve
	import excel "${aux}/country_symb.xls", sheet("Foglio2") firstrow allstring clear
	levelsof country_symb, local(loc_country_list)
restore

gen check = 0

foreach c of local loc_country_list {
	
	replace check = 1 if country == "`c'"
}

drop if check == 1
drop check

rename country area

keep area variable sector year realvalue shortname
rename shortname varname_source
rename variable source_code

tempfile temp1
save `temp1'


levelsof area, local(loc_area)

foreach c of local loc_area {
	
	use `temp1', clear
	keep if area == "`c'"

	levelsof sector, local(loc_sector)			
	tempfile temp2
	save `temp2'
	
	foreach s of local loc_sector {
		
		use `temp2', clear
		keep if sector == "`s'"
	
		gen dup = 0
		levelsof source_code, local(loc_source_code)
		sort source_code
		foreach vv of local loc_source_code {
			by source_code: replace dup = cond(_N==1,0,_n) if source_code == "`vv'"
			drop if dup > 1
		}
		drop dup
		
		gen na_code = ""
		gen nacode_label = ""
		order na_code source_code nacode_label varname_source
		keep area sector na_code source_code nacode_label varname_source
		save "${intermediate_to_erase}/grid/grid_`c'_`s'", replace

	
	}	
	
}

//put all the metadata together 
clear
local files : dir "${intermediate_to_erase}/grid" files "grid_*.dta" , ///
	respectcase 
global files `files' 
local iter = 1 
tempfile ap 
foreach f in "$files" {
	qui use "${intermediate_to_erase}/grid/`f'", clear 
	if `iter' != 1 qui append using `ap'
	qui save `ap', replace 
	local iter = 0 
	qui erase "${intermediate_to_erase}/grid/`f'"
}

tempfile temp4
save `temp4'

levelsof sector, local(loc_sector)		

foreach s of local loc_sector {

	use `temp4', clear
	keep if sector == "`s'"

	levelsof area, local(loc_area)

		tempfile temp5
		save `temp5'

		foreach c of local loc_area {
			
			use `temp5', clear
			keep if area == "`c'"
			drop sector area
			duplicates drop 
			

			
			global intermediate "${topo_dir_raw}/WID_topo/intermediate"
			
			export delimited "${intermediate}/`c'_`s'", replace 	
			*export excel "${intermediate}/grid.xlsx", ///
		*sheet("`c'_`s'", replace) firstrow(variables) 	
			
		
	
	}
}

		
	

	
	
	
	
	
	
	

 

   	
