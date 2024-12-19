
** Set paths here
tempfile all
	
* Origin folder: it contains the excel files to import
global origin "${topo_dir_raw}/ECB_QSA/raw data" 

* Annual datasets (then erased)
global annual "${topo_dir_raw}/ECB_QSA/raw data/dta files/Annual"

* Grid folder
global grid "${topo_dir_raw}/ECB_QSA/auxiliary files"

* Grid-annual datasets (then erased)
global grid_annual "${topo_dir_raw}/ECB_QSA/rawdata/dta files/Annual/Annual, grid"

* Destination folder
global destination "${topo_dir_raw}/ECB_QSA/intermediate"

local counter = 1 
foreach s in S1M S14 S15 {
		
	di as result "sector: `s'"	
	*foreach c in germany  {
	foreach c in austria belgium bulgaria croatia cyprus ///
		czechrep denmark estonia finland france germany ///
		greece hungary ireland italy latvia lithuania ///
		luxembourg malta netherlands poland portugal ///
		romania slovakia slovenia spain sweden gb {
				
		di as text "  - `c'"		
		
		* Choose path if run on mac or windows:
		qui import excel "${origin}/`c'_qsa.xlsx", sheet("data") firstrow clear // update, August 2023

		** Dates column
		qui rename A fulldate

		qui gen year_q = quarterly(fulldate, "YQ")
		qui format year_q %tq

		qui split fulldate, p("Q")
		qui encode fulldate1, gen(year)
		qui encode fulldate2, gen(quarter)
		qui drop fulldate fulldate1 fulldate2
		qui order year_q, first
		qui order year, after(year_q)
		qui order quarter, after(year)

		qui rename year_q yq
		qui rename quarter q
		qui rename year y

		qui label var yq "Year-quarter, .`s'., .N."
		qui label var y "Year, .`s'., .N."
		qui label var q "Quarter, .`s'., .N." 
	
		** Step 1: search across reference sectors

		** Keep only `s' sector
		qui ds, has(varlabel *.`s'.*)  
		qui keep `r(varlist)'

		** Keep only Non-consolidated data 
		qui ds, has(varlabel *.N.*)
		qui keep `r(varlist)'


		** Clean variable names (labels preserve the full names for double checking)
		 
		qui renpfix QSA // Delete Dataset name 
		qui renpfix Q   // Delete Frequency
		qui renpfix N   // Delete Adjustment indicator (N: Neaither seasonally adjusted nor calendar adjusted)
			
		*harmonize country names (iso2c)
		qui gen country = "`c'"
		if "`c'" == "gb" qui replace country = "uk" // workaround
		qui kountry country, from(other) stuck marker 
		cap assert MARKER == 1 
		if _rc != 0 {
			di as error "country name not recognized by kountry package"
			exit 1
		}
		qui rename _ISO3N_ country2 
		qui kountry country2, from(iso3n) to(iso2c)
		qui rename _ISO2C_ area 
		qui drop countr* MARKER
		qui order area, first

		if area == "uk" qui replace area = "GB" // workaound

		*take suffix out 
		qui levelsof area, local(isocode) clean 
		di as result "`isocode'"
		qui renpfix `isocode'
		qui order area, first
	
		qui renpfix W0  // Delete Counterpart ara (W0: World)
		qui renpfix "`s'" // Delete Reference sector (S1M: Households and NPISH/S14:Households/S15:NPISH)
		qui renpfix S1  // Delete Counterpart sector (S1: Total economy)
		qui renpfix N   // Delete Consolidation status (N: Non-consolidated)
		 
		foreach var of varlist * {
			local newname : subinstr local var "_" "", all
			if "`newname'" != "`var'" {
				qui rename `var' `newname'
			}
		}

		foreach var of varlist * {
			local newname : subinstr local var "Z" "", all
			if "`newname'" != "`var'" {
				qui rename `var' `newname'
			}
		}

		foreach var of varlist * {
			local newname : subinstr local var "T" "", all
			if "`newname'" != "`var'" {
				qui rename `var' `newname'
			}
		}

		foreach var of varlist *S {
			local newname : subinstr local var "3S" "", all
			if "`newname'" != "`var'" {
				qui rename `var' `newname'31
			}
		}

		foreach var of varlist *L {
			local newname : subinstr local var "3L" "", all
			if "`newname'" != "`var'" {
				qui rename `var' `newname'32
			}
		}

		foreach var of varlist *S {
			local newname : subinstr local var "4S" "", all
			if "`newname'" != "`var'" {
				qui rename `var' `newname'41
			}
		}

		foreach var of varlist *L {
			local newname : subinstr local var "4L" "", all
			if "`newname'" != "`var'" {
				qui rename `var' `newname'42
			}
		}


		* Eliminate LE (LE: Levels or stocks) and make asset/liabilities names consistent with grid
		qui renvarlab ALEF-LLEF89, map(substr("@", 1,1) + "_A" + substr("@", 4, 6)) 

		* Generate Financial net worth
		qui gen BF90 = A_AF - L_AF

		* Recast all variables as double 
		foreach var of varlist A_AF- BF90{
		   qui recast double `var'
		}
		*** If so, insert here!
		

		* Adjust dataset organization
		qui rename yq year_q
		qui rename q quarter
		qui rename y year

		qui label var year_q "Year-quarter"
		qui label var year ""
		qui label var quarter "Quarter" 

		qui order area, first

		qui gen sector = ""
		qui replace sector = "`s'"
		qui order sector, after(area)

		{
		if "`s'" == "S1M" {
			qui replace sector = "hn"
			   }
		else if "`s'" == "S14"  {
			qui replace sector = "hs"
			   }
		else if "`s'" == "S15"  {
			qui replace sector = "np"
			   }
		}
		qui order sector, after(area)


		qui gen source = "ECB_QSA"
		qui order source, after(sector)

		qui sort year_q


		* qui save quarterly dataset
		*qui save "C:\Users\grella\qui dropbox\THE_GC_WEALTH_PROJECT_website\Wealth Topography\01-InternalSystem\02-Procedures_and_tables\01-Procedures\17-ECB\data\rawdata\QSA_ESA2010_ECB\dta files\Quarterly/`c'_q_`s'.dta", replace	// windows
			
			
		* Create and qui save annual dataset	
		qui keep if quarter == 4
		qui replace quarter = 0
		qui save "${annual}/`c'_a_`s'.dta", replace	
		qui sleep 1000


		* STEP 3: Match
		qui use "${grid}/grid_a_stock.dta", clear 

		qui merge 1:1 year_q using "${annual}/`c'_a_`s'.dta", update 

		qui drop _merge
		qui erase "${annual}/`c'_a_`s'.dta" // erase the file to qui save memory

		* Transform variables in units
		foreach var of varlist A_* {
			qui replace `var' = `var'*1000000
		}
		foreach var of varlist L_* {
			qui replace `var' = `var'*1000000
		}
		qui replace BF90 = BF90*1000000
				
				
		* Re-order
		qui order area sector source, after(quarter)

		qui drop if missing(area) 

		* qui drop all variables outside the grid by finding "XDC" in the label (XDC means local currency)
		foreach v of varlist _all {
			if strpos(`"`:var label `v''"', "XDC") {
				qui drop `v'
			}
		}


		*qui save "/Users/giacomorella/qui dropbox/THE_GC_WEALTH_PROJECT_website/${topo_dir_raw}/17-ECB/data/rawdata/QSA_ESA2010_ECB/dta files/Quarterly, grid/`c'_q_`s'_grid.dta", replace // mac
		*qui save "C:\Users\grella\qui dropbox\THE_GC_WEALTH_PROJECT_website\Wealth Topography\01-InternalSystem\02-Procedures_and_tables\01-Procedures\17-ECB\data\rawdata\QSA_ESA2010_ECB\dta files\Quarterly, grid/`c'_q_`s'_grid.dta", replace // windows


		* Create and qui save annual dataset	
		*keep if quarter == 4
		*replace quarter = 0


		*qui save "/Users/giacomorella/qui dropbox/THE_GC_WEALTH_PROJECT_website/${topo_dir_raw}/17-ECB/data/rawdata/QSA_ESA2010_ECB/dta files/Annual, grid/`c'_a_`s'_grid.dta", replace	// mac
		
		
		if `counter' != 1 qui append using `all'
		qui save `all', replace 
		local counter = 0 
		
		*qui save "${grid_annual}/`c'_a_`s'_grid.dta", replace 	
	}
}

qui use `all', clear 
qui recast int year
qui save "${destination}/populated_grid.dta", replace

