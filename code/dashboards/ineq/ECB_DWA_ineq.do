clear all


*global path 	"`:env USERPROFILE'/Dropbox/gcwealth"
*cd "$path"

local source ECB_DWA_ineq
run "code/mainstream/auxiliar/all_paths.do"
run $memorize_labels

//define internal paths 
local sourcef "${ineq_dir_raw}/`source'"
local rawdata "`sourcef'/raw data/data.csv"
local results "`sourcef'/final_table/`source'"

import delimited "`rawdata'" , clear

drop 	ref_sector key valuation trans ///
		obs_status conf_status title_compl data_comp compiling_org ///
		pre_break_value comment_obs freq time_per_collect diss_org time_for comment_ts

order ref_area time_period dwa_grp unit_measure obs_value unit_* decimals
			

********************************************************************************	
// Prepare
********************************************************************************
	
	// Help
	split title , p(" - ")
	
	// Area
	rename ref_area area
	
	// Year + isolate q4
	gen year=substr(time_period,1,4)	
		gen trim=substr(time_period,7,8)
		destring year trim, replace
		keep if trim==4
		drop trim
		tostring year, replace
		replace time_period=year
		drop year
		rename time_period year
		destring year, replace
	
	
	// value
	gen value=.
	
	
	// Percentiles
	gen percentile=""
	
	replace percentile="p0p50" 		if dwa_grp=="B50"
	replace percentile="p90p100" 	if dwa_grp=="D10"
	replace percentile="p50p60" 	if dwa_grp=="D6"
	replace percentile="p60p70" 	if dwa_grp=="D7"
	replace percentile="p70p80" 	if dwa_grp=="D8"
	replace percentile="p80p90" 	if dwa_grp=="D9"
	
	// Varcode
	gen varcode_1=""	
	gen varcode_2=""
	gen varcode=""
	
	
	// source
	gen source="`source'"
	
	
	// Drop Useless groups
		foreach grp in  HSO HST WSE WSR WSS WSU WSX  {
		drop if dwa_grp=="`grp'"
	}
	
	
	********************************************************************************
	// Gini
	********************************************************************************
	preserve
		keep if unit_measure=="GI"
		
		replace value=obs_value
		replace varcode="t-hs-gin-netwea-ho"	// HHs
		replace percentile="p0p100"
		
		
		keep area year value percentile varcode source
		
		
		tempfile gini
		save `gini', replace
	restore	

	
	
	
	****************************************************************************************
	// Average Wealth Overall
	****************************************************************************************
	preserve 
		*keep if unit_me=="EUR_MN"  & title=="Mean net wealth of households"
		keep if dwa_grp=="_Z"  & (title=="Adjusted wealth (net) of households, per household" | ///
								 title=="Adjusted wealth (net) of households, per capita")
		
		replace value=obs_value*10^unit_mult 
		
		replace percentile="p0p100" 		
		
		replace varcode_1="t-hs-avg-netwea-"
		replace varcode_2="ho"	if unit_measure=="EUR" | unit_measure=="EUR_R_NH"
		replace varcode_2="ia"	if unit_measure=="EUR_R_POP"			
		replace varcode=varcode_1+varcode_2	
		
		keep area year value percentile varcode source
		
		tempfile overall_averages
		save `overall_averages', replace
	restore
	

	****************************************************************************************
	// Average Net Wealth By Percentiles
	****************************************************************************************
	preserve
		keep if title1=="Adjusted wealth (net) of households" ///
				& (unit_measure=="EUR_R_NH" |  unit_measure=="EUR_R_POP")
	
		replace value=obs_value*10^unit_mult
		
		
		replace varcode_1="t-hs-avg-netwea-"
		replace varcode_2="ho" 	if (unit_measure=="EUR_R_NH")
		replace varcode_2="ia" 	if (unit_measure=="EUR_R_POP")
		replace varcode=varcode_1+varcode_2	
	
		// Check
		levelsof dwa_grp
		
		keep area year value percentile varcode source
		
		tempfile decile_averages
		save `decile_averages', replace
	restore
	


	********************************************************************************
	//  Wealth Shares: directly availalbe: Bottom 50% , Top 10% and Top 5%
	********************************************************************************
	preserve
		keep if unit_measure=="PT" &  ///
				(dwa_grp=="B50" |  dwa_grp=="T10" | dwa_grp=="T5")
			// Directly availalbe: Bottom 50% , Top 10% and Top 5%
			
			replace value=obs_value*10^unit_mult
			
			replace percentile="p90p100" 	if dwa_grp=="T10"
			replace percentile="p95p100" 	if dwa_grp=="T5"	
			replace percentile="p0p50" 		if dwa_grp=="B50"
			
			replace varcode_1="t-hs-dsh-netwea-"
			replace varcode_2="ho" 	
			replace varcode=varcode_1+varcode_2	
			
			// Check
			levelsof title
			
			keep area year value percentile varcode source
			
			tempfile wealth_shares
			save `wealth_shares', replace
	restore

	
	
*******************************************************************************
clear 
append using `gini'
append using `overall_averages'
append using `decile_averages'
append using `wealth_shares'	

sort area year varcode percentile
	
	
	
*save "C:/Users/mtarga/Desktop/DWA/data.dta", replace

*use "C:/Users/mtarga/Desktop/DWA/data.dta" , replace
bys varcode: tab percentile

	
	// Quick Check
	***************************************************************************
		preserve 
		
			// Calculate NW Total
			keep if (varcode=="t-hs-avg-netwea-ho" | varcode=="t-hs-dsh-netwea-ho") & percentile!="p0p100"
			
			gen help=value if varcode!="t-hs-dsh-netwea-ho"
			replace help=help*5 if percentile=="p0p50" & varcode!="t-hs-dsh-netwea-ho"
			
			sort area year varcode percentile
			list in 1/10
			
			bys area year varcode: egen Wbar_tot=total(help) if varcode=="t-hs-avg-netwea-ho"
		


			// Check W Shares
			gen htop10=(help/Wbar_tot)*100 if percentile=="p90p100"
			gen hbot50=(help/Wbar_tot)*100 if percentile=="p0p50"
			
			bys area year percentile : egen bot50=max(hbot50) 
			bys area year percentile : egen top10=max(htop10) 
			
			
			list area year value percentile bot50 top10 in 1/100 ///
						if (percentile=="p90p100" | percentile=="p0p50") ///
						& varcode=="t-hs-dsh-netwea-ho"
		
			// Correct!
			
		restore
		
		
		
********************************************************************************
// Extensions
	/*
		Average NW	: Bottom 60, btoom 70, bottom 80, mid 40, top 20
		Wealth Share: Bottom 60, btoom 70, bottom 80, mid 40, top 20
					  ** t-hs-dsh-netwea-ia is fully missing!
	*/
********************************************************************************

		
		// Account for Percentiles
		gen help=value
		replace help=help*5 if percentile=="p0p50"
		replace help=. 		if percentile=="p0p100"
		replace help=. 		if varcode=="t-hs-dsh-netwea-ho"
	
		bys area year varcode: egen Wbar_tot=total(help) 	
		replace Wbar_tot=. if varcode=="t-hs-dsh-netwea-ho"
		replace Wbar_tot=. if varcode=="t-hs-gin-netwea-ho"
		replace Wbar_tot=. if varcode=="t-hs-dsh-netwea-ia"
		replace Wbar_tot=. if varcode=="t-hs-gin-netwea-ia"
		
		
		
		// Av. Wealth
		************************************************************************
			// Bottom 90
			gen hmu_bottom_90=1	if 	(percentile=="p0p50" ///
								|	percentile=="p50p60" ///
								|	percentile=="p60p70" ///
								|	percentile=="p70p80" ///
								|	percentile=="p80p90") 
			bys area year varcode: egen mu_bottom_90=mean(help) if hmu_bottom_90==1	
			
			
			// Mid 40%
			gen hmu_mid_40=1	if 	(percentile=="p50p60" ///
								|	percentile=="p60p70" ///
								|	percentile=="p70p80" ///
								|	percentile=="p80p90")
			bys area year varcode: egen mu_mid_40=mean(help) if hmu_mid_40==1	
			
			// Top 20
			gen hmu_top_20=1	if 	(percentile=="p90p100" ///
								|	percentile=="p80p90") 
			bys area year varcode: egen mu_top_20=mean(help) if hmu_top_20==1
			
			
			// Top 10
			gen hmu_top_10=1	if 	percentile=="p90p100" 
			bys area year varcode: egen mu_top_10=mean(help) if hmu_top_10==1
				
			
		drop hmu*
		list
		
		// Sotre new estimates to append
		preserve 
			foreach var in mu_bottom_90 mu_top_10 mu_top_20 mu_mid_40 {
				bys area year varcode: egen hvalue_`var'=max(`var') 
				drop if hvalue_`var'==.
			}
			bys area year varcode: gen N=_n
			keep if N==1
			drop N
			keep area year varcode hvalue* source
			list
				expand 4 
				list
				bys area year varcode: gen N=_n
				gen value=.
				gen percentile=""
				
				bys area year varcode:replace value=hvalue_mu_bottom_90 	if _n==1
				bys area year varcode:replace percentile="p0p90"			if _n==1
				bys area year varcode:replace value=hvalue_mu_top_10 		if _n==2
				bys area year varcode:replace percentile="p90p100"			if _n==2
				bys area year varcode:replace value=hvalue_mu_top_20 		if _n==3
				bys area year varcode:replace percentile="p80p100"			if _n==3
				bys area year varcode:replace value=hvalue_mu_mid_40 		if _n==4
				bys area year varcode:replace percentile="p50p90"			if _n==4
				drop hvalue* N
			list
			
			tempfile extra_averages
			save `extra_averages' , replace
		restore
		
		
		
		
		// Wealth Shares
		************************************************************************
			// Bottom 60
			gen hmu_bottom_60=1	if 	(percentile=="p0p50" ///
								|	percentile=="p50p60") 
			bys area year varcode: egen s_bottom_60=total(help) if hmu_bottom_60==1	
			replace s_bottom_60=s_bottom_60/Wbar_tot
			
			
			// Bottom 70
			gen hmu_bottom_70=1	if 	(percentile=="p0p50" ///
								|	percentile=="p50p60" ///
								|	percentile=="p60p70") 
			bys area year varcode: egen s_bottom_70=total(help) if hmu_bottom_70==1	
			replace s_bottom_70=s_bottom_70/Wbar_tot
			
			
			// Bottom 80
			gen hmu_bottom_80=1	if 	(percentile=="p0p50" ///
								|	percentile=="p50p60" ///
								|	percentile=="p60p70" ///
								|	percentile=="p70p80") 
			bys area year varcode: egen s_bottom_80=total(help) if hmu_bottom_80==1	
			replace s_bottom_80=s_bottom_80/Wbar_tot
			
			
			// Bottom 90
			gen hmu_bottom_90=1	if 	(percentile=="p0p50" ///
								|	percentile=="p50p60" ///
								|	percentile=="p60p70" ///
								|	percentile=="p70p80" ///
								|	percentile=="p80p90") 
			bys area year varcode: egen s_bottom_90=total(help) if hmu_bottom_90==1	
			replace s_bottom_90=s_bottom_90/Wbar_tot
			
			
			// Mid 40
			gen hmu_mid_40=1	if 	 ///
									(percentile=="p50p60" ///
								|	percentile=="p60p70" ///
								|	percentile=="p70p80" ///
								|	percentile=="p80p90") 
			bys area year varcode: egen s_mid_40=total(help) if hmu_mid_40==1	
			replace s_mid_40=s_mid_40/Wbar_tot
			
			
			// Top 20
			gen hmu_top_20=1	if 	 ///
									(percentile=="p80p90" ///
								|	percentile=="p90p100") 
			bys area year varcode: egen s_top_20=total(help) if hmu_top_20==1	
			replace s_top_20=s_top_20/Wbar_tot
			
			
			
			***************************
			// Bottom 50 - if varcode=="t-hs-avg-netwea-ia"
			gen hmu_bottom_50=1	if 	 percentile=="p0p50" 
			bys area year varcode: egen s_bottom_50=total(help) if hmu_bottom_50==1	
			replace s_bottom_50=s_bottom_50/Wbar_tot
			
			
			// Top 10 - if varcode=="t-hs-avg-netwea-ia"
			gen hmu_top_10=1	if 	 percentile=="p90p100" 
			bys area year varcode: egen s_top_10=total(help) if hmu_top_10==1	
			replace s_top_10=s_top_10/Wbar_tot
			***************************
			
			drop hmu*
				
			
		// Sotre new estimates to append
		preserve 
			foreach var in s_bottom_50 s_bottom_60 s_bottom_70 s_bottom_80 s_bottom_90 s_mid_40 s_top_20 s_top_10 {
				bys area year varcode: egen hvalue_`var'=max(`var') 
				drop if hvalue_`var'==.
			}
			bys area year varcode: gen N=_n
			keep if N==1
			drop N
			keep area year varcode hvalue* source
			
				expand 8
				list
				bys area year varcode: gen N=_n
				gen value=.
				gen percentile=""
				
				replace varcode="t-hs-dsh-netwea-ho" if varcode=="t-hs-avg-netwea-ho"
				replace varcode="t-hs-dsh-netwea-ia" if varcode=="t-hs-avg-netwea-ia"
				
				bys area year varcode:replace value=hvalue_s_bottom_60 	if _n==1
				bys area year varcode:replace percentile="p0p60"		if _n==1
				bys area year varcode:replace value=hvalue_s_bottom_70 	if _n==2
				bys area year varcode:replace percentile="p0p70"		if _n==2
				bys area year varcode:replace value=hvalue_s_bottom_80 	if _n==3
				bys area year varcode:replace percentile="p0p80"		if _n==3
				bys area year varcode:replace value=hvalue_s_bottom_90 	if _n==4
				bys area year varcode:replace percentile="p0p90"		if _n==4
				bys area year varcode:replace value=hvalue_s_mid_40 	if _n==5
				bys area year varcode:replace percentile="p50p90"		if _n==5
				bys area year varcode:replace value=hvalue_s_top_20 	if _n==6
				bys area year varcode:replace percentile="p80p100"		if _n==6
				
				bys area year varcode:replace value=hvalue_s_top_10 	if _n==7
				bys area year varcode:replace percentile="p90p100"		if _n==7
				bys area year varcode:replace value=hvalue_s_bottom_50 	if _n==8
				bys area year varcode:replace percentile="p0p50"		if _n==8
				
				drop hvalue* N				
				
				// 0-100 scale
				replace value=value*100 if varcode=="t-hs-dsh-netwea-ia" & value<1
				replace value=value*100 if varcode=="t-hs-dsh-netwea-ho" & value<1
			
			tempfile extra_shares
			save `extra_shares' , replace
		restore	
		
	keep area year value percentile varcode source
	bys varcode: tab percentile
	
	// Append Extra Shares and Averages
	append using  `extra_shares'
	append using  `extra_averages'
	
	
	sort area year varcode percentile
	bys area year varcode percentile: gen N=_n
	tab N

	drop if N==2
	drop N
			
	
	// Drop useless quantites
	*drop if varcode =="t-hs-avg-netwea-ho" & percentile=="p50p60"
	*drop if varcode =="t-hs-avg-netwea-ho" & percentile=="p60p70"
	*drop if varcode =="t-hs-avg-netwea-ho" & percentile=="p70p80"
	*drop if varcode =="t-hs-avg-netwea-ho" & percentile=="p80p90"
	
	*drop if varcode =="t-hs-avg-netwea-ia" & percentile=="p50p60"
	*drop if varcode =="t-hs-avg-netwea-ia" & percentile=="p60p70"
	*drop if varcode =="t-hs-avg-netwea-ia" & percentile=="p70p80"
	*drop if varcode =="t-hs-avg-netwea-ia" & percentile=="p80p90"
	
	
	// Keep only HO
	tab varcode
	drop if varcode=="t-hs-avg-netwea-ia"
	drop if varcode=="t-hs-dsh-netwea-ia"
	
	drop if area=="I9"
			
*save "`results'", replace
qui export delimited "`results'", replace 

bys varcode: tab percentile
