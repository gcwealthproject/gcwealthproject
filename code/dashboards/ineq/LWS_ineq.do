//settings
clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source LWS_ineq
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
*local rawdata_anw "`sourcef'/raw data/LWS_ineq_anw_29Mar2023.csv"
*local rawdata_dnw "`sourcef'/raw data/LWS_ineq_dnw_29Mar2023.csv"
*local rawdata_anw "`sourcef'/raw data/LWS_ineq_anw_04Jan2024_expanded.csv"
*local rawdata_dnw "`sourcef'/raw data/LWS_ineq_dnw_04Jan2024_expanded.csv"

local rawdata_anw "`sourcef'/raw data/LWS_ineq_anw_07Jul2024_expanded.csv"
local rawdata_dnw "`sourcef'/raw data/LWS_ineq_dnw_07Jul2024_expanded.csv"


local results "`sourcef'/final_table/`source'"


// Some countryes have only dnw and not anw 
********************************************************************************

	// A(djusted)nw Countries
	qui import delimited "`rawdata_anw'", clear varnames(1)
	qui collapse (mean) value, by(country year)

	keep country year
	tempfile anw
	save `anw' , replace
	
	
	// D(isposable)nw Countries
	qui import delimited "`rawdata_dnw'", clear varnames(1)
	qui collapse (mean) value, by(country year)
	
	keep country year
	tempfile dnw
	save `dnw' , replace
	
	
	
	// Spot Missings
	clear
	use `anw'
	merge 1:1 country year using `dnw'
	drop if country==""
		
		// Check no Countries that for some years have anw
		bys country: egen h_min=min(_merge)
		bys country: egen h_max=max(_merge)
	
		*replace _merge=2 if h_min!=h_max
	

	levelsof country if _merge==1 | _merge==3 , c local(anw_countries)
	levelsof country if _merge==2 , c local(dnw_countries)
	
	// Italy for 94 and 2000 only DNW, afterwards both!
	
	
	
// Generate Dataset
********************************************************************************
	
// Start with Adj
foreach nw in anw dnw {
	
	qui import delimited "`rawdata_`nw''", clear varnames(1)
		
	qui collapse (mean) value, by(country year variable)

	gen keep=.
	foreach cc of local `nw'_countries {
		replace keep=1 if country=="`cc'"
	}
	
	keep if keep==1
	drop keep
	
	//clean
	drop if strpos(variable, "`nw'")
	drop if strpos(variable, "adpop")
	drop if missing(value)


	//adjust value
	qui replace value = value * 100 if variable == "gini"
	qui replace value = value * 100 if variable == "b50_sh"
	qui replace value = value * 100 if variable == "m40_sh"
	qui replace value = value * 100 if variable == "t20_sh"
	qui replace value = value * 100 if variable == "t10_sh"
	qui replace value = value * 100 if variable == "t1_sh"
	qui replace value = value * 100 if variable == "t5_sh"

	
	//percentiles
	qui gen percentile = ""
		qui replace percentile = "p0p100" if variable == "gini"
		qui replace percentile = "p0p100" if variable == "average"
		qui replace percentile = "p80p100" if variable == "t20_sh"
		qui replace percentile = "p90p100" if variable == "t10_sh"
		qui replace percentile = "p95p100" if variable == "t5_sh"
		qui replace percentile = "p99p100" if variable == "t1_sh"
		qui replace percentile = "p50p90" if variable == "m40_sh"
		qui replace percentile = "p0p50" if variable == "b50_sh"
		
		qui replace percentile = "p0p50" 	if variable == "b50_av"
		qui replace percentile = "p50p90" 	if variable == "m40_av"
		qui replace percentile = "p80p100" 	if variable == "t20_av"
		qui replace percentile = "p90p100" 	if variable == "t10_av"
		qui replace percentile = "p95p100" 	if variable == "t5_av"
		qui replace percentile = "p99p100" 	if variable == "t1_av"
		
		qui replace percentile = "p50p90" 	if variable == "thr50"
		qui replace percentile = "p80p100" 	if variable == "thr80"
		qui replace percentile = "p90p100" 	if variable == "thr90"
		qui replace percentile = "p95p100" 	if variable == "thr95"
		qui replace percentile = "p99p100" 	if variable == "thr99"
		
		
	//generate code variables
	gen dashboard = "t"
	gen sector = "hs"
	gen vartype = "dsh"
	gen concept = "netwea"
	gen specific = "ho"
	qui replace vartype = "gin" if strpos(variable, "gini")
	qui replace vartype = "avg" if strpos(variable, "average")
	qui replace vartype = "avg" if strpos(variable, "av")
	qui replace vartype = "thr" if strpos(variable, "thr")
	gen source = "`source'"
	

	egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  
	drop dashboard sector vartype concept specific variable

	//clean
	rename country area

	//order
	order area year value percentile source varcode

	
	if "`nw'"=="anw"{
		// Italy has both anw and dnw after 2000
		drop if area=="IT" & year>2000
	}
	

	
	//save
	tempfile tf_lws_`nw'
	save `tf_lws_`nw'' , replace

} 


clear

//append
qui append using `tf_lws_anw'
qui append using `tf_lws_dnw'

sort area year


//export
export delimited "`results'", replace


// Check
preserve 
bys area year percentile varcode: gen N=_N
tab N
restore

/*
// Example
preserve
keep if area=="US"
twoway 	(line value year if varcode=="t-hs-thr-netwea-ho" & percentile=="p50p90") ///
		(line value year if varcode=="t-hs-thr-netwea-ho" & percentile=="p80p100") ///
		(line value year if varcode=="t-hs-thr-netwea-ho" & percentile=="p90p100") ///
		(line value year if varcode=="t-hs-thr-netwea-ho" & percentile=="p95p100") ///
		
		
*/		