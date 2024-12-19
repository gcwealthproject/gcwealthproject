clear

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"


local source CS_ineq
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/wealth_data_wide.dta"
local results "`sourcef'/final_table/`source'"


use "`rawdata'" , clear
drop if c3==""	// avoid aggregates (Africa, Europe,...)



** Codebook
********************************************************************************

	/* 
	
		Auxilary variables
		*******************************************
			xr, xr_sm = exchange rate
			wealth_rank  sorts countrys by var=="totw" --> total net wealth ($) 
		
		
		Average Net Wealth per Adult
		*******************************************
		wpa		-> in Dollars
		
		
		Gini
		******************************************
		gini	-> Unit???
		
		
		Thresholds
		*******************************************
		wmin_1-wmin_9
		min_top_10, min_top_5, min_top_1

	
		Wealth Shares
		*******************************************
		wdecile_1-wdecile_9
		top10, top5, top1
		
		
		
		Open issues
		******************************************
		
			* All monetary values are in $, xt -> convert back to nominal
				a. What about CPI adjustments?
				
			* Distributional measures do not  specify the unit of measurs
				a. HH?
				b. ia?
		
	*/
	
	
	
	// Exchange rates
	*****************************************************
	preserve
		
		keep if var=="xr"
		
		// reshape
		expand 23
		bys country: gen year=1999+_n 
		gen xr=.
		forvalues v=2000(1)2022 {
			replace xr=v_`v' if year==`v'
		}
	
		keep country year xr
		tempfile xr
		save `xr', replace
	restore
	
	
	
	
	
********************************************************************************	
** Reshape Files
********************************************************************************

	// Average Wealth
	*****************************************************
	preserve
		
		keep if var=="wpa"
		
		// reshape
		expand 23
		bys country: gen year=1999+_n 
		gen value=.
		forvalues v=2000(1)2022 {
			replace value=v_`v' if year==`v'
		}
		
		keep country c3 var value year data_quality vname
		
		// National currency
		merge 1:1 country year using `xr'
		drop _merge
		replace value=value*xr
		drop xr
		
		// auxialary for GC
		gen varcode="t-hs-avg-netwea-ia"
		gen percentile="p0p100"
		
		tempfile mu
		save `mu', replace
	restore
	
	
	
	// Gini
	*****************************************************
	preserve
		
		keep if var=="gini"
		
		// reshape
		expand 23
		bys country: gen year=1999+_n 
		gen value=.
		forvalues v=2000(1)2022 {
			replace value=v_`v' if year==`v'
		}
		
		keep country c3 var value year data_quality vname
		
		// auxialary for GC
		gen varcode="t-hs-gin-netwea-ia"
		gen percentile="p0p100"

		tempfile gini
		save `gini', replace
	restore
		
	
	
	
	// Wealth Shares
	*****************************************************
	foreach var in wdecile_1 wdecile_2 wdecile_3 wdecile_4 wdecile_5 wdecile_6 wdecile_7 wdecile_8 wdecile_9 top_10 top_5 top_1 {
			
		preserve
			
			keep if var=="`var'"
			
			// reshape
			expand 23
			bys country: gen year=1999+_n 
			gen value=.
			forvalues v=2000(1)2022 {
				replace value=v_`v' if year==`v'
			}
			
			keep country c3 var value year data_quality vname
			
			// auxialary for GC
			gen varcode="t-hs-dsh-netwea-ia"
			gen percentile=""
			
			tempfile a`var'
			save `a`var'', replace
		restore	
	}
	
	
	
	// Calculate wealth sahres: 
			** bottom 10% to 90%, bottom 99%
			** Mid 40%
			** Top 20, 10, 5, 1%
	preserve
		clear
		
		foreach var in wdecile_1 wdecile_2 wdecile_3 wdecile_4 wdecile_5 wdecile_6 wdecile_7 wdecile_8 wdecile_9 top_10 top_5 top_1 {
		 append using `a`var''	
		}
		
		drop vname
		
		// Bottom Shares from 10 to 90%
		gen help=.
		forvalues v=1(1)9 {
			replace help=`v' if var=="wdecile_`v'"
		}
		
		forvalues v=1(1)9 {
			bys country year: egen help_b`v'0_value=total(value) if help<=`v'
		}
		
		bys country year: gen help_b99_value=100-value if var=="top_1" 		
		
			
		// Mid 40%
		bys country year: egen help_m40_value=total(value) if help>=5 & help<=9
 		drop help
		
	
		// Top 
		bys country year: gen help_t10_value=value 	if var=="top_10"
		bys country year: gen help_t5_value=value 	if var=="top_5"
		bys country year: gen help_t1_value=value 	if var=="top_1"
		
		bys country year: egen help_t20_value=total(value) if var=="top_10" | var=="wdecile_9" 
		
		
		tempfile inter
		save `inter', replace
		
		ds help_*
		local help_CSshares=r(varlist)
		
		foreach var of local help_CSshares {
			use `inter', clear	
			keep if `var'!=.
			replace value=`var'
			
			** erase duplicates 
			bys country year value: gen help=_n
			keep if help==1
			drop help
			
			gen info="`var'"
			keep country c3 year data_quality value info

			
			tempfile a`var'
			save `a`var'', replace
		}
		
		clear
		foreach var of local help_CSshares {
			append using  `a`var''
		}
		
		
		// Auxilary for GC Wealth
		gen varcode="t-hs-dsh-netwea-ia"
		gen percentile=""
		
		forvalues v=1(1)9 {
			replace percentile="p0p`v'0" if info=="help_b`v'0_value"
		}
			replace percentile="p0p99" if info=="help_b99_value"
			
			replace percentile="p50p90" if info=="help_m40_value"
			
			
			replace percentile="p80p100" if info=="help_t20_value"
			replace percentile="p90p100" if info=="help_t10_value"
			replace percentile="p95p100" if info=="help_t5_value"
			replace percentile="p99p100" if info=="help_t1_value"
				
			drop info
		
		// append Back
		sort country year var
		tempfile shares
		save `shares', replace
	restore	




	// Welath Thresholds
	*****************************************************
	foreach var in wmin_1 wmin_2 wmin_3 wmin_4 wmin_5 wmin_6 wmin_7 wmin_8 wmin_9 min_top_10 min_top_5 min_top_1 {
			
		preserve
			
			keep if var=="`var'"
			
			// reshape
			expand 23
			bys country: gen year=1999+_n 
			gen value=.
			forvalues v=2000(1)2022 {
				replace value=v_`v' if year==`v'
			}
			
			keep country c3 var value year data_quality vname
			
			
			tempfile a`var'
			save `a`var'', replace
		restore	
	}
	
	
	// Apppend
	preserve
		clear
		
		foreach var in wmin_9 min_top_10 min_top_5 min_top_1 {
		 append using `a`var''	
		}
	
		
		// Auxilary for GC Wealth
		gen varcode="t-hs-thr-netwea-ia"
		gen percentile=""
		replace percentile="p80p100" 	if var=="wmin_9"
		replace percentile="p90p100" 	if var=="min_top_10"
		replace percentile="p95p100" 	if var=="min_top_5"
		replace percentile="p99p100" 	if var=="min_top_1"
		
		
		// National currency
		merge m:1 country year using `xr'
		drop _merge
		replace value=value*xr
		drop xr
	
	
		sort country year var
		tempfile thrs
		save `thrs', replace
	restore	

	

// Append All infos
********************************************************************************
	clear
	
	append using `mu'
	append using `gini'
	append using `shares'
	append using `thrs'
	
	sort country year var
	

	
// Final Settings for GC Wealth 
********************************************************************************
drop var vname


	// Keep only data with "good enough" quality
	keep if data_quality>=3 
	tab data_quality
	drop data_quality
	
	// Merge to area codes
	preserve
		import excel "./handmade_tables/dictionary.xlsx", ///
				firstrow sheet("GEO") clear
		
		rename GEO3 c3
		rename GEO area
		keep c3 area
		
		keep if c3!=""
		
		tempfile areas
		save `areas', replace
		
	restore
		
	merge m:1 c3 using `areas'	
	keep if _merge==3
	drop _merge
	
	tab country , m

********************************************************************************
// Drop Distributional Estimates for Bulgaria, Croatia, Czechia, Israel, ///
// Kazakhstan, Romania, Russia, Singapore, South Africa, Taiwan, and Turkey
// All these countries do not rely on distributional data!!!
********************************************************************************
gen help=1 if country=="Bulgaria" | country=="Croatia" | country=="Czechia"  ///
			| country=="Israel" | country=="Kazakhstan" | country=="Romania" ///
			| country=="Russia" | country=="Singapore" | country=="South Africa" ///
			| country=="Taiwan" | country=="Turkey"

drop if help==1 &  (varcode=="t-hs-dsh-netwea-ia" ///
		| varcode=="t-hs-gin-netwea-ia" ///
		| varcode=="t-hs-thr-netwea-ia")

keep  area year varcode percentile value 
order area year varcode percentile value 
	
bys varcode: tab percentile

gen source="`source'"
sort area varcode percentile year

// Exprt Dataset
export delimited "`results'", replace 
