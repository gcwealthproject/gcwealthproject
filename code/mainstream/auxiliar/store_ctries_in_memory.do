*list countries 
qui import excel ///
	"handmade_tables/dictionary.xlsx", sheet("GEO") firstrow clear
qui drop if GEO == "_na" | missing(GEO)	
qui keep Country GEO GEO3	
tempfile tf_geoctr 
qui save `tf_geoctr'

*list regions within countries 
qui import excel ///
	"handmade_tables/dictionary.xlsx", sheet("GEOReg") firstrow clear 
qui rename (Country_Label Region_Label Meaning) (GEO geo_r Region)
qui drop if GEO == "_na" | missing(GEO)	
qui keep GEO geo_r Region 
qui merge m:1 GEO using `tf_geoctr', keep(3) nogen 
qui replace GEO = GEO + "_" + geo_r 
qui replace Country = Country + ", " + Region
qui drop GEO3 geo_r Region
tempfile tf_georeg 
qui save `tf_georeg'

*append countries and region 
qui use `tf_geoctr', clear 
qui append using `tf_georeg'
qui sort GEO 

*memorize values 
qui levelsof GEO, clean local(geos) 
global geos `geos'
di as result "Allowed ISO codes: ${geos}"
foreach g in $geos {
	qui levelsof Country if GEO == "`g'", clean local(lab_`g')
	global lab_`g' `lab_`g''
	qui levelsof GEO3 if GEO == "`g'" & !missing(GEO3), clean local(`g'iso3)
	global iso3_`g' ``g'iso3'
}	
