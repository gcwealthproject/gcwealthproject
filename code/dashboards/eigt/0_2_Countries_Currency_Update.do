******************************
*** EIGT data: currency update
******************************

// Author: Francesca
// Last update: October 2024

// Data used: $intfile/eigt_taxsched_currency.dta, $intfile/eigt_taxsched_data.dta 
// $supvars/supplementary_var_16Jul2024
// $intfile/eigt_oecdrev_currency_22mar2024.dta, $intfile/eigt_oecdrev_data_22mar2024.dta 

// $hmade/eigt_currency.xlsx
// Output: $intfile/eigt_taxsched_data_correct.dta, $intfile/eigt_oecdrev_data_22mar2024_correct.dta  

// Content: convert monetary values to the local currency unit used in WID for conversion

******************** 1. TAX SCHEDULES CONVERSION *******************************

// Prepare WID currency
	use "$supvars/supplementary_var_$supvarver", clear
	xfill LCU_wid
	keep country LCU_wid
	rename country GEO
	duplicates drop
	drop if LCU == "" | substr(GEO, 3, 1) != ""
	tempfile widcurren
	qui save "`widcurren'", replace
	
// Open tax schedule currencies 
	qui use "$intfile/eigt_taxsched_currency.dta", clear

// Attach WID data currencies 
	qui merge m:1 GEO using "`widcurren'" , keep(master matched)
	rename curren taxsch_curren 
	rename LCU_wid wid_currency

// For the cases unmatched with wid, check that the currency is the local 
//currency unit in 2023 so no conversion is needed
	preserve 
		qui import excel "$hmade/eigt_currency.xlsx", sheet("LCU2023") firstrow clear
		keep GEO nat_
		tempfile currenc
		qui save "`currenc'", replace
	restore
	preserve 
		qui keep if _m==1
		drop _m

		qui merge m:1 GEO using "`currenc'", keep(master matched)
		qui: count if _m == 1 
		if (`r(N)' != 0) {
			display as error "WARNING: `r(N)' cases unmatched, check"
			tab GEO_long if _m == 1 
		}	
		drop _m
		count if taxsch_curren != nat_currency // 0
	restore
	qui replace wid_currency = taxsch_curre if _m == 1 // GG and JE, GBP

// Check observations for which tax schedule currency != wid_currency	
	display "Countries for which tax schedule currency != wid_currency"
	tab GEO if _m == 3 & taxsch_curre != wid_currency // work on it
	qui gen toupdate = (_m == 3 & taxsch_curre != wid_currency) // flag those cases
	drop _m

// Attach conversion rates to those cases
	preserve 
		qui import excel "$hmade/eigt_currency.xlsx", sheet("conversion") firstrow clear
		rename curren taxsch_curren
		rename nat_currency wid_currency
		tempfile conversion
		qui save "`conversion'", replace
	restore

	qui merge m:1 GEO taxsch_curren wid_currency using "`conversion'" , keep(master matched)
	qui: count if toupdate == 1 & _m == 1 
	if (`r(N)' != 0) {
		display in red "`r(N)' cases unmatched for tax schedule data, check"
		tab GEO if toupdate == 1 & _m == 1
	}	
	drop _m GEO_long

// Set conversion rate to 1 in case no conversion is needed 
	qui replace conv_rate = 1 if !toupdate

// Save conversion rates for tax schedule data
	tempfile taxsch_curren
	qui save "`taxsch_curren'", replace

// Attach conversion rates to tax schedule data 
	qui use "$intfile/eigt_taxsched_data.dta", clear
	qui merge m:1 GEO year using "`taxsch_curren'", nogen 

	labvars taxsch_curren wid_currency toupdate conv_rate fixed_rate ///
			"Original currency from the source" "WID currency" ///
			"Whether currency conversion is needed" "Conversion rate 1 wid_currency" ///
			"Whether the conversion rate is fixed (1) or the market rate is needed (0)"

// Apply conversion rate and prepare for matching
	preserve
		qui use "$supvars/supplementary_var_$supvarver", clear
		keep country year xlcusx // WID: Market exchange rate with USD
		rename country GEO
		tempfile convert
		qui save "`convert'", replace
	restore
	qui merge m:1 GEO year using "`convert'", keep(master match)
	qui: count if _m == 1 & fixed_rate == 0
	if (`r(N)' != 0) {
		display in red "WARNING: `r(N)' cases unmatched for tax schedule data in supvar, check"
		tab GEO year if _m == 1 & fixed_rate == 0
	}	
	qui: count if _m == 3 & fixed_rate == 0 & taxsch_curren != "USD" & wid_currency != "USD"
	if (`r(N)' != 0) {
		display in red "`r(N)' cases for which xlcusx cannot be used directly, check"
		tab GEO year if _m == 3 & fixed_rate == 0 & taxsch_curren != "USD" & wid_currency != "USD"
	}	
	qui replace conv_rate = 1/xlcusx if conv_rate == . & fixed_rate == 0 & taxsch_curren == "USD" // from USD to wid
	qui replace conv_rate = xlcusx if conv_rate == . & fixed_rate == 0 & wid_currency == "USD" // to USD from wid
	
// DIVIDE the monetary variables by conv_rate to convert currency
	foreach var in chiexe ad1lbo ad1ubo torac1 {
		replace `var' = `var' / conv_rate if (`var' != -999 &  `var' != -998 & `var' != -997)
	}
	drop toupdate conv_rate fixed_rate xlcusx _merge taxsch_curre
	rename wid_currency curren 
	qui compress

// Make currency numeric 
	preserve 
		qui import excel "$hmade/eigt_currency.xlsx", sheet("codes") firstrow clear
		tempfile codes
		qui save "`codes'", replace
	restore

	qui merge m:1 curren using "`codes'" , keep(master matched)
	qui: count if _m == 1
	if (`r(N)' != 0) {
		display in red "`r(N)' cases of currency numeric code not found, check"
		continue, break
	}		
	rename numericcode curre
	qui labmask curre, values(curren)
	drop curren _m
	rename curre curren

	qui save "$intfile/eigt_taxsched_data_correct", replace
			

******************** 2. OECD REVENUES CONVERSION *******************************

// Open oecd currencies 
	qui use "$intfile/eigt_oecdrev_currency_$oecdver.dta", clear

// Attach WID data currencies 
	qui merge m:1 GEO using "`widcurren'" , keep(master matched)
	rename curren oecd_curren 
	rename LCU_wid wid_currency

	preserve 
		qui import excel "$hmade/eigt_currency.xlsx", sheet("LCU2023") firstrow clear
		keep GEO nat_
		tempfile currenc
		qui save "`currenc'", replace
	restore
	preserve 
		qui keep if _m==1
		drop _m

		qui merge m:1 GEO using "`currenc'", keep(master matched)
		qui: count if _m == 1 
		if (`r(N)' != 0) {
			display as error "WARNING: `r(N)' cases unmatched, check"
			tab GEO_long if _m == 1 
		}	
		drop _m
		count if oecd_curren != nat_currency // 0
	restore
	qui replace wid_currency = oecd_curren if _m == 1 // TK, NZD
	

// Check observations for which oecd currency != wid_currency	
	tab GEO if _m == 3 & oecd_curren != wid_currency // work on it
	qui gen toupdate = (_m == 3 & oecd_curren != wid_currency) // flag those cases
	drop _m

// Attach conversion rates to those cases
	preserve 
		qui import excel "$hmade/eigt_currency.xlsx", sheet("conversion") firstrow clear
		rename curren oecd_curren
		rename nat_currency wid_currency
		tempfile conversion
		qui save "`conversion'", replace
	restore

	qui merge m:1 GEO oecd_curren wid_currency using "`conversion'" , keep(master matched)
	qui: count if toupdate == 1 & _m == 1 
	if (`r(N)' != 0) {
		display in red "`r(N)' cases unmatched for OECD data, check"
		tab GEO if toupdate == 1 & _m == 1
	}	
	drop _m GEO_long

// Set conversion rate to 1 in case no conversion is needed 
	qui replace conv_rate = 1 if !toupdate

// Save conversion rates for oecd revenues data
	tempfile oecd_curren
	qui save "`oecd_curren'", replace

// Attach conversion rates to oecd revenues data 
	qui use "$intfile/eigt_oecdrev_data_$oecdver.dta", clear
	qui merge m:1 GEO year using "`oecd_curren'", nogen 

	labvars oecd_curren wid_currency toupdate conv_rate fixed_rate ///
			"Original currency from OECD data" "WID currency" ///
			"Whether currency conversion is needed" "Conversion rate 1 wid_currency" ///
			"Whether the conversion rate is fixed (1) or the market rate is needed (0)"

// Apply conversion rate and prepare for matching
	preserve
		qui use "$supvars\supplementary_var_$supvarver", clear
		keep country year xlcusx // WID: Market exchange rate with USD
		rename country GEO
		tempfile convert
		qui save "`convert'", replace
	restore
	qui merge m:1 GEO year using "`convert'", keep(master match)
	qui: count if _m == 1 & fixed_rate == 0
	if (`r(N)' != 0) {
		display in red "`r(N)' cases unmatched for oecd rev data in supvar, check"
		tab GEO year if _m == 1 & fixed_rate == 0
	}	
	qui: count if _m == 3 & fixed_rate == 0 & oecd_curren != "USD" & wid_currency != "USD"
	if (`r(N)' != 0) {
		display in red "`r(N)' cases for which xlcusx cannot be used directly, check"
		display in red "364 cases checked: Bolivia and Guyana, solved"
		tab GEO if _m == 3 & fixed_rate == 0 & oecd_curren != "USD" & wid_currency != "USD"
	}	
	qui replace conv_rate = 1/xlcusx if conv_rate == . & fixed_rate == 0 & oecd_curren == "USD" // from USD to wid
	qui replace conv_rate = xlcusx if conv_rate == . & fixed_rate == 0 & wid_currency == "USD" // to USD from wid
	
// 1) Bolivia: OECD data for Bolivia are in Venezuelan Bolívares (VEB), need to be BOB 
// 2) Guyana: OECD data for Guyana are in VEF, need to be in GYD
	qui replace xlcusx = . if _m == 3 & fixed_rate == 0 & oecd_curren != "USD" & wid_currency != "USD"

	// BOLIVIA
	// VEF->USD
	preserve
		qui use "$supvars\supplementary_var_$supvarver", clear
		keep country year xlcusx // WID: Market exchange rate with USD
		qui keep if country == "VE" // Venezuela to have the exchange rate VEF -> USD
		drop country 
		qui gen GEO = "BO"
		qui gen xlcusx2 = xlcusx * 1000 // need also this for VEB -> VEF
		drop xlcusx
		tempfile bolivia1
		qui save "`bolivia1'", replace
	restore
	// USD->BOB
	preserve
		qui use "$supvars\supplementary_var_$supvarver", clear
		keep country year xlcusx // WID: Market exchange rate with USD
		qui keep if country == "BO" // Bolivia to have the exchange rate BOB -> USD
		rename country GEO
		qui merge 1:1 GEO year using "`bolivia1'"
		qui replace xlcusx2 = xlcusx2 / xlcusx // need for VEB -> USD and USD -> BOB
		drop xlcusx _m
		qui gen oecd_curren = "VEB" 
		qui gen wid_currency = "BOB"
		tempfile bolivia2
		qui save "`bolivia2'", replace
	restore	
	cap drop _m
	qui merge m:1 GEO year using "`bolivia1'", keep(master matched)
	drop _m 
	qui replace conv_rate = xlcusx2 if conv_rate == . & fixed_rate == 0 & oecd_curren != "USD" & wid_currency != "USD"
	drop xlcusx2
	
	// GUYANA
	// VEF->USD	
	preserve
		qui use "$supvars\supplementary_var_$supvarver", clear
		keep country year xlcusx // WID: Market exchange rate with USD
		qui keep if country == "VE" // Venezuela to have the exchange rate VEF -> USD
		drop country 
		qui gen GEO = "GY"
		rename xlcusx xlcusx2
		tempfile guyana1
		qui save "`guyana1'", replace
	restore
	// USD->GYD
	preserve
		qui use "$supvars\supplementary_var_$supvarver", clear
		keep country year xlcusx // WID: Market exchange rate with USD
		qui keep if country == "GY" // Guyana to have the exchange rate GYD -> USD
		rename country GEO
		qui merge 1:1 GEO year using "`guyana1'"
		qui replace xlcusx2 = xlcusx2 / xlcusx // need for VEF -> USD and USD -> GYD
		drop xlcusx _m
		qui gen oecd_curren = "VEF" 
		qui gen wid_currency = "GYD"
		tempfile guyana2
		qui save "`guyana2'", replace
	restore	
	cap drop _m
	qui merge m:1 GEO year using "`guyana2'", keep(master matched)
	drop _m 

	qui replace conv_rate = xlcusx2 if conv_rate == . & fixed_rate == 0 & oecd_curren != "USD" & wid_currency != "USD"
	drop xlcusx2

	
// DIVIDE the monetary variables by conv_rate to convert currency
	foreach var in revenu_fed revenu_gen revenu_loc revenu_reg  {
		qui replace `var' = `var' / conv_rate if (`var' != -999 &  `var' != -998 & `var' != -997)
	}
	drop toupdate conv_rate fixed_rate xlcusx oecd_curren
	rename wid_currency curren 

	// Make currency numeric 
	preserve 
		qui import excel "$hmade/eigt_currency.xlsx", sheet("codes") firstrow clear
		tempfile codes
		qui save "`codes'", replace
	restore

	qui merge m:1 curren using "`codes'" , keep(master matched)
	qui: count if _m == 1
	if (`r(N)' != 0) {
		display in red "`r(N)' cases of currency numeric code not found, check"
		continue, break
	}		
	rename numericcode curre
	qui labmask curre, values(curren)
	drop curren _m
	rename curre curren
	order GEO GEO_long year curren
	qui compress
	
	qui save  "$intfile/eigt_oecdrev_data_$oecdver_correct.dta", replace	
	
