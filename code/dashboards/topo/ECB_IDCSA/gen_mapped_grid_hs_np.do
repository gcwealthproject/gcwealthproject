
** Set paths here
run "code/mainstream/auxiliar/all_paths.do"
tempfile all

* Origin folder: it contains the excel files to import
global origin "${topo_dir_raw}/ECB_IDCSA/raw data/csv files" 

* Auxiliary folder
global aux "${topo_dir_raw}/ECB_IDCSA/auxiliary files" 

* Intermediate to erase
global intermediate "${topo_dir_raw}/ECB_IDCSA/intermediate to erase" 

* Destination folder
global destination "${topo_dir_raw}/ECB_IDCSA/intermediate"



** DISAGGREGATED SECTORS


foreach s in S14 S15 {


	foreach c in canada colombia iceland israel japan mexico newzealand ///
		northmacedonia norway switzerland turkey gb {		
	
	qui import delimited "${origin}/`c'_idcs.csv", varnames(1) ///
			delimiter(comma) clear 

	qui rename datasource* datasource
	qui keep if datasource == ""
	qui drop datasource
	qui gen index = ""
	qui replace index = "source_code" if [_n] == 1
	qui replace index = "varname_source" if [_n] == 2
	qui order index, first 

	qui sxpose, clear firstnames
	
	qui keep if strpos(source_code, "`s'")
	
	qui gen na_code = source_code
	qui order na_code, before(source_code)

	qui replace na_code = subinstr(na_code, "IDCS.A.N.", "", .) // Delete Dataset name
		
	if "`c'" == "albania" {
		qui replace na_code = subinstr(na_code, "AL.", "", .) // Delete area
	}
	else if "`c'" == "brazil" {
		qui replace na_code = subinstr(na_code, "BR.", "", .) // Delete area
	}
	else if "`c'" == "canada" {
		qui replace na_code = subinstr(na_code, "CA.", "", .) // Delete area
	}
	else if "`c'" == "chile" {
		qui replace na_code = subinstr(na_code, "CL.", "", .) // Delete area
	}
		qui else if "`c'" == "colombia" {
		replace na_code = subinstr(na_code, "CO.", "", .) // Delete area
	}
	else if "`c'" == "iceland" {
		qui replace na_code = subinstr(na_code, "IS.", "", .) // Delete area
	}	   
	else if "`c'" == "israel" {
		qui replace na_code = subinstr(na_code, "IL.", "", .) // Delete area
	}			   
	else if "`c'" == "japan" {
		qui replace na_code = subinstr(na_code, "JP.", "", .) // Delete area
	}	   
	else if "`c'" == "korea" {
		qui replace na_code = subinstr(na_code, "KR.", "", .) // Delete area
	}		   
	else if "`c'" == "mexico" {
		qui replace na_code = subinstr(na_code, "MX.", "", .) // Delete area
	}		   
	else if "`c'" == "newzealand" {
		qui replace na_code = subinstr(na_code, "NZ.", "", .) // Delete area
	}		   
	else if "`c'" == "northmacedonia" {
		qui replace na_code = subinstr(na_code, "MK.", "", .) // Delete area
	}	   
	else if "`c'" == "norway" {
		qui replace na_code = subinstr(na_code, "NO.", "", .) // Delete area
	}		   
	else if "`c'" == "russia" {
		qui replace na_code = subinstr(na_code, "RU.", "", .) // Delete area
	}		   
	else if "`c'" == "switzerland" {
		qui replace na_code = subinstr(na_code, "CH.", "", .) // Delete area
	}	   
	else if "`c'" == "turkey" {
		qui replace na_code = subinstr(na_code, "TR.", "", .) // Delete area
	}	
	else if "`c'" == "gb" {
		qui replace na_code = subinstr(na_code, "GB.", "", .) // Delete area
	}		   
	else if "`c'" == "usa" {
		qui replace na_code = subinstr(na_code, "US.", "", .) // Delete area
	}
		   
	// Delete Counterpart ara (W0: World), 
	// Frequency, Adjustment indicator (N: Neaither seasonally adjusted nor calendar adjusted), 
	// Reference sector (S1M: Households and NPISH/S14:Households/S15:NPISH), 
	// Counterpart sector (S1: Total economy)
	
	qui replace na_code = subinstr(na_code, "W0.`s'.S1.N.", "", .) 	
	qui replace na_code = subinstr(na_code, "._Z.XDC._T.S.V.N._T", "", .) 	
	qui replace na_code = subinstr(na_code, "._Z", "", .) // Delete the rest
	qui replace na_code = subinstr(na_code, ".T", "", .) // Delete "original maturities"
	qui replace na_code = subinstr(na_code, "A.LE.", "A_A", .) // Replace financial assets
	qui replace na_code = subinstr(na_code, "L.LE.", "L_A", .) // Replace liabilities
	qui replace na_code = subinstr(na_code, ".S", "1", .) // Delete "short maturities"
	qui replace na_code = subinstr(na_code, ".L", "2", .) // Delete "long maturities"
	
	qui save "${intermediate}/intermediate_mapping.dta", replace

	qui import excel "${aux}/grid_empty.xlsx", sheet("grid_empty") firstrow clear 

	qui drop source_code varname_source

	qui merge m:1 na_code using "${intermediate}/intermediate_mapping.dta"

	qui drop _merge
	qui drop if na_code == "" & nacode_label == "" &  source_code == "" &  varname_source == ""
	qui drop if  source_code == "" &  varname_source == "" 

	qui drop source_code
	qui drop if nacode_label == "" // drop extra country-source-sector related items

	export excel "${destination}/grid_hs_np", sheet("`c'_`s'", modify) firstrow(variables) 

}
}
