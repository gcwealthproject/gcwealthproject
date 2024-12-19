clear all



local source Alvaredo2010
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/spain08.xls"
local results "`sourcef'/final_table/`source'"

///import Table_10D.8
qui import excel "`rawdata'", ///
	sheet("Table_10D.8") cellrange(A8:E34) firstrow clear

//reshape
//rename to reshape
rename (A B C) (year Top1 Top905)
rename (D E) (Top901 Top9001)

reshape long Top, i(year) j(percentiles)

//rename correctly
gen percentile = ""
qui replace percentile = "p99p100" if percentiles==1

qui replace percentile = "p99.5p100" if percentiles==905
qui replace percentile = "p99.9p100" if percentiles==901
qui replace percentile = "p99.99p100" if percentiles==9001

drop percentiles

//gen value
rename Top value
//drop missing
drop if missing(value)

//generate code variables
gen dashboard = "t"
gen sector = "hs"
gen vartype = "dsh"
gen concept = "netwea"
gen specific = "ia"

egen varcode = concat(dashboard sector vartype concept specific), ///
	punct ("-")  

drop dashboard sector vartype concept specific

//gen warehouse variables	
gen area = "ES"
gen source = "Alvaredo2010"

//gen method of estimation - data_type
//qui gen data_type = "wt"

//order
order area year value percentile varcode

//export
qui export delimited "`results'", replace 
