//harmonize country names 
qui replace GEO = "NO" if GEO == "N0"
qui replace GEO = "UK" if GEO == "GB"
