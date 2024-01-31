
********************************************************************************************************
*Findings HHs who are in 2019 and tracing back so that each "HHID" (including split) is in all 4 waves
********************************************************************************************************

use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\MWI_2010-2019_IHPS_v06_M_Stata (1)/hh_mod_a_filt_19.dta", clear
keep y4_hhid y3_hhid 
tempfile mergemaster19
save `mergemaster19'

*distinct y4_hhid y3_hhid

use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\MWI_2010-2019_IHPS_v06_M_Stata (1)/hh_mod_a_filt_16.dta", clear
keep y3_hhid y2_hhid 
merge 1:m y3_hhid using `mergemaster19' 
drop if _merge!=3
drop _merge
tempfile mergemaster1916
save `mergemaster1916'


use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\MWI_2010-2019_IHPS_v06_M_Stata (1)/hh_mod_a_filt_13.dta", clear
keep y2_hhid HHID 
merge 1:m y2_hhid using `mergemaster1916'
drop if _merge!=3
drop _merge
tempfile mergemaster191613
save `mergemaster191613'


use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\MWI_2010-2019_IHPS_v06_M_Stata (1)/hh_mod_a_filt_10.dta", clear
keep HHID case_id ea_id
merge 1:m HHID using `mergemaster191613'
drop if _merge!=3
drop _merge
order HHID y2_hhid y3_hhid y4_hhid
sort HHID y2_hhid y3_hhid y4_hhid
tempfile mergemaster19161310
save `mergemaster19161310'

*distinct y4_hhid y3_hhid y2_hhid HHID


************************************************************
*Finding only parents
************************************************************

split y2_hhid, parse(-)
*drop y2_hhid

split y3_hhid, parse(-)
*drop y3_hhid

split y4_hhid, parse(-)
*drop y4_hhid

rename (y4_hhid1 y3_hhid1 y2_hhid1) (y4_hhid_og y3_hhid_og y2_hhid_og)

rename (y4_hhid2 y3_hhid2 y2_hhid2) (y4_hhid_level y3_hhid_level y2_hhid_level)

destring (y4_hhid_og y3_hhid_og y2_hhid_og y4_hhid_level y3_hhid_level y2_hhid_level), replace

keep if y4_hhid_level==1 & y3_hhid_level==1 & y2_hhid_level==1 //keep only parents**

*distinct y4_hhid y3_hhid y2_hhid HHID



save "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\complete_files", replace
