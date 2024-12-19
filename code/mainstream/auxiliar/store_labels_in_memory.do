//Purpose: store labels from metadata_and_sources.xlsx in memory to filter 
//observations and fill varcode 

//list dictionaries 
local dictionaries d1_dashboard d2_sector d3_vartype d4_concept ///
	d5_dboard_specific

//store labels in working memory 
local llength = 80
foreach d in `dictionaries' {
	local dbd = substr("`d'", 2, 1)
	global d`dbd' = substr("`d'", 4, .)
	if `dbd' == 1 {
		display as result "{hline `llength'}"
		di as result ///
			"Metedata (for definitive labeling and filtering)"
		*di as text "    X - XX - XXX - XXXXXX - XX"	
		*di as text "code1 code2 code3  code4   code5"
		display as result "{hline `llength'}"
	}
	qui import excel ///
		"handmade_tables/dictionary.xlsx", sheet("`d'") firstrow ///
		clear case(lower)	
	cap confirm variable description 
	if _rc == 0 {
		local add_desc description 
	}
	else local add_desc 
	qui keep code label	`add_desc'
	qui levelsof code, local(codes`dbd') clean
	global codes`dbd' `codes`dbd''
	di as result "codes`dbd': `codes`dbd''"
	foreach c in `codes`dbd'' {
		qui levelsof label if code == "`c'", local(code`dbd'_`c') clean 
		global code`dbd'_`c' `code`dbd'_`c''
		di as text "   `c' label: ${code`dbd'_`c'}"
		cap levelsof description if code == "`c'", local(desc`dbd'_`c') clean
		if ustrregexra("`desc`dbd'_`c''", "[^[:ascii:][:alnum:][:punct:] \t\r\n]", "") != "" {
			local desc`dbd'_`c' = ///
				ustrregexra("`desc`dbd'_`c''", "[^[:ascii:][:alnum:][:punct:] \t\r\n]", "")
			global desc`dbd'_`c' `desc`dbd'_`c''
			di as result "          description: ${desc`dbd'_`c'}"
			di as result "this: `desc`dbd'_`c''"
		}
		
	}
	if `dbd' == wordcount("`dictionaries'") {
		display as result "{hline `llength'}"
	}
}
