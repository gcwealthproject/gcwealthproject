//general settings 
clear all 
run "code/mainstream/auxiliar/all_paths.do"
run "code/mainstream/auxiliar/version_control.do" //centralized version control
	
//run all code from EIG 
display as result "running 1_0_EIGT_Warehouse.do..."
run "code/dashboards/eigt/1_0_EIGT_Warehouse.do"

di as result "done building EIG tax!"

