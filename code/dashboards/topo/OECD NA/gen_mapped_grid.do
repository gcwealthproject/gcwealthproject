
clear all

** Set paths here
*run "code/Stata/auxiliar/all_paths.do"
global origin "${topo_pro}/OECD NA/raw data"
global aux "${topo_pro}/OECD NA/auxiliary files"
global destination "${topo_pro}/OECD NA/intermediate"


import delimited "${origin}/7HA_A_Q_11102022152427497.csv", clear



*** part 1 (same for translate)
* the original dataset does not contain reference of the financial position
* we add the financial position based on the full_name_oecd files
* and 

gen finpos = "empty" // financial position
gen her    = . // heriarchy in raw data



replace finpos = "ASS" if transaction == "Investment fund shares"
replace her = 1 if transaction == "Investment fund shares"

replace finpos = "ASS" if transaction == "Money market fund shares"
replace her = 2 if transaction == "Money market fund shares"


replace finpos = "ASS" if transaction == "Real estate fund shares"
replace finpos = "ASS" if transaction == "Bond fund shares"
replace finpos = "ASS" if transaction == "Mixed fund shares"
replace finpos = "ASS" if transaction == "Equity fund shares"
replace finpos = "ASS" if transaction == "Other fund shares"

replace finpos = "ASS" if transaction == "Net equity of households in life insurance reserves"
replace finpos = "ASS" if transaction == "Net equity of households in non-unit-linked life insurance reserves"
replace finpos = "ASS" if transaction == "Net equity of households in unit-linked life insurance reserves"


replace finpos = "ASS" if transaction == "Net equity of households in pension funds"

replace finpos = "ASS" if transaction == "Pension plans managed by autonomous pension funds"
replace finpos = "ASS" if transaction == "Defined contribution plans (DC)"
replace finpos = "ASS" if transaction == "Defined benefit plans (DB)"
replace finpos = "ASS" if transaction == "Hybrid plans"

replace finpos = "ASS" if transaction == "Pension plans managed by non-autonomous pension funds"
replace finpos = "ASS" if transaction == "Insured pension plans"
replace finpos = "ASS" if transaction == "Other pension plans and unfunded pension plans"


replace finpos = "LIAB" if transaction == "Loans"
replace finpos = "LIAB" if transaction == "Short-term loans (up to 1 year)"
replace finpos = "LIAB" if transaction == "Consumer credit (up to 1 year)"
replace finpos = "LIAB" if transaction == "Revolving credit (up to 1 year)"
replace finpos = "LIAB" if transaction == "Credit cards"
replace finpos = "LIAB" if transaction == "Other lines of credit"
replace finpos = "LIAB" if transaction == "Non-revolving credit (up to 1 year)"
replace finpos = "LIAB" if transaction == "Automobile short-term loans (up to 1 year)"
replace finpos = "LIAB" if transaction == "Other short-term loans for consumer durables"
replace finpos = "LIAB" if transaction == "Other ST instalment credit, incl. student ST loans"
replace finpos = "LIAB" if transaction == "Other short-term loans"
replace finpos = "LIAB" if transaction == "Long-term loans (more than 1 year)"
replace finpos = "LIAB" if transaction == "Consumer credit (more than 1 year)"

replace finpos = "LIAB" if transaction == "LT Loans for consumer durables"
replace finpos = "LIAB" if transaction == "Automobile LT loans"
replace finpos = "LIAB" if transaction == "Other LT loans for consumer durables"
replace finpos = "LIAB" if transaction == "Other instalment credit"
replace finpos = "LIAB" if transaction == "Student LT loans"
replace finpos = "LIAB" if transaction == "Other LT instalment credit"
replace finpos = "LIAB" if transaction == "Lending for house purchase"
replace finpos = "LIAB" if transaction == "Mortgage guaranteed"
replace finpos = "LIAB" if transaction == "Unguaranteed"
replace finpos = "LIAB" if transaction == "Other long-term loans"


replace transaction = "Non-financial assets" if transaction == "NON-FINANCIAL ASSETS"
replace finpos = "ASS" if transaction == "Non-financial assets"


replace finpos = "ASS" if transaction == "Of which Dwellings"
replace finpos = "ASS" if transaction == "Of which Machinery & equipment"
replace finpos = "ASS" if transaction == "Of which Other building & structures (incl. non-residential build.)"
replace finpos = "ASS" if transaction == "Of which Inventory"
replace finpos = "ASS" if transaction == "Of which Land"
replace finpos = "ASS" if transaction == "Consumer durables (Memorandum item)"


replace transaction = substr(transaction, 9, .) if substr(transaction, 1, 8) == "Of which"



order finpos, before(transaction)

***
drop v12
sort time
rename time year

drop flags flagcodes referenceperiod referenceperiodcode ///
			powercode powercodecode unitcode unit v12 frequency v10 ///
			v8 measure type activity country // 


drop v12
	
rename v6 sector 
rename v4 varname_source
rename transaction source_code


// Rename sectors
replace sector = "hn" if sector == "Households and NPISHs"
replace sector = "hs" if sector == "Households"
replace sector = "np" if sector == "S15"


// gen na_code from source_code for matching
gen na_code = source_code
replace na_code = substr(na_code, 2, .)
replace na_code = substr(na_code, 2, .) if substr(source_code, 2, 1) == "E"

// Loans
replace na_code = substr(na_code, 1, 2) if substr(source_code, 4, 1) == "T"
// Short term loans
replace na_code = substr(na_code, 1, 2)+"1" if substr(source_code, 5, 3) == "SLI"
// Long term loans
replace na_code = substr(na_code, 1, 2)+"2" if substr(source_code, 5, 3) == "LLI"


replace na_code = "A"+na_code
replace na_code = "A_"+na_code if finpos == "ASS" 
replace na_code = "L_"+na_code if finpos == "LIAB" 



replace source_code = source_code+" ("+finpos+")"
drop finpos

rename location geo3

tempfile temp
save `temp'
***


import delimited "${aux}/geo_translator.csv", varnames(1)  clear
drop country

merge 1:m geo3 using "`temp'", update 

keep if _merge == 3
sort geo
drop geo3 _merge
rename geo area

tempfile temp1
save `temp1'



*** part 2 (only for the creation of the grid)

keep if year == 2019
drop year value

tempfile temp2
save `temp2'



levelsof sector, local(loc_sector)

tempfile temp_sector
save `temp_sector'

foreach s of local loc_sector {

	use `temp_sector', clear
	
	keep if sector ==  "`s'" 

	tempfile temp_area
	save `temp_area'

	levelsof area, local(loc_area)

	foreach a of local loc_area {

		use `temp_area', clear

		keep if area ==  "`a'" 
			
			drop area sector
			
			tempfile temp_sec_area
			save `temp_sec_area'		

			import delimited "${aux}/grid_empty.csv", clear 
			drop varname_source source_code
			merge 1:1 na_code using "`temp_sec_area'", update 
			
			drop if source_code == ""
			drop if nacode_label == ""
			drop _merge 

		qui export excel "${destination}/grid", sheet("`a'_`s'", replace) firstrow(variables) 


}
}

