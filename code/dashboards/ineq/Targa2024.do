clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Targa2024
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local results "`sourcef'/final_table/`source'"

	

********************************************************************************		
/* 
What do we Need:
	// We use Gini provided in Figure 2
	// Average Wealth --> in nominal terms, not Euors
*/
********************************************************************************	
clear
set obs 10

gen area="CN"
gen year=.
gen value=.
gen percentile="p0p100"
gen varcode="t-hs-gin-netwea-ho" if _n<=5
replace varcode="t-hs-avg-netwea-ho" if _n>5
gen source="Targa2024"


// GINI
****************************************************
replace year=1995 if _n==1
replace year=2002 if _n==2
replace year=2013 if _n==3
replace year=2015 if _n==4
replace year=2017 if _n==5
//
replace value=55 if _n==1
replace value=47 if _n==2
replace value=61 if _n==3
replace value=57 if _n==4
replace value=62 if _n==5


// AV. net Welath
****************************************************
replace year=1995 if _n==6
replace year=2002 if _n==7
replace year=2013 if _n==8
replace year=2015 if _n==9
replace year=2017 if _n==10
//
replace value=24500 if _n==6
replace value=110900 if _n==7
replace value=664500 if _n==8
replace value=787800 if _n==9
replace value=979800 if _n==10

	
//export
qui export delimited "`results'", replace 
