//generate longname 1-2 (from the 02a tranlator)
qui levelsof varcode, local(allvarcodes) clean 
forval n = 1/2 {
	qui gen lg`n' = ""
}
foreach v in `allvarcodes' {
	di as result "`v': `longname'"
	local ss1 = substr("`v'", 1, 1) 
	local ss2 = substr("`v'", 3, 2) 
	local ss3 = substr("`v'", 6, 3) 
	local ss4 = substr("`v'", 10, 6) 
	local ss5 = substr("`v'", 17, 2) 
	
	*display on screen 
	forvalues x = 1/5 {
		``x'_code_`c''
		di as result "ss`x': `ss`x'' " _continue
		di as text "-label: ${code`x'_`ss`x''}"
	}
	di as result "" _continue
	di as result "(${code5_`ss5'})"
	
	*replace variables
	qui replace lg1 = "${code3_`ss3'} " if varcode == "`v'" 
	qui replace lg2 = ///
		" ${code4_`ss4'}, of the ${code2_`ss2'} sector (${code5_`ss5'})" ///
		if varcode == "`v'"
}

*fill longname 
qui egen lg3 = concat(lg1 percentile lg2), punct("-") 
qui egen lg4 = concat(lg1 lg2)
cap drop longname
qui gen longname = ""
qui replace longname = lg3 if substr(varcode, 1, 1) == "t"
qui replace longname = lg4 if substr(varcode, 1, 1) != "t"
drop lg1 lg2 lg3 lg4 

//order
order area year val* percentile varcode longname
