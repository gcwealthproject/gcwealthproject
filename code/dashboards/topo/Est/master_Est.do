
//runs all do-files to build ECB data 
run "code/mainstream/auxiliar/all_paths.do"


//create_grid_stock.do
//When updating data, input to create_grid_stock.do needs to be updated to
qui do "${topo_pro}/Est/codes/create_grid_stock.do"

//run translate and populate grid
qui do "${topo_pro}/Est/codes/translate.do"
qui di as result "raw data have been translated and the grid has been populated!"
pwd


// generate grid
do "${topo_pro}/Est/codes/gen_mapped_grid.do"
qui di as result "the grid has been generated!"
pwd

//gen metadata
do "${topo_pro}/Est/codes/gen_metadata.do"
qui di as result "metadata have been generated!"
pwd 

//gen topography
do "${topo_pro}/Est/codes/gen_topography.do"
qui di as result "topography have been generated!"
qui di as result "topography have saved in final table/Est_warehouse.dta!"
pwd 




