clear all


local source Brandolini2006
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Brandolini2004.xlsx"
local results "`sourcef'/final_table/`source'"



//import - Table 6 Tranpose - Adjusted
********************************************************************************
qui import excel "`rawdata'", /// 
	sheet("Transpose") cellrange(A10:L16) firstrow clear
	
	
//clean
drop Populationshare1 Halfsquaredcoefficientofvari VH2 Next40 Mean3

rename (Statistic Bottom40percent) (year Bottom40)
rename (Top20percent Top10percent Top5percent) (Top20 Top10 Top5)
rename (Top1percent Giniindex) (Top1 Gini)

// Reshape
tempfile toexpand
save `toexpand' , replace
ds year, not
local X=r(varlist)
clear
gen help=""
gen value=.
foreach x of local X {
	append using `toexpand'
	replace help="`x'" if help==""
	replace value=`x' if help=="`x'"
}

keep help year value


// Add variables
gen area="IT"

gen percentile = ""
replace percentile = "p0p40" 	if help=="Bottom40"
replace percentile = "p80p100" 	if help=="Top20"
replace percentile = "p90p100" 	if help=="Top10"
replace percentile = "p95p100" 	if help=="Top5"
replace percentile = "p99p100" 	if help=="Top1"
replace percentile = "p0p100" 	if help=="Gini"
replace percentile = "p0p100" 	if help=="Average"


// Gini value corrrectly

replace value = value * 100 if help == "Gini"
 
 // Varcode
gen varcode=""
replace varcode="t-hs-gin-netwea-ho" if help=="Gini"
replace varcode="t-hs-dsh-netwea-ho" if help!="Gini"

gen source = "Brandolini2006"




// Keep and order
keep  area year value percentile varcode source
order area year value percentile varcode source



// Export
qui export delimited using ///
	"`results'", replace

