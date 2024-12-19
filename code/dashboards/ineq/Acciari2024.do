clear all

*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source Acciari2024
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/TopW_All_benchmark.xlsx"
local results "`sourcef'/final_table/`source'"

///import
qui import excel "`rawdata'", ///
	cellrange (A1:X23) firstrow clear
	
//clean
drop Top50_DINA_missadj Top1_01_DINA_missadj ///
	 Top1_001_DINA_missadj Top01_001_DINA_missadj ///
	 
//reshape
//rename to reshape
rename (Top10_DINA_missadj Top5_DINA_missadj Top1_DINA_missadj) (Top10 Top5 Top1)
rename (Top10_1_DINA_missadj Bottom50_DINA_missadj) (Top9 Top50)
rename (Bottom90_DINA_missadj Mid40_DINA_missadj) (Top90 Top40)
rename (Top05_DINA_missadj Top001_DINA_missadj) (Top805 Top8001)
rename (Top01_DINA_missadj Top005_DINA_missadj) (Top801 Top8005)

rename (PTop50_DINA_missadj PTop10_DINA_missadj) (Top950 Top910)
rename (PTop5_DINA_missadj	PTop1_DINA_missadj) (Top95 Top91)
rename (PTop05_DINA_missadj PTop01_DINA_missadj) (Top905 Top901)
rename (PTop005_DINA_missadj PTop001_DINA_missadj) (Top9005 Top9001)

reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p99" if percentiles==9
qui replace percentile = "p0p50" if percentiles==50
qui replace percentile = "p0p90" if percentiles==90
qui replace percentile = "p50p90" if percentiles==40

qui replace percentile = "p99.5p100" if percentiles==805
qui replace percentile = "p99.99p100" if percentiles==8001
qui replace percentile = "p99.9p100" if percentiles==801
qui replace percentile = "p99.95p100" if percentiles==8005

qui replace percentile = "p50p100_thr" if percentiles==950
qui replace percentile = "p90p100_thr" if percentiles==910
qui replace percentile = "p99p100_thr" if percentiles==91
qui replace percentile = "p95p100_thr" if percentiles==95
qui replace percentile = "p99.5p100_thr" if percentiles==905
qui replace percentile = "p99.9p100_thr" if percentiles==901
qui replace percentile = "p99.95p100_thr" if percentiles==9005
qui replace percentile = "p99.99p100_thr" if percentiles==9001

drop percentiles

//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "thr" if strpos(percentile, "thr")
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "IT"
gen source = "`source'"

//gen method of estimation - data_type
//qui gen data_type = "ns"

//rename thresholds
qui replace percentile = "p50p100" if percentile=="p50p100_thr"
qui replace percentile = "p90p100" if percentile=="p90p100_thr"
qui replace percentile = "p99p100" if percentile=="p99p100_thr"
qui replace percentile = "p95p100" if percentile=="p95p100_thr"
qui replace percentile = "p99.5p100" if percentile=="p99.5p100_thr"
qui replace percentile = "p99.9p100" if percentile=="p99.9p100_thr"
qui replace percentile = "p99.95p100" if percentile=="p99.95p100_thr"
qui replace percentile = "p99.99p100" if percentile=="p99.99p100_thr"

//order
order area year value percentile varcode



// Include GINI - Online Appendix Table S.1
****************************************
preserve
	clear
	set obs 2021 
	gen area="IT"
	gen percentile="p0p100"
	gen varcode="t-hs-gin-netwea-ia"
	gen source="`source'"
	gen year=_n
	
	gen value=.
	replace value	=	0.634702 	*100 if year==	1995
	replace value	=	0.666122	*100 if year==	1998
	replace value	=	0.672303	*100 if year==	2000
	replace value	=	0.737292 	*100 if year==	2006
	replace value	=	0.742224	*100 if year==	2008
	replace value	=	0.762512	*100 if year==	2010
	replace value	=	0.784706 	*100 if year==	2012
	replace value	=	0.777488	*100 if year==	2014
	replace value	=	0.763752	*100 if year==	2016
			
	drop if value==.	
	list	
	tempfile gini
	save `gini' , replace
restore

append using `gini'
	

//export
qui export delimited "`results'", replace 
