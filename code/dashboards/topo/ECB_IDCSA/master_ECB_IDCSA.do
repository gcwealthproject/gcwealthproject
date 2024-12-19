
//runs all do-files to build ECB data 
run "code/mainstream/auxiliar/all_paths.do"

*global user "/Users/giacomorella/Dropbox"


//geb grid_grid_stock
//When updating data, input to create_grid_stock.do needs to be updated to
qui do "${topo_pro}/ECB_IDCSA/codes/create_grid_stock.do"

// translate and populate grid 
do "${topo_pro}/ECB_IDCSA/codes/translate.do"
qui di as result "raw data have been translated!"
pwd

// generate grid for names and codes
// generate grid for hn (joint households and NPISH) sector
do "${topo_pro}/ECB_IDCSA/codes/gen_mapped_grid_hn.do"
// generate grid for hs (households) and np (NPISH) sectors
do "${topo_pro}/ECB_IDCSA/codes/gen_mapped_grid_hs_np.do"
qui di as result "populated grid has been generated!"
pwd


// gen metadata
// gen metadata for hn (joint households and NPISH) sector
do "${topo_pro}/ECB_IDCSA/codes/gen_metadata_hn.do"
// gen metadata for hs (households) and np (NPISH) sectors
do "${topo_pro}/ECB_IDCSA/codes/gen_metadata_hs_np.do"
qui di as result "metadata have been generated!"
pwd 

// gen topography
// gen topography for hn (joint households and NPISH) sector
do "${topo_pro}/ECB_IDCSA/codes/gen_topography_hn.do"
// gen topography for hs (households) and np (NPISH) sectors
do "${topo_pro}/ECB_IDCSA/codes/gen_topography_hs_np.do"
qui di as result "topography have been generated!"
qui di as result "topography have saved in final table/ECB_IDCSA_warehouse.csv!"
pwd 

