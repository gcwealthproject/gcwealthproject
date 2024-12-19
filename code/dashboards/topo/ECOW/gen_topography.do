
** Set paths here
global path "${topo_dir_raw}/ECOW/auxiliary files"
global origin "${topo_dir_raw}/ECOW/raw data"
global intermediate "${topo_dir_raw}/ECOW/intermediate"
global aux "${topo_dir_raw}/ECOW/auxiliary files"


* We need to translate USD in Local Cur
clear
wid, indicators(xlcusx)
keep year value country
rename value cur
rename country area 
tempfile widcur
save  `widcur'


* Import dates
*import excel "${origin}/AOW_FW.xls", replace
import excel "${origin}\Data_tax_evasion_offshore_wealth_v3", clear firstrow   sheet("ECOW")
***

**** reshape data
forvalues t=2001(1)2016{
	preserve 
	keep Name d_`t'
	rename Name area
	rename d_`t' value
	gen year=`t'
	tempfile d_`t'
	save  `"d_`t'"', replace
	restore
}
clear
forvalues t=2001(1)2016{
append using d_`t'
erase "d_`t'.dta"
}

drop if value==.


*translate varcode   into year varcode value source sector percentile longname area
gen varcode="p-hs-agg-offsho-ga"
gen source="ECOW"
gen sector="hs"
gen percentile="p0p100"
replace area="Canada" if area=="Canada138 "
replace area="Czech Republic" if area=="Czechia"
kountry area, from(other) stuck
rename _ISO3N_ iso3
kountry iso3, from(iso3n) to(iso2c)
drop iso3 
rename area country
rename _ISO2C_ area



gen longname=""




keep year varcode value  source sector percentile longname area 

merge 1:1 year area using `widcur', nogen keep(1 3)


* transform value into local cur and adjust the billion
replace value=value*cur*1000000000
drop cur

*export
global output "${topo_dir_raw}/ECOW/final table"
save "${output}/ECOW_warehouse.dta", replace
export delimited using "${output}/ECOW_warehouse.csv", replace





