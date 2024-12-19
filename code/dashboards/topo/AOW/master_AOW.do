
local source AOW
run "code/mainstream/auxiliar/all_paths.do"

//gen topography
do "${topo_pro}/AOW/codes/gen_topography.do"
qui di as result "topography have been generated!"
qui di as result "topography have saved in final table/AOW_warehouse.dta!"
pwd 


//gen metadata
do "${topo_pro}/AOW/codes/gen_metadata.do"
di as result "metadata have been generated!"
pwd 






