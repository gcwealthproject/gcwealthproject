//check that some variables are not missing 
foreach v in $checkvars {
	cap assert !missing(`v') 
	if _rc != 0 {
		qui levelsof source if missing(`v'), local(miss) clean
		di as error ///
			"The following source(s) have missing `v': `miss'. " ///
			"Solve the issue and try again. If you want to override " ///
			"this, comment the -run $check_nonmissings- line in the " ///
			"current do file"
		levelsof varcode if missing(`v'), local(miss2) clean	
		di as text "missing varcodes: " 
		foreach m in `miss2' {
			di as text "`m'"
		}
		exit 10 
	}
}
