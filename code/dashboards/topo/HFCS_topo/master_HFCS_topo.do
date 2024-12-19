
 
cd "C:\Users\mlongmuir\Dropbox (Graduate Center)\gc_wealth_q (1)"


local source HFCS_topo


// create topography
qui do "${topo_pro}/HFCS_topo/warehouse/codes/gen_topography"
qui di as result "topography have been generated!"
qui di as result "topography have saved in final table/HFCS_topo_warehouse.dta!"
pwd 


// create metadata
qui do "${topo_pro}/HFCS_topo/warehouse/codes/gen_metadata"
di as result "metadata have been generated!"
pwd 







