

** Set paths here
*run "Code/Stata/auxiliar/all_paths.do"
*tempfile all


// Check the following lines always before running the code
local general_source = "ECB_QSA" // The source does not change across the do-file
qui local sector_list S1M S14 S15
qui local country_list austria belgium bulgaria croatia cyprus czechrep ///
		denmark estonia finland france germany greece hungary ireland  ///
		italy latvia lithuania luxembourg malta netherlands poland  ///
		portugal romania slovakia slovenia spain sweden gb

	
* Origin folder: it contains the excel files to import
global bycountry "${topo_dir_raw}/ECB_QSA/intermediate/grid"
global bycountry_data "${topo_dir_raw}/ECB_QSA/intermediate/populated_grid"
global cmappings "${topo_dir_raw}/ECB_QSA/auxiliary files"
global intermediate "${topo_dir_raw}/ECB_QSA/intermediate to erase"
global output "${topo_dir_raw}/ECB_QSA/output"		
		
		

//list compositions and codes in memory 
qui import excel using "${cmappings}/composition table NA.xlsx" , sheet("composition table") clear firstrow

qui ds code label description extended_composition1 d5_dboard_specific, not 
qui local comp `r(varlist)'
qui local ncomp = wordcount("`comp'")
qui display "`comp'"

qui levelsof code, local(codes) clean
qui local ncodes = wordcount("`codes'")
qui di "`codes'"

foreach c in `codes' {
	
  qui levelsof label if code == "`c'", local(lab_`c') clean   
  qui di as text " `lab_`c' '"
  
  qui levelsof d5_dboard_specific if code == "`c'", local(d5_`c') clean
  qui di as text " `d5_`c' '"
}

qui di as result "There are `ncomp' different compositions available " ///
	"for `ncodes' codes"


//save each composition's list of variables in memory 	
foreach cod in `codes' {
	qui di as result "`cod': "
	qui local iter = 1 
	
	foreach com in `comp' {
		qui di as text "  -`com' includes: "
		qui levelsof `com' if code == "`cod'", local(`cod'`iter') clean 
		qui levelsof `com' if code == "`cod'", local(`cod'`iter'_dirty) clean 
		qui levelsof extended_composition1 if code == "`cod'", ///
			local(`cod'_ext_comp) clean   		
			  
		qui di as text "     dirty composition: ``cod'`iter''"
		*if not empty ...
		if "``cod'`iter''" != "" {
			foreach char in "+" "-" "(" ")" {
				qui local `cod'`iter' = ///
					subinstr("``cod'`iter''", "`char'", "", .)
			}
			qui di as text "     clean composition: ``cod'`iter''"
			* qui macro list _`cod'`iter'_dirty
			* qui macro list _`cod'`iter'
		}
		else {
			*di as error "empty"
		}
		qui local iter = `iter' + 1
	}	
}	 


** Crate topography by country-sector-concept triple

foreach s in `sector_list'{

	foreach ctry in `country_list' {
	
	qui import excel using "${bycountry}", clear firstrow sheet("`ctry'_`s'")
	qui levelsof na_code, local(cod_`ctry') clean 
	qui levelsof varname_source, local(varnamesource_`ctry') clean 
	qui levelsof nacode_label, local(nacodelabel_`ctry') clean 

	qui di as result upper("`ctry'") _continue
	qui di as text " has these na_codes available `cod_`ctry''"  

	foreach cod in `codes' { // Loop over concepts
		
		qui local iter = 1 
	
		foreach com in `comp' { // Loop over composition for a given concept
		*go only if not empty  
			if wordcount("``cod'`iter''") != 0 {
				qui di as result " `cod' nº`iter' needs " ///
					wordcount("``cod'`iter''") " items: ``cod'`iter''"
				qui local `cod'`iter'found = wordcount("``cod'`iter''")	

				*loop over each code-composition's item  
				qui local vnsource
				qui local nalabelcode
				
				foreach x in ``cod'`iter'' {
					
					qui di as text "  - `x'" _continue 
					cap assert strpos(" `cod_`ctry'' ", " `x' ") 
					if _rc == 0 {
						
						qui di as result " found it." 
						*qui di as text "`vnsource'"
						
					}
					*subtract to list if not found 
					else {
						*qui di as error " didnt't find"
						qui local `cod'`iter'found = ``cod'`iter'found' - 1
					}
					
				} //close foreach x
				
				*check how many where found 
				qui di as result "  conclusion: " _continue
			
				if ``cod'`iter'found' == wordcount("``cod'`iter''")	{

					*di ``cod'`iter'found'
					qui local outcome ///
						"composition can be computed using : ``cod'`iter'_dirty'"
					qui di as text "`outcome'"
		
					// Save country in local 
					if "`ctry'" == "austria" {
						qui local area_short =  "AT"
					}
					if "`ctry'" == "belgium" {
						qui local area_short =  "BE"
					}
					if "`ctry'" == "bulgaria" {
						qui local area_short =  "BG"
					}
					if "`ctry'" == "croatia" {
						qui local area_short =  "HR"
					}
					if "`ctry'" == "cyprus" {
						qui local area_short =  "CY"
					}
					if "`ctry'" == "czechrep" {
						qui local area_short =  "CZ" 
					} 
					if "`ctry'" == "denmark" {
						qui local area_short =  "DK"
					}
					if "`ctry'" == "estonia" {
						qui local area_short =  "EE" 
					}
					if "`ctry'" == "finland" {
						qui local area_short =  "FI" 
					}
					if "`ctry'" == "france" {
						qui local area_short =  "FR" 
					} 
					if "`ctry'" == "germany" {
						qui local area_short =  "DE" 
					}
					if "`ctry'" == "greece" {
						qui local area_short =  "GR" 
					}
					if "`ctry'" == "hungary" {
						qui local area_short =  "HU" 
					} 
					if "`ctry'" == "ireland" {
						qui local area_short =  "IE"
					}
					if "`ctry'" == "italy" {
						qui local area_short =  "IT" 
					}
					if "`ctry'" == "latvia" {
						qui local area_short =  "LV"
					}
					if "`ctry'" == "lithuania" {
						qui local area_short =  "LT" 
					}
					if "`ctry'" == "luxembourg" {
						qui local area_short =  "LU" 
					}
					if "`ctry'" == "malta" {
						qui local area_short =  "MT" 
					}
					if "`ctry'" == "netherlands" {
						qui local area_short =  "NL" 
					}
					if "`ctry'" == "poland" {
						qui local area_short =  "PL"
					}
					if "`ctry'" == "portugal" {
						qui local area_short =  "PT" 
					}
					if "`ctry'" == "romania" {
						qui local area_short =  "RO"
					} 
					if "`ctry'" == "slovakia" {
						qui local area_short =  "SK"
					} 
					if "`ctry'" == "slovenia" {
						qui local area_short =  "SI" 
					}
					if "`ctry'" == "spain" {
						qui local area_short =  "ES" 
					} 
					if "`ctry'" == "sweden" {
						qui local area_short =  "SE" 
					} 
					if "`ctry'" == "gb" {
						qui local area_short =  "GB" 
					}
					qui di as text "`area_short'" // and print it
					
					// Save sector in local 
					if "`s'" == "S1M" {
						qui local sector_short =  "hn" 
					}
					if "`s'" == "S14" {
						qui local sector_short =  "hs" 
					}
					if "`s'" == "S15" {
						qui local sector_short =  "np" 
					}
					qui di as text "`sector_short'" // and print it

					
					// Create topography concept
					preserve
						use "${bycountry_data}", clear
						qui keep if area == "`area_short'"
						qui keep if sector == "`sector_short'"
						
						qui gen percentile = "p0p100"						
						qui gen d1 = "p" // Dashboard: Wealth topography
						qui gen d2 = sector // Sector
						qui gen d3 = "agn"  // 	Vartype: Aggregate (Non-consolidated)
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
						
						save "${intermediate}/topo/topo_`ctry'_`sector_short'_`cod'", replace
						drop area year source percentile varcode sector value
					restore	 
						
					// Exit the loop over each code-composition's item 
					continue, break
				}
				else {
					qui di as text "composition cannot be computed"
				}
				
			
			} // close if wordcount("``cod'`iter''") != 0 
			
			local iter = `iter' + 1
		} // close foreach com in `comp'
		
	
	}
		
	}
	

	
}	


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


decode year, gen(yyear)
destring yyear, gen(yyyear)
drop year yyear 
rename yyyear year
order year, first

run "code/mainstream/auxiliar/all_paths.do"
global output "${topo_dir_raw}/ECB_QSA/final table"
save "${output}/ECB_QSA_warehouse.dta", replace
export delimited using "${output}/ECB_QSA_warehouse.csv", replace