*********************************
*** EIGT data: adjust for website
*********************************

// Author: Francesca
// Last update: August 2024

// Data used: output/eigt_ready.dta
// Output: output/databases/dashboards/eigt_countries_wide_viz.dta for the website

// Prepare data in partially wide form 
	use "$output/eigt_ready.dta", clear
	drop if substr(GEO, 1, 3) == "US,"

	keep GEO year varcode value source* note 
	gen tax = substr(varcode, 3,1)
	gen bracket = substr(varcode, -2, 2)
	destring bracket, replace
	keep if  substr(varcode, 3, 2) == "ec" |  substr(varcode, 3, 2) == "ee" | ///
			 substr(varcode, 3, 2) == "ic" |  substr(varcode, 3, 2) == "ie" | ///
			 substr(varcode, 3, 2) == "gc" |  substr(varcode, 3, 2) == "ge" | ///
			 substr(varcode, 3, 2) == "te" |  substr(varcode, 3, 2) == "tu" | ///
			 substr(varcode, 3, 2) == "tg"
	
	replace varcode = substr(varcode, 10, 6)
	
// Concatenate sources by GEO year to allow the reshape
	preserve 
		keep GEO year source 
		duplicates drop 
		bys GEO year: gen nsources = _n
		reshape wide source, i(GEO year) j(nsources)
		gen source = source1 + "/" + source2 + "/" + source3 
		replace source = substr(source, 1, length(source) - 1) if substr(source, -1, 1) == "/"		
		replace source = substr(source, 1, length(source) - 1) if substr(source, -1, 1) == "/"		
		drop *1 *2 *3
		tempfile tempor
		save "`tempor'", replace
	restore
	
	drop source*
	merge m:1 GEO year using "`tempor'", nogen

// Concatenate notes by GEO year to allow the reshape
	preserve 
		keep GEO year note 
		duplicates drop 
		bys GEO year: gen nnotes = _n
		reshape wide note, i(GEO year) j(nnotes)
		gen note = note1 + "/" + note2 + "/" + note3 + "/" + note4 if note1 != ""
		replace note = substr(note, 1, length(note) - 1) if substr(note, -1, 1) == "/"		
		replace note = substr(note, 1, length(note) - 1) if substr(note, -1, 1) == "/"		  
		replace note = substr(note, 1, length(note) - 1) if substr(note, -1, 1) == "/"		
		drop *1 *2 *3 *4
		tempfile tempor1
		save "`tempor1'", replace
	restore
	
	drop source* note*
	merge m:1 GEO year using "`tempor'", nogen
	merge m:1 GEO year using "`tempor1'", nogen
	
// Make note invariant 
	sort GEO year bracket tax
	replace note = note[_n-1] if GEO == GEO[_n-1] & year == year[_n-1] & bracket == bracket[_n-1] & tax == tax[_n-1]

	/*
// Attribute eig revenues
	foreach var in revenu prorev revgdp {
		gen v = value if varcode == "`var'" & tax == "EIG Tax"
		bys GEO year: egen min_`var' = min(v)	
		gen `var' = min_`var'
		drop min_`var' v
	}
	foreach var in revenu prorev revgdp {
		gen v = value if varcode == "`var'" & tax == "EI Tax"
		bys GEO year: egen min_`var' = min(v)	
		replace `var' = min_`var' if `var' == . & min_`var' != .
		drop min_`var' v
	}	

	drop if applies_to == "general government"
*/ 

// Reshape
	qui reshape wide value, i(GEO year bracket tax) j(varcode) string
	qui rename (value*) (*)

	egen id = group(GEO year tax)
	xtset id 
	xfill exempt firsty status toplbo toprat typtax source note revenu prorev revgdp, i(id)
	drop id
	
	ds status typtax firsty 
	foreach var in `r(varlist)' {
		format `var' %4.0f
	}
		
// CURRENCY IS NOW TAKEN FROM SUPPLEMENTARY
/* Add string currency
	preserve 
		import excel "$hmade/eigt_currency.xlsx", sheet("WID") firstrow clear
		drop unitlabel
		tempfile widcurren
		save "`widcurren'", replace
	restore

	merge m:1 GEO using "`widcurren'", keep(master matched)
	drop _m
	
	preserve 
		import excel "$hmade/eigt_currency.xlsx", sheet("LCU2023") firstrow clear
		keep GEO nat_
		tempfile currenc
		save "`currenc'", replace
	restore

	merge m:1 GEO using "`currenc'", keep(master matched)
	replace wid_curren = nat_curr if wid_curr == ""
	count if wid_curren == ""
	
	drop curren
	rename wid_curren currency
	drop nat _m
*/
	foreach var in adjlbo adjmrt adjubo exempt firsty status toplbo toprat typtax revenu prorev revgdp {
		replace `var' = . if `var' == -999 | `var' == -998 | `var' == -997
	}

	/*
// Add Inheritance or Estate category 
	gen inh_yes = (tax == "Inheritance Tax" & status == 1)
	gen est_yes = (tax == "Estate Tax" & status == 1)
	bys GEO year: egen i_yes = max(inh_yes)
	bys GEO year: egen e_yes = max(est_yes)
	tab i_y e_y
	
	preserve 
		keep if i_yes == 1 // Inheritance yes
		keep if tax == "Inheritance Tax"
		replace tax = "EI Tax"
		duplicates drop 
		tempfile inh 
		save "`inh'", replace
	restore
	preserve 
		keep if i_yes == 0 & e_yes == 1 // Estate only
		keep if tax == "Estate Tax"
		replace tax = "EI Tax"
		duplicates drop 
		tempfile est 
		save "`est'", replace
	restore
	preserve 
		keep if i_yes == 0 & e_yes == 0 // None of the 2
		drop if tax == "Gift Tax" | tax == "EI Tax" | tax == "EIG Tax"
		replace tax = "EI Tax"
		duplicates drop 
		tempfile none 
		save "`none'", replace
	restore	
	append using "`inh'"
	append using "`est'"
	append using "`none'"

	drop inh_ est_ i_ e_
	*/ 
	order GEO year tax brac adjlbo adjubo adjmrt exempt firsty status toplbo toprat typtax  revenu prorev revgdp source note
	sort GEO year tax bra
	replace tax = "Estate Tax" if tax == "e"
	replace tax = "Gift Tax" if tax == "g"
	replace tax = "Inheritance Tax" if tax == "i"
	replace tax = "EIG Tax" if tax == "t"
	
qui export delimited "$intfile/eigt_countries_wide_viz.csv", replace  
save "$intfile/eigt_countries_wide_viz.dta", replace
	
	
////////////////////////////////////////////////////////////////////////////////
/* Prepare code_desc_viz.xlsx

// Load concept descriptions from dictionary 
	qui import excel "$hmade/dictionary.xlsx", ///
		sheet("d4_concept") clear firstrow	
	qui levelsof code, local(concepts) clean 
	foreach c in `concepts' {
		di as result "`c': " _continue 
		qui levelsof description if code == "`c'", local(des_`c') clean 
		*local des_`c' = subinstr("`des_`c''", ",","", .)
		local des_`c' = subinstr("`des_`c''", ";","", .)
		local des_`c' = subinstr("`des_`c''", `"""',  "", .)
		local des_`c' = subinstr("`des_`c''", char(10),  "", .)
		local des_`c' = subinstr("`des_`c''", char(13),  "", .)
		di as text "`des_`c''" 
	}

	qui use varcode sector using "$intfile/eigt_countries_v1_ready.dta", clear 
	qui keep if substr(varcode, 1, 1) == "x"

	duplicates drop 

	qui gen description = ""
	foreach c in `concepts' {
		qui replace description = "`des_`c''" + " The variable refers to the " + sector + "." if strpos(varcode, "`c'")
	}
	drop sector 
	
// Export long form
	replace varcode = substr(varcode, 1, 15)
	duplicates drop 
	qui export excel "output/metadata/code_desc_viz_v1.xlsx", ///
		sheet("long_version", replace) firstrow(variables)

// Export wide form
	qui replace varcode = subinstr(varcode, "-", "_", .)
	qui gen id = 1
	qui reshape wide description, i(id) j(varcode) string 
	qui rename (description*) (*)

	qui export excel "output/metadata/code_desc_viz_v1.xlsx", ///
		sheet("Sheet1", replace) firstrow(variables) 


	
	
	