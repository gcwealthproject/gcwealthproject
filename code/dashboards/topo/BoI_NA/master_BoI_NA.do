cd "C:\Users\mlongmuir\Dropbox (Graduate Center)\gc_wealth_q (1)\"
run "code/mainstream/auxiliar/all_paths.do"

// gen grid_stock.dta
do "${topo_pro}/BoI_NA/codes/create_grid_stock.do"

// gen  grid
do "${topo_pro}/BoI_NA/codes/gen_mapped_grid.do"
qui di as result "grid has been generated!"
pwd

//run translate and populate grid
do "${topo_pro}/BoI_NA/codes/translate.do"
qui di as result "raw data have been translated and the grid populated!"
pwd

//gen metadata
do "${topo_pro}/BoI_NA/codes/gen_metadata.do"
di as result "metadata have been generated!"
pwd 

//gen topography
do "${topo_pro}/BoI_NA/codes/gen_topography.do"
qui di as result "topography have been generated!"
qui di as result "topography have saved in final table/BoI_NA_warehouse.dta!"
pwd 







