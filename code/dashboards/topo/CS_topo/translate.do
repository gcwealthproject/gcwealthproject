// CS
// translate


** Set paths here
global intermediate_to_erase "${topo_dir_raw}/CS_topo/intermediate to erase"
global origin "${topo_dir_raw}/CS_topo/raw data"

//prepare currency data

use "${origin}/wealth_data_wide.dta", clear

qui keep if  var == "xr"
qui  reshape long v_, i(level country c3 region var wealth_rank data_quality EuroZone emerging vname) j(year)



* Step 2: Rename the variable for clarity
qui  rename v_ cur
qui  keep if data_quality>2

qui kountry c3, from(iso3c) to(iso2c)

qui rename _ISO2C_ area

qui keep area cur year

qui keep if year<=2023
drop if area==""
tempfile cur
save `cur' 

//import raw data

use "${origin}/wealth_data_wide.dta", clear


* Filter by specific variables
qui  keep if var == "totw" | var == "totf" | var == "totn" | var == "totd"


* Step 1: Specify the data structure before reshaping
qui  reshape long v_ , i(level country c3 region var wealth_rank data_quality EuroZone emerging vname) j(year)

* Step 2: Rename the variable for clarity
qui  rename v_ value


*Data quality at least "fair"
qui  keep if data_quality>2

// the next to lines make the variable names the same to those on CS website
drop if c3==""


qui kountry c3, from(iso3c) to(iso2c)

qui  rename _ISO2C_ area


* drop later projected values
keep if year<=2022


qui gen totw = value if var== "totw"
qui gen totd = value if var== "totd"
qui gen totf = value if var== "totf"
qui gen totn = value if var== "totn"

* reduce dataset to one year-country observation
qui gen id = _n
qui gen totw_var = .
qui replace totw_var = totw if !missing(totw)

qui gen totd_var = .
qui replace totd_var = totd if !missing(totd)

qui gen totf_var = .
qui replace totf_var = totf if !missing(totf)

qui gen totn_var = .
qui replace totn_var = totn if !missing(totn)
qui collapse (max) totw_var totd_var totf_var totn_var, by(area year)

qui rename totw_var totw
qui rename totd_var totd
qui rename totf_var totf
qui rename totn_var totn

*transform from USD into local currency
qui merge 1:1 area year using `cur', nogen

qui replace totw=totw*cur
qui replace totn=totn*cur
qui replace totf=totf*cur
qui replace totd=totd*cur

qui drop cur

// generate sector and source variable

qui gen source="CS_topo"

qui gen sector = "hs"
qui order area source sector year 

save "${topo_dir_raw}/CS_topo/intermediate/populated_grid_hs.dta", replace




