//settings
clear all
local source StatisticsNorway
run "code/mainstream/auxiliar/all_paths.do"

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/Statistics_Norway_2022_06_24.xlsx"
local results "`sourcef'/final_table/`source'"

//import - wealth shares 
qui import excel "`rawdata'", sheet("inequality-indicators") ///
	cellrange (A1:O12) firstrow clear

//clean
gen year = real(A)
drop A Total

//rename to reshape
rename (Decile10 Decile1) (Top10 Top910)
rename (Top5percent Top1percent Top01percent) (Top5 Top1 Top901)

//gen new variables
gen Top920 = Top910 + Decile2
gen Top930 = Top920 + Decile3
gen Top940 = Top930 + Decile4
gen Top950 = Top940 + Decile5
gen Top960 = Top950 + Decile6
gen Top970 = Top960 + Decile7
gen Top980 = Top970 + Decile8
gen Top990 = Top980 + Decile9
gen Top5090 =  Decile6 + Decile7 + Decile8 + Decile9
gen Top20 = Top10 + Decile9
gen Top909 = Top10 - Top1
gen Top905 = Top5 - Top1
drop Decile*
	
//reshape
reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1
qui replace percentile = "p90p100" if percentiles==10
qui replace percentile = "p0p50" if percentiles==950
qui replace percentile = "p50p90" if percentiles==5090
qui replace percentile = "p80p100" if percentiles==20
qui replace percentile = "p95p100" if percentiles==5
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p90p99" if percentiles==909
qui replace percentile = "p95p99" if percentiles==905
qui replace percentile = "p0p10" if percentiles==910
qui replace percentile = "p0p20" if percentiles==920
qui replace percentile = "p0p30" if percentiles==930
qui replace percentile = "p0p40" if percentiles==940
qui replace percentile = "p0p60" if percentiles==960
qui replace percentile = "p0p70" if percentiles==970
qui replace percentile = "p0p80" if percentiles==980
qui replace percentile = "p0p90" if percentiles==990
drop percentiles

//gen value
rename Top value
qui replace value = value * 100 if percentile=="p0p100"
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
qui replace vartype = "gin" if percentile=="p0p100"
gen concept = "netwea"
gen specific = "ho"

egen varcode = concat(dashboard sector vartype concept specific), punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "NO"
gen source = "`source'"

//gen method of estimation - 
//qui gen data_type = "" 

order area year value percentile varcode 

//export
qui export delimited "`results'", replace
