
** Set paths here
run "code/mainstream/auxiliar/all_paths.do"
tempfile all

	
* Origin folder: it contains the excel files to import
global origin "${topo_dir_raw}/ECB_QSA/raw data/csv files" 

* Auxiliary folder
global aux "${topo_dir_raw}/ECB_QSA/auxiliary files" 

* Intermediate to erase
global intermediate "${topo_dir_raw}/ECB_QSA/intermediate to erase" 

* Destination folder
global destination "${topo_dir_raw}/ECB_QSA/intermediate" 


foreach s in S1M S14 S15{

	foreach c in austria belgium bulgaria croatia cyprus czechrep denmark ///
	estonia finland france germany greece hungary ireland italy latvia ///
	lithuania luxembourg malta netherlands poland portugal ///
	romania slovakia slovenia spain sweden gb {

		qui import delimited "${origin}/`c'_qsa.csv", varnames(1) ///
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

		qui replace na_code = subinstr(na_code, "QSA.Q.N.", "", .) // Delete Dataset name

		if "`c'" == "austria" {
			qui replace na_code = subinstr(na_code, "AT.", "", .) // Delete area
		}
		else if "`c'" == "belgium" {
			qui replace na_code = subinstr(na_code, "BE.", "", .) // Delete area
		}
		else if "`c'" == "bulgaria" {
			qui replace na_code = subinstr(na_code, "BG.", "", .) // Delete area
		}
		else if "`c'" == "croatia" {
			qui replace na_code = subinstr(na_code, "HR.", "", .) // Delete area
		}
		else if "`c'" == "cyprus" {
			qui replace na_code = subinstr(na_code, "CY.", "", .) // Delete area
		}
		else if "`c'" == "czechrep" {
			qui replace na_code = subinstr(na_code, "CZ.", "", .) // Delete area
		}	   
		else if "`c'" == "denmark" {
			qui replace na_code = subinstr(na_code, "DK.", "", .) // Delete area
		}		   
		else if "`c'" == "estonia" {
			qui replace na_code = subinstr(na_code, "EE.", "", .) // Delete area
		}	   
		else if "`c'" == "finland" {
			qui replace na_code = subinstr(na_code, "FI.", "", .) // Delete area
		}		   
		else if "`c'" == "france" {
			qui replace na_code = subinstr(na_code, "FR.", "", .) // Delete area
		}		   
		else if "`c'" == "germany" {
			qui replace na_code = subinstr(na_code, "DE.", "", .) // Delete area
		}		   
		else if "`c'" == "greece" {
			qui replace na_code = subinstr(na_code, "GR.", "", .) // Delete area
		}	   
		else if "`c'" == "hungary" {
			qui replace na_code = subinstr(na_code, "HU.", "", .) // Delete area
		}		   
		else if "`c'" == "ireland" {
			qui replace na_code = subinstr(na_code, "IE.", "", .) // Delete area
		}		   
		else if "`c'" == "italy" {
			qui replace na_code = subinstr(na_code, "IT.", "", .) // Delete area
		}	   
		else if "`c'" == "latvia" {
			qui replace na_code = subinstr(na_code, "LV.", "", .) // Delete area
		}	
		else if "`c'" == "lithuania" {
			qui replace na_code = subinstr(na_code, "LT.", "", .) // Delete area
		}		   
		else if "`c'" == "luxembourg" {
			qui replace na_code = subinstr(na_code, "LU.", "", .) // Delete area
		}		   
		else if "`c'" == "malta" {
			qui replace na_code = subinstr(na_code, "MT.", "", .) // Delete area
		}
		else if "`c'" == "netherlands" {
			qui replace na_code = subinstr(na_code, "NL.", "", .) // Delete area
		}	   
		else if "`c'" == "poland" {
			qui replace na_code = subinstr(na_code, "PL.", "", .) // Delete area
		}		   
		else if "`c'" == "portugal" {
			qui replace na_code = subinstr(na_code, "PT.", "", .) // Delete area
		}			   
		else if "`c'" == "romania" {
			qui replace na_code = subinstr(na_code, "RO.", "", .) // Delete area
		}		   
		else if "`c'" == "slovakia" {
			qui replace na_code = subinstr(na_code, "SK.", "", .) // Delete area
		}
		else if "`c'" == "slovenia" {
			qui replace na_code = subinstr(na_code, "SI.", "", .) // Delete area
		}	   
		else if "`c'" == "spain" {
			qui replace na_code = subinstr(na_code, "ES.", "", .) // Delete area
		}	   
		else if "`c'" == "sweden" {
			qui replace na_code = subinstr(na_code, "SE.", "", .) // Delete area
		}	
		else if "`c'" == "gb" {
			qui replace na_code = subinstr(na_code, "GB.", "", .) // Delete area
		}

		// Delete Counterpart ara (W0: World), 
		// Frequency, Adjustment indicator (N: Neaither seasonally adjusted nor calendar adjusted), 
		// Reference sector (S1M: Households and NPISH/S14:Households/S15:NPISH), 
		// Counterpart sector (S1: Total economy)
		
		qui replace na_code = subinstr(na_code, "W0.`s'.S1.N.", "", .) 
		qui replace na_code = subinstr(na_code, "._Z.XDC._T.S.V.N._T", "", .) // Delete Counterpart ara (W0: World)
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

		qui export excel "${destination}/grid", sheet("`c'_`s'", replace) firstrow(variables) 
 


}

}
