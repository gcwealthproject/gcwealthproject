
** Set paths here
*run "Code/Stata/auxiliar/all_paths.do"
tempfile all
	
* Origin folder: it contains the excel files to import
global origin "${topo_dir_raw}/Est/raw data" 

* Grid folder
global grid "${topo_dir_raw}/Est/auxiliary files"

* Intermediate to erase folder
global intermediate_to_erase "${topo_dir_raw}/Est/intermediate to erase"

* Intermediate folder
global intermediate "${topo_dir_raw}/Est/intermediate"


// Import

*import delimited "${origin}/nasa_10_f_bs__custom_3518312_linear.csv",  varnames(1) delimiter(";") clear // June 2023 Version
*import delimited "${origin}/nasa_10_f_bs__custom_7119296_linear.csv",  varnames(1) clear // August 2023 Version
import delimited "${origin}/nasa_10_f_bs__custom_11875082_linear.csv",  varnames(1) clear // Juni 2024 Version

// drop vars we don't need
drop dataflow lastupdate freq obs_flag

rename time_period year

drop co_nco // we always work with non consolidated data

levelsof unit // millions of national currency
replace obs_value = obs_value*1000000
drop unit


// Transform na_item in na_code
drop if na_item == "BF90" // drop financial net worth (we generate it after)
replace na_item = "A"+na_item

replace na_item = "A_"+na_item if finpos == "ASS"
replace na_item = "L_"+na_item if finpos == "LIAB"

rename na_item na_code //done!

rename geo area // Rename area

drop finpos // finpos already included in na_code

replace area = "EU27" if area == "EU27_2020"

replace sector = "S1M" if sector == "S14_S15"
****
// tranpose


levelsof sector, local(loc_sector)

tempfile temp_1
save `temp_1'


foreach s of local loc_sector {

	use `temp_1'
	
	keep if sector ==  "`s'" 

	tempfile temp_2
	save `temp_2'

		levelsof area, local(loc_area)

		foreach a of local loc_area {

			use `temp_2'

			keep if area ==  "`a'" 

			levelsof na_code, local(loc_na_code)

			foreach cod of local loc_na_code {
	
				qui gen `cod' = .
				qui replace `cod' = obs_value if "`cod'" == na_code
			}

			drop na_code
			drop obs_value

			drop sector area 
			
			ds _all
			local first = word("`r(varlist)'", 2) // first variable
			ds _all
			local nwords :  word count `r(varlist)'
			local last = word("`r(varlist)'", `nwords') // last variable

			
			collapse `first'-`last', by(year)


			// replace with missing variables that are always missing
			foreach var of varlist `first'-`last' {

				egen checksum = total(`var'), by(year)
				order checksum, after(`var')
				if checksum == 0 {
					replace `var' = .
				}
				drop checksum
			}

			// sector
			qui gen sector = ""

			qui gen area = "`a'"


			if "`s'" == "S1M" {
				qui replace sector = "hn"
				   }
			else if "`s'" == "S14"  {
				qui replace sector = "hs"
				   }
			else if "`s'" == "S15"  {
				qui replace sector = "np"
				   }
			
			qui order year, first
			qui order area sector, after(year)

			tempfile temp_3
			save `temp_3'
			
			qui use "${grid}/grid_a_stock.dta", clear

			qui merge 1:1 year using "`temp_3'", update 

			qui drop _merge
			
			qui replace BF90 = A_AF - L_AF
			
			sort year 
			
			gen source = "Est"
			if "`s'" == "S1M" {
				qui replace sector = "hn"
				   }
			else if "`s'" == "S14"  {
				qui replace sector = "hs"
				   }
			else if "`s'" == "S15"  {
				qui replace sector = "np"
			}
			replace area = "`a'"
			
			keep year-source 

			order area sector source, after(year)
			
			qui save "${intermediate_to_erase}/pop_grid_`a'_`s'.dta", replace
			
}


}


drop _all

//put all the metadata together 
clear
local files : dir "${intermediate_to_erase}/" files "pop_grid_*.dta",  respectcase 
global files `files' 
local iter = 1 
tempfile ap 
foreach f in "$files" {
	qui use "${intermediate_to_erase}/`f'", clear 
	if `iter' != 1 qui append using `ap'
	qui save `ap', replace 
	local iter = 0 
	qui erase "${intermediate_to_erase}/`f'"
}

save "${topo_dir_raw}/Est/intermediate/populated_grid.dta", replace

