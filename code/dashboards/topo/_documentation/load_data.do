//Suggested commands to load excel and csv files


//cd "folder where data is saved"


* Wealth Topography

//Database with metadata: - Excel
import excel "topo_warehouse_meta.xlsx", sheet("Sheet1") firstrow clear

//Database with metadata: - CSV
import delimited "topo_warehouse_meta.csv",  bindquote(strict)  varnames(1) clear

//Database without metadata: - Excel
import excel "topo_warehouse.xlsx", sheet("Sheet1") firstrow clear

//Database without metadata: - CSV
import delimited "topo_warehouse.csv",  bindquote(strict)  varnames(1) clear



* Wealth Inequality Trends

//Database with metadata: - Excel
import excel "ineq_warehouse_meta.xlsx", sheet("Sheet1") firstrow clear

//Database with metadata: - CSV
import delimited "ineq_warehouse_meta.csv", bindquote(strict) varnames(1) clear

//Database without metadata: - Excel
import excel "ineq_warehouse.xlsx", sheet("Sheet1") firstrow clear

//Database without metadata: - CSV
import delimited "ineq_warehouse.csv",  bindquote(strict)  varnames(1) clear



*  Estate, Inheritance, and Gift Taxes

//Database with metadata: - Excel
import excel "eigt_warehouse_meta.xlsx", sheet("Sheet1") firstrow clear

//Database with metadata: - CSV
import delimited "eigt_warehouse_meta.csv",  bindquote(strict)  varnames(1) clear

//Database without metadata: - Excel
import excel "eigt_warehouse.xlsx", sheet("Sheet1") firstrow clear

//Database without metadata: - CSV
import delimited "eigt_warehouse.csv",  bindquote(strict)  varnames(1) clear



* Supplementary Variables


//Supplementary variables: - Excel
import excel "supplementary_var.xlsx", sheet("Sheet1") firstrow clear

//Supplementary variables: - CSV
import delimited "supplementary_var.csv",  bindquote(strict)  varnames(1) clear



* Full Data Warehouse

//Warehouse with metadata: - Excel
import excel "warehouse_meta.xlsx", sheet("Sheet1") firstrow clear

//Warehouse with metadata: - CSV
import delimited "warehouse_meta.csv",  bindquote(strict)  varnames(1) clear

// Warehouse without metadata: - Excel
import excel "warehouse.xlsx", sheet("Sheet1") firstrow clear

// Warehouse without metadata: - CSV
import delimited "warehouse_meta.csv",  bindquote(strict)  varnames(1) clear





