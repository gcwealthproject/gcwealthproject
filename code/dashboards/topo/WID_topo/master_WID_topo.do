
// Master WID file 
//to update the underlying dataset, ///
//run 'codes/1_download_data.do' ///


local source WID_topo
run "code/mainstream/auxiliar/all_paths.do"

// gen grid that matches source and codes
qui do "${topo_pro}/WID_topo/codes/gen_mapped_grid"
qui di as result "grid has been generated!"
pwd

// translate raw data and populate grid
qui do "${topo_pro}/WID_topo/codes/translate"
qui di as result "raw data have been translated and the grid has been populated!"
pwd

// create metadata
qui do "${topo_pro}/WID_topo/codes/gen_metadata"
di as result "metadata have been generated!"
pwd 

// create topography
qui do "${topo_pro}/WID_topo/codes/gen_topography"
qui di as result "topography have been generated!"
qui di as result "topography have saved in final table/WID_topo_warehouse.dta!"
pwd 





