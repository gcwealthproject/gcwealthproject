
local source BoI_FA
run "code/mainstream/auxiliar/all_paths.do"


// gen grid_stock.dta
do "${topo_pro}/BoI_FA/codes/create_grid_stock.do"

// gen  grid
do "${topo_pro}/BoI_FA/codes/gen_mapped_grid.do"
qui di as result "grid has been generated!"
pwd


//run translate
do "${topo_pro}/BoI_FA/codes/translate.do"
qui di as result "raw data have been translated!"
pwd


//gen metadata
do "${topo_pro}/BoI_FA/codes/gen_metadata.do"
di as result "metadata have been generated!"
pwd 


//gen topography
do "${topo_pro}/BoI_FA/codes/gen_topography.do"
qui di as result "topography have been generated!"
qui di as result "topography have saved in final table/BoI_FA_warehouse.dta!"
pwd 





