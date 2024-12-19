    
** Set paths here
run "code/mainstream/auxiliar/all_paths.do"
*tempfile all


// Check the following lines always before running the code
local general_source = "WID_topo" // The source does not change across the do-file
qui local sector_list hn hs np

* Origin folder: it contains the excel files to import
global bycountry "${topo_dir_raw}/WID_topo/intermediate"
global cmappings "${topo_dir_raw}/WID_topo/auxiliary files"
global intermediate "${topo_dir_raw}/WID_topo/intermediate to erase"
global output "${topo_dir_raw}/WID_topo/final table"
global bycountry_data "${topo_dir_raw}/WID_topo/intermediate"



foreach s in `sector_list'{

use "${topo_dir_raw}/WID_topo/intermediate/populated_grid_`s'.dta", clear
levelsof area, local(country_list)



//list compositions and codes in memory 
qui import excel using "${cmappings}/composition table WID.xlsx" , sheet("composition table `s'") clear firstrow


qui ds code label description extended_composition1 d5_dboard_specific, not 
qui local comp `r(varlist)'
qui local ncomp = wordcount("`comp'")
qui display "`comp'"

qui levelsof code, local(codes) clean
qui local ncodes = wordcount("`codes'")
qui display "`codes'"

foreach c in `codes' {
  levelsof label if code == "`c'", local(lab_`c') clean   
  di as text " `lab_`c' '"
  
    qui levelsof d5_dboard_specific if code == "`c'", local(d5_`c') clean
  qui di as text " `d5_`c' '"
}



di as result "There are `ncomp' different compositions available " ///
	"for `ncodes' codes"

//save each composition's list of variables in memory 	
foreach cod in `codes' {
	di as result "`cod': "
	qui local iter = 1 
	foreach com in `comp' {
		di as text "  -`com' includes: "
		levelsof `com' if code == "`cod'", local(`cod'`iter') clean 
		levelsof `com' if code == "`cod'", local(`cod'`iter'_dirty) clean 
		levelsof extended_composition1 if code == "`cod'", ///
			local(`cod'_ext_comp) clean   
			  
		di as text "     dirty composition: ``cod'`iter''"
		*if not empty ...
		if "``cod'`iter''" != "" {
			foreach char in "+" "-" "(" ")" {
				local `cod'`iter' = ///
					subinstr("``cod'`iter''", "`char'", "", .)
			}
			di as text "     clean composition: ``cod'`iter''"
			* qui macro list _`cod'`iter'_dirty
			* qui macro list _`cod'`iter'
		}
		else {
			*di as error "empty"
		}
		local iter = `iter' + 1
	}
}	 





** Crate metadata by country-sector-concept triple

//now open country by country and check lists one by one 


	foreach ctry in `country_list' {
	
	*qui import excel using "${bycountry}/grid.xlsx", clear firstrow sheet("`ctry'_`s'")
	qui import delimited "${bycountry}/`ctry'_`s'", clear  varnames(1) 

	// source specific
	drop na_code
	rename source_code na_code

	levelsof na_code, local(cod_`ctry') clean 
	levelsof varname_source, local(varnamesource_`ctry') clean 
	levelsof nacode_label, local(nacodelabel_`ctry') clean 

	di as result upper("`ctry'") _continue
	di as text " has these na_codes available `cod_`ctry''"  

	foreach cod in `codes' { // Loop over concepts
	
		qui local iter = 1 
	
		foreach com in `comp' { // Loop over composition for a given concept
			*go only if not empty  
			if wordcount("``cod'`iter''") != 0 {
				di as result " `cod' nº`iter' needs " ///
					wordcount("``cod'`iter''") " items: ``cod'`iter''"
				qui local `cod'`iter'found = wordcount("``cod'`iter''")	

				*loop over each code-composition's item  
				qui local vnsource
				qui local nalabelcode
				
				foreach x in ``cod'`iter'' {
					
					di as text "  - `x'" _continue 
					cap assert strpos(" `cod_`ctry'' ", " `x' ") 
					if _rc == 0 {
						
					// Append (progressively) the var source names
					levelsof varname_source if na_code == "`x'", ///
						local(vnsource_`x') clean 
					local vnsource `vnsource' `vnsource_`x''
					local vnsource "`vnsource';"
					
					*qui local vnsource : subinstr local vnsource " " ", ", all
						
					// Append (progressively) the na_label and na_code source names
					levelsof nacode_label if na_code == "`x'", ///
						local(nacode_label_`x') clean 
					local nalabelcode `nalabelcode' `nacode_label_`x''
					local nalabel_code "`nalabelcode' (`x');"
					local nalabelcode "`nalabelcode';"
						
					di as result " found it." 
					qui di as text "`vnsource'"
					qui di as text "`nalabelcode'"
					qui di as text "`nalabelcode' (`x')"
						
					}
					*subtract to list if not found 
					else {
						*qui di as error " didnt't find"
						qui local `cod'`iter'found = ``cod'`iter'found' - 1
					} 					
				} //close foreach x
				
				*check how many where found 
				di as result "  conclusion: " _continue
			
				if ``cod'`iter'found' == wordcount("``cod'`iter''")	{
				
					*di ``cod'`iter'found'
					local outcome "composition can be computed"
					di as text "`outcome'"

					
					// Create topography concept
					preserve
						use "${topo_dir_raw}/WID_topo/intermediate/populated_grid_`s'.dta", clear
						qui keep if area == "`ctry'"
						qui keep if sector == "`s'"
						
						qui gen percentile = "p0p100"						
						qui gen d1 = "p" // Dashboard: Wealth topography
						qui gen d2 = sector // Sector
						qui gen d3 = "agg"  // 	Vartype: Aggregate
						qui gen d4 = "`cod'" // Concept
						qui gen d5 = "`d5_`cod''" // Dashboard specific
	
						qui gen varcode = d1+"-"+d2+"-"+d3+"-"+d4+"-"+d5						
						
						qui gen value = ``cod'`iter'_dirty' // it works! 
						qui di value
						qui gen longname = ""
					
						* Output
						* area | year | source | percentile | varcode | value | longname (empty)
						qui keep area year source percentile varcode sector value longname
						qui drop if value == . // clean
						
						save "${intermediate}/topo/topo_`ctry'_`s'_`cod'", replace
						drop area year source percentile varcode sector value
					restore	 
					
					// Exit the loop over each code-composition's item 
					continue, break

					
				}
				else {
					di as text "composition cannot be computed"
				}
				
			
			} // close if wordcount("``cod'`iter''") != 0 
			
			local iter = `iter' + 1
		} // close foreach com in `comp'
		
	
	}
		
	}
	

	}	




drop _all

//put all together 
clear
local files : dir "${intermediate}/topo" files "topo_*.dta" ,  respectcase 
global files `files' 
local iter = 1 
tempfile ap 
foreach f in "$files" {
	qui use "${intermediate}/topo/`f'", clear 
	if `iter' != 1 qui append using `ap'
	qui save `ap', replace 
	local iter = 0 
	qui erase "${intermediate}/topo/`f'"
}

/*

**********************************************
//Temporary code (June 5, by Giacomo)

tempfile inputfile
save `inputfile'

// Flag country-sector pairs for which subcomponents (nnhass, nfahou, fliabi) are available

levelsof area, local(area_list)

foreach ctry in `area_list' {
	
	use `inputfile', clear
	
	keep if area == "`ctry'"

	tempfile inputfile_areaonly
	save `inputfile_areaonly'
	
	levelsof sector, local(sector_list)
	
	foreach sctr in `sector_list' {
		
		use `inputfile_areaonly', clear
		
		keep if sector == "`sctr'"

		gen flag = 0

		replace flag = 1 if strpos(varcode,"nnhass") != 0 
		egen maxflag=max(flag)
		replace flag = 2 if strpos(varcode,"nfahou") != 0 & maxflag == 1
		drop maxflag
		egen maxflag=max(flag)
		replace flag = 3 if strpos(varcode,"fliabi") != 0 & maxflag == 2
		drop maxflag
		
		egen maxflag=max(flag)
		replace flag = maxflag
		
		save "${intermediate}/topo/topo_`ctry'_`sctr'_flags", replace

	}
	
}

clear
local files : dir "${intermediate}/topo" files "topo_*.dta" ,  respectcase 
global files `files' 
local iter = 1 
tempfile ap 
foreach f in "$files" {
	qui use "${intermediate}/topo/`f'", clear 
	if `iter' != 1 qui append using `ap'
	qui save `ap', replace 
	local iter = 0 
	qui erase "${intermediate}/topo/`f'"
}


gen area_sector = area+"_"+sector

sort area_sector
quietly by area_sector:  gen dup = cond(_N==1,0,_n)
drop if dup>1
levelsof flag
// keep only area_sector for which netwea needs to be recalculated
keep if flag == 3

// area_sector: 

//ES_hs, 
//FR_hs, 

//AU_hn, 
//DE_hn,
//ES_hn,
//FR_hn, 
//IT_hn, 
//KR_hn, 
//SE_hn, 
//ZA_hn

//CA_hn, CA_hs, CA_np, 
//CZ_hn, CZ_hs, CZ_np, 
//DK_hn, DK_hs, DK_np, 
//FI_hn, FI_hs, FI_np, 
//GB_hn, GB_hs, GB_np, 
//JP_hn, JP_hs, JP_np, 
//MX_hn, MX_hs, MX_np, 
//NL_hn, NL_hs, NL_np, 
//NO_hn, NO_hs, NO_np, 
//US_hn, US_hs, US_np, 

//Create datasets with correct netwea

// hs sector
qui local count_list_torecalcutate ES FR

foreach ctry in `count_list_torecalcutate' {
	
	use `inputfile', clear
	
	keep if area == "`ctry'"
	keep if sector == "hs"
	drop if strpos(varcode,"netwea") != 0
	

	keep if varcode == "p-hs-agg-nnhass-ga" | varcode == "p-hs-agg-nfahou-ga" | varcode == "p-hs-agg-fliabi-lb"

	save "${intermediate}/topo/country", replace

	* Financial asset side
	use "${intermediate}/topo/country", clear
	keep if varcode == "p-hs-agg-nnhass-ga"
	rename value nnhass
	save "${intermediate}/topo/nnhass", replace

	* Housing asset side
	use "${intermediate}/topo/country", clear
	keep if varcode == "p-hs-agg-nfahou-ga"
	rename value nfahou
	save "${intermediate}/topo/nfahou", replace

	* Liabilities side
	use "${intermediate}/topo/country", clear
	keep if varcode == "p-hs-agg-fliabi-lb"
	rename value fliabi
	save "${intermediate}/topo/fliabi", replace

	merge 1:m year using "${intermediate}/topo/nfahou"
	drop _merge

	merge 1:m year using "${intermediate}/topo/nnhass"

	gen netwea = nnhass + nfahou -  fliabi
	rename netwea value
	replace varcode = "p-hs-agg-netwea-na"

	drop _merge nfahou nnhass fliabi

	order area year sector source percentile varcode value longname
	

	save "${intermediate}/topo/`ctry'_hs_netwea", replace

	
}

// hn sector
qui local count_list_torecalcutate AU DE ES FR IT KR SE ZA

foreach ctry in `count_list_torecalcutate' {
	
	use `inputfile', clear
	
	keep if area == "`ctry'"
	keep if sector == "hn"
	drop if strpos(varcode,"netwea") != 0
	

	keep if varcode == "p-hn-agg-nnhass-ga" | varcode == "p-hn-agg-nfahou-ga" | varcode == "p-hn-agg-fliabi-lb"

	save "${intermediate}/topo/country", replace

	* Financial asset side
	use "${intermediate}/topo/country", clear
	keep if varcode == "p-hn-agg-nnhass-ga"
	rename value nnhass
	save "${intermediate}/topo/nnhass", replace

	* Housing asset side
	use "${intermediate}/topo/country", clear
	keep if varcode == "p-hn-agg-nfahou-ga"
	rename value nfahou
	save "${intermediate}/topo/nfahou", replace

	* Liabilities side
	use "${intermediate}/topo/country", clear
	keep if varcode == "p-hn-agg-fliabi-lb"
	rename value fliabi
	save "${intermediate}/topo/fliabi", replace

	merge 1:m year using "${intermediate}/topo/nfahou"
	drop _merge

	merge 1:m year using "${intermediate}/topo/nnhass"

	gen netwea = nnhass + nfahou -  fliabi
	rename netwea value
	replace varcode = "p-hn-agg-netwea-na"

	drop _merge nfahou nnhass fliabi

	order area year sector source percentile varcode value longname
	

	save "${intermediate}/topo/`ctry'_hn_netwea", replace

	
}


//all sectors
qui local count_list_torecalcutate CA CZ DK FI GB JP MX NL NO US
use `inputfile', clear


foreach ctry in `count_list_torecalcutate' {
	
	use `inputfile', clear
	
	keep if area == "`ctry'"

	tempfile inputfile_areaonly
	save `inputfile_areaonly'
	
	levelsof sector, local(sector_list)
	
	foreach sctr in `sector_list' {
		
		use `inputfile_areaonly'
		keep if sector == "`sctr'"
		drop if strpos(varcode,"netwea") != 0
	
		
		save "${intermediate}/topo/country", replace

		* Financial asset side
		use "${intermediate}/topo/country", clear
		keep if varcode == "p-"+"`sctr'"+"-agg-nnhass-ga"
		rename value nnhass
		save "${intermediate}/topo/nnhass", replace

		* Housing asset side
		use "${intermediate}/topo/country", clear
		keep if varcode == "p-"+"`sctr'"+"-agg-nfahou-ga"
		rename value nfahou
		save "${intermediate}/topo/nfahou", replace

		* Liabilities side
		use "${intermediate}/topo/country", clear
		keep if varcode == "p-"+"`sctr'"+"-agg-fliabi-lb"
		rename value fliabi
		save "${intermediate}/topo/fliabi", replace

		merge 1:m year using "${intermediate}/topo/nfahou"
		drop _merge

		merge 1:m year using "${intermediate}/topo/nnhass"

		gen netwea = nnhass + nfahou -  fliabi
		rename netwea value
		replace varcode = "p-"+"`sctr'"+"-agg-netwea-na"

		drop _merge nfahou nnhass fliabi

		order area year sector source percentile varcode value longname
	

	save "${intermediate}/topo/`ctry'_`sctr'_netwea", replace

		
	}
		
}

clear
local files : dir "${intermediate}/topo" files "*_netwea.dta" ,  respectcase 
global files `files' 
local iter = 1 
tempfile ap 
foreach f in "$files" {
	qui use "${intermediate}/topo/`f'", clear 
	if `iter' != 1 qui append using `ap'
	qui save `ap', replace 
	local iter = 0 
	qui erase "${intermediate}/topo/`f'"
}


tempfile correct_netwea
save `correct_netwea'



//drop all 'wrong' netwea from `inputfile' 

use `inputfile', clear

// hs sector
qui local count_list_torecalcutate ES FR
foreach ctry in `count_list_torecalcutate' {
	drop if strpos(varcode,"netwea") != 0 & area == "`ctry'" & sector == "hs"
}

// hn sector
qui local count_list_torecalcutate AU DE ES FR IT KR SE ZA
foreach ctry in `count_list_torecalcutate' {
		drop if strpos(varcode,"netwea") != 0 & area == "`ctry'" & sector == "hn"	
}

//all sectors
qui local count_list_torecalcutate CA CZ DK FI GB JP MX NL NO US
foreach ctry in `count_list_torecalcutate' {
		drop if strpos(varcode,"netwea") != 0 & area == "`ctry'"	
}

tempfile inputfile_cleaned
save `inputfile_cleaned'
	
	
// append	
append using `correct_netwea'

drop if value == 0
drop if value == .

****

*/

run "code/mainstream/auxiliar/all_paths.do"
global output "${topo_dir_raw}/WID_topo/final table"
save "${output}/WID_topo_warehouse.dta", replace
export delimited using "${output}/WID_topo_warehouse.csv", replace







