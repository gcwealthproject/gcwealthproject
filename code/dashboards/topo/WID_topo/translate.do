// WID
// translate


** Set paths here
global intermediate_to_erase "${topo_dir_raw}/WID_topo/intermediate to erase"
global origin "${topo_dir_raw}/WID_topo/raw data"

//import raw data

use "${origin}/raw_data.dta", clear

drop if strpos(country, "-") != 0



// generate sector variable
gen sector = substr(variable, 1, 2)
order sector, after(variable)

keep if sector == "mh" | sector == "mi" | sector == "mp" | sector == "pr"
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



kountry countryname, from(other) stuck marker 
rename _ISO3N_ country2 
kountry country2, from(iso3n) to(iso2c)
rename _ISO2C_ area 
 // use WID code for countries/areas not recognized by kountry package
replace area = country if MARKER == 0

drop countr* MARKER
order area, first
*levelsof area

// replace - with _ in regions
gen arear_ax = strpos(area, "-") 
replace area = substr(area, 1, 2)+"_"+substr(area, 4, .) if arear_ax > 0
drop arear_ax

keep area variable sector year realvalue shortname
rename shortname varname_source
rename variable source_code

// identifiers
tostring year, gen(year_str)
gen ident = area+"_"+source_code+"_"+sector+"_"+year_str

tempfile temp1
save `temp1'


// Compute nominal values from real

levelsof area, local(loc_area)

foreach c of local loc_area {

use `temp1', clear 
	
keep if area == "`c'"

preserve 
	use "${origin}/raw_prices.dta", clear
	rename country area
	keep if area == "`c'"
	drop area
	tempfile price_c
	save `price_c' 
restore

merge m:1 year using `price_c' 
keep if _merge == 3
drop _merge
gen value = realvalue*priceindex
*order value, after(realvalue)
sort  source_code year


tempfile nominal_`c'
save `nominal_`c''

*save "${intermediate_to_erase}/real_to_nominal/wid_nominal_`c'.dta", replace

}


drop _all	
// append all nominal country-level dataset
foreach c of local loc_area {
	append using `nominal_`c''
}

drop priceindex



//

drop realvalue ident
tempfile temp1
save `temp1'


//


levelsof sector, local(loc_sector)

foreach s of local loc_sector {
	
	use `temp1', clear
	keep if sector == "`s'"

	levelsof area, local(loc_area_`s')
		
	tempfile temp2
	save `temp2'

	foreach c of local loc_area_`s' {
	
			use `temp2', clear
			
			keep if area == "`c'"
			
			tempfile temp3
			save `temp3'
			
			levelsof source_code, local(loc_source_code)

			foreach v of local loc_source_code {

				gen `v' = .
				replace `v' = value if source_code == "`v'"
			}
			
			drop source_code
			drop value
			collapse `loc_source_code', by(year)
				
			gen area = "`c'"
			order area, first 
			
			tempfile pre_pop_`c'_`s'
			save `pre_pop_`c'_`s''
					
			}
		
	}	
	
	
	
drop _all	
// append all country-level dataset (hs)
foreach c of local loc_area_hs {
	append using `pre_pop_`c'_hs'
}
gen source = "WID_topo"
gen sector = "hs"
order source sector, after(area)
save "${topo_dir_raw}/WID_topo/intermediate/populated_grid_hs.dta", replace

drop _all
// append all country-level dataset (hn)
foreach c of local loc_area_hn {
	append using `pre_pop_`c'_hn'
}
gen source = "WID_topo"
gen sector = "hn"
order source sector, after(area)
save "${topo_dir_raw}/WID_topo/intermediate/populated_grid_hn.dta", replace

drop _all
// append all country-level dataset (np) 
foreach c of local loc_area_np {
	append using `pre_pop_`c'_np'
}
gen source = "WID_topo"
gen sector = "np"
order source sector, after(area)
save "${topo_dir_raw}/WID_topo/intermediate/populated_grid_np.dta", replace


	
	
	
	
	
	
	


