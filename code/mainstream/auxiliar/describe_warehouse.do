//store variable types, formats and ranks 
qui describe, replace clear 
qui replace name = subinstr(name, "_", "", .)
qui replace name = "v" + name 
qui levelsof name, local(whvars_${wht}) clean 
global whvars_${wht} `whvars_${wht}'
foreach v in `whvars_$wht' {
	foreach u in type format position isnumeric {
		local u2 = substr("`u'", 1, 3)
		qui levelsof `u' if name == "`v'", local(`v'_`u2'_${wht}) clean 
		global `v'_`u2'_${wht} = "``v'_`u2'_${wht}'"
	}
}
