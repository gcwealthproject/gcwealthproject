
// Master LWS file 
//import LWS aggregates 
//to update the underlying dataset, ///
//send 'data_download/XX_steal_lws_aggregates.do' to the lissy interface ///
//then copy-paste the part of the output between the csv banners into a ///
// .txt or .csv file 
 


local source LWS_topo
run "code/mainstream/auxiliar/all_paths.do"

qui do "${topo_pro}/LWS_topo/codes/gen_mapped_grid"
qui di as result "grid has been generated!"
pwd

qui do "${topo_pro}/LWS_topo/codes/create_grid_stock"
qui di as result "empty grid has been generated!"
pwd

// translate raw data and populate grid
qui do "${topo_pro}/LWS_topo/codes/translate"
qui di as result "raw data have been translated and the grid has been populated!"
pwd

// create metadata
qui do "${topo_pro}/LWS_topo/codes/gen_metadata"
di as result "metadata have been generated!"
pwd 

// create topography
qui do "${topo_pro}/LWS_topo/codes/gen_topography"
qui di as result "topography have been generated!"
qui di as result "topography have saved in final table/LWS_topo_warehouse.dta!"
pwd 





