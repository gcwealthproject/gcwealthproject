/////////////////////////
/// Main do file for EIGT translation from old to new structure
/////////////////////////

/// Last update: 4 November 2024
/// Author: Francesca

////////////////////////////////////////////////////////////////////////////////
/// STEP 0: General setting

	clear

// Working directory and paths

	*** automatized user paths
	global username "`c(username)'"
	
	dis "$username" // Displays your user name on your computer
		
	* Francesca
	if "$username" == "fsubioli" { 
		global dir  "/Users/`c(username)'/Dropbox/gcwealth" 
	}	
	if "$username" == "Francesca Subioli" | "$username" == "Francesca" | "$username" == "franc" { 
		global dir  "C:/Users/`c(username)'/Dropbox/gcwealth" 
	}	
	* Luca 
	if "$username" == "lgiangregorio" | "$username" == "lucagiangregorio" { 
		global dir  "/Users/`c(username)'/Dropbox/gcwealth" 
	}
	
	global dofile "$dir/code/dashboards/eigt"
	global intfile "$dir/raw_data/eigt/intermediary_files"
	global hmade "$dir/handmade_tables"
	global supvars "$dir/output/databases/supplementary_variables"
	                   
	cd "$dir"
	
	global supvarver 16Jul2024
	global oecdver 22mar2024
	
////////////////////////////////////////////////////////////////////////////////
/// STEP 1: Country-level data

	display as result "Checking tax schedule data for countries..."
	do "$dofile/0_1_Countries_Taxsch_Check.do"

	display as result "Updating the currency..."
	display as result "Supvar version $supvarver"
	display as result "OECD version $oecdver"	

	do "$dofile/0_2_Countries_Currency_Update.do"
	
	display as result "Translating into the new structure..."
	do "$dofile/0_3_Countries_Translation.do"

	
////////////////////////////////////////////////////////////////////////////////
/// STEP 2: New country-level data	
	
	display as result "Translating into the new structure..."
	do "$dofile/0_4_NewData_Adjustment.do"
	
////////////////////////////////////////////////////////////////////////////////
/// STEP 3: Regional-level data	

	display as result "Checking tax schedule data for US states..."
	do "$dofile/0_5_Regions_Taxsch_Check.do"
	
	display as result "Checking revenue data for US states..."
	do "$dofile/0_6_Regions_Revenues_Check.do"
	
	display as result "Translating US states into the new structure..."
	do "$dofile/0_7_Regions_Translation.do"

