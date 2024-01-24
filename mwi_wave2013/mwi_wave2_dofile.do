










clear



global mwi_GHS_W2_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\MWI_2010-2019_IHPS_v06_M_Stata (1)"
global mwi_GHS_W2_created_data  "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\mwi_wave2013"









************************
*Geodata Variables
************************

use "${mwi_GHS_W2_raw_data}\PlotGeovariables_IHPS_13.dta", clear
*merge 1:m case_id using  "${mwi_GHS_W1_created_data}\hhids.dta"
ren y2_hhid HHID

ren slope  plot_slope
ren elevation  plot_elevation
ren twi   plot_wetness

tab1 plot_slope plot_elevation plot_wetness, missing

egen med_slope_HHID = median( plot_slope), by (HHID)
egen med_elevation_HHID = median( plot_elevation), by (HHID)
egen med_wetness_HHID = median( plot_wetness), by (HHID)

egen med_slope = median( plot_slope)
egen med_elevation = median( plot_elevation)
egen med_wetness = median( plot_wetness)

replace plot_slope= med_slope_HHID if plot_slope==.
replace plot_elevation= med_elevation_HHID if plot_elevation==.
replace plot_wetness= med_wetness_HHID if plot_wetness==.

replace plot_slope= med_slope if plot_slope==.
replace plot_elevation= med_elevation if plot_elevation==.
replace plot_wetness= med_wetness if plot_wetness==.


collapse (sum) plot_slope plot_elevation plot_wetness, by (HHID)
sort HHID
la var plot_slope "slope of plot"
la var plot_elevation "Elevation of plot"
la var plot_wetness "Potential wetness index of plot"
save "${mwi_GHS_W2_created_data}\geodata_2013.dta", replace




***************modifying conversion file

use "C:\Users\obine\Downloads\ihs_seasonalcropconversion_factor_2020.dta", clear
keep if crop_code==1 & condition==1
destring unit_code, replace
sort region crop_code unit_code
save "${mwi_GHS_W2_created_data}\coversionfactor_for_maize_consumption.dta", replace




**********************
*HH_id
**********************

//dropped duplicate observation....................

use "${mwi_GHS_W2_raw_data}\hh_mod_a_filt_13.dta",clear 
rename hh_a10a ta
rename hh_wgt weight
rename region region
lab var region "1=North, 2=Central, 3=South"
gen rural = (reside==2)
lab var rural "1=Household lives in a rural area"
collapse (max) hh_a40c, by ( region district ea_id ) 
sort ea_id 
duplicates report ea_id
duplicates drop ea_id, force
save "${mwi_GHS_W2_created_data}\hhid.dta", replace



**************
*food prices
**************


use "${mwi_GHS_W2_raw_data}\com_ck_10.dta" , clear

*encode com_ck00b, gen (item_code)
*label list item_code
*br if item_code==20


merge m:1 ea_id using  "${mwi_GHS_W2_created_data}\hhid.dta", keepusing(region district ea_id)

ren com_ck00a crop_code
ren com_ck00b3 unit_code

sort region crop_code unit_code
drop _merge
merge m:1 region crop_code unit_code using "${mwi_GHS_W2_created_data}\coversionfactor_for_maize_consumption.dta", keepusing(conversion)

******************
*Maize
******************
replace conversion = 1 if unit_code==1 & crop_code==1

gen maize_unit = com_ck00b2*conversion if crop_code==1
gen maize_pr = com_ck00b1 if crop_code==1

gen maize_price= maize_pr/maize_unit
tab maize_price
sum maize_price, detail
*br conversion maize_unit  maize_pr maize_price crop_code if crop_code==1
tab maize_price, missing

egen median_pr_ea_id = median(maize_price), by (ea_id)
egen median_pr_district  = median(maize_price), by (district )
egen median_pr_region  = median(maize_price), by (region )


egen num_pr_ea_id = count(maize_price), by (ea_id)
egen num_pr_district  = count(maize_price), by (district )
egen num_pr_region = count(maize_price), by (region )





tab num_pr_ea_id
tab num_pr_district
tab num_pr_region


gen maize_price_mr  = maize_price

replace maize_price_mr = median_pr_ea_id if maize_price_mr==. 
tab maize_price_mr,missing

replace maize_price_mr = median_pr_district if maize_price_mr==. 
tab maize_price_mr,missing


replace maize_price_mr = median_pr_region if maize_price_mr==.
tab maize_price_mr,missing

collapse (max) maize_price_mr, by (region district ea_id)

label var maize_price_mr  "commercial price of maize in naira"
//dropped districts missing (3) observation....................

drop if district==.
sort region district ea_id

save "${mwi_GHS_W2_created_data}\maize_pr.dta", replace



**********************
*HH
**********************
use "${mwi_GHS_W2_raw_data}\hh_mod_a_filt_13.dta",clear 

rename hh_a10a ta
rename hh_wgt weight
rename region region
lab var region "1=North, 2=Central, 3=South"
gen rural = (reside==2)
lab var rural "1=Household lives in a rural area"
drop HHID
ren y2_hhid HHID
keep HHID case_id ea_id district region
sort region district ea_id
merge m:1 ea_id using "${mwi_GHS_W2_created_data}\maize_pr.dta"
collapse (max) maize_price_mr, by (HHID)

label var maize_price_mr  "commercial price of maize in naira"
save "${mwi_GHS_W2_created_data}\food_prices_2013.dta", replace
















********************************
*Subsidized Fertilizer (Coupon)
********************************
use "${mwi_GHS_W2_raw_data}\ag_mod_e2_13.dta",clear 
ren y2_hhid HHID
*ag_e02 institution where they bought coupon
*ag_e08a quantity of subsidized fertilizer
*ag_e08b qty units (kg,g,50kg etc)
*ag_e15 cost of coupon used 
*ag_e16a ag_e16b institution where they bought coupon
*ag_e07 (input codes ) 1-11 is for fertilizer



*various types of input (inorganic fert, other chemicals)

*************Getting Subsidized quantity*******************
ren ag_e07 input_type  
tab input_type
gen subsidy_qty_2013 = ag_e08a if  input_type<=11
tab subsidy_qty_2013,missing

*conversion  to kg

tab ag_e08b
tab ag_e08b,nolabel
replace subsidy_qty= 0.001*subsidy_qty if ag_e08b==1
tab subsidy_qty,missing
replace subsidy_qty = 2*subsidy_qty if ag_e08b==3
tab subsidy_qty,missing
replace subsidy_qty = 3*subsidy_qty if ag_e08b==4
tab subsidy_qty,missing
replace subsidy_qty = 5*subsidy_qty if ag_e08b==5
tab subsidy_qty,missing
replace subsidy_qty = 10*subsidy_qty if ag_e08b==6
tab subsidy_qty,missing
replace subsidy_qty = 50*subsidy_qty if ag_e08b==7
tab subsidy_qty,missing
replace subsidy_qty = 0 if subsidy_qty==.

*checcking that the conversion is correct
*br ag_e08a ag_e08b subsidy_qty ag_e15 if  input_type<=11


*************Getting Subsidized Dummy Variable *******************

gen subsidy_dummy =1 if ag_e08a!=. & input_type<=11
tab subsidy_dummy,missing
replace subsidy_dummy=0 if subsidy_dummy==.
tab subsidy_dummy,missing



collapse (sum)subsidy_qty (max) subsidy_dummy, by (HHID)
label var subsidy_qty  "Quantity of Fertilizer Purchased with coupon in kg"
label var subsidy_dummy "=1 if acquired any fertilizer using coupon"
save "${mwi_GHS_W2_created_data}\subsidized_fert_2013.dta", replace


*****************************************************
*Dummy Variables for Fertilizer coupon by years
*****************************************************
use "${mwi_GHS_W2_raw_data}\ag_mod_e3_13.dta",clear 
ren y2_hhid HHID
*ag_e27a subsidy in 2009
*ag_e27b subsidy in 2010
*ag_e27c subsidy in 2011
*ag_e27d subsidy in 2012

gen subsidy_dummy_09 =1 if ag_e27a==1
replace subsidy_dummy_09 =0 if subsidy_dummy_09==.

gen subsidy_dummy_10 =1 if ag_e27b==1
replace subsidy_dummy_10 =0 if subsidy_dummy_10==.

gen subsidy_dummy_11 =1 if ag_e27c==1
replace subsidy_dummy_11 =0 if subsidy_dummy_11==.

gen subsidy_dummy_12 =1 if ag_e27d==1
replace subsidy_dummy_12 =0 if subsidy_dummy_12==.

tab subsidy_dummy_09,missing
tab subsidy_dummy_10,missing
tab subsidy_dummy_11,missing
tab subsidy_dummy_12,missing


collapse (max) subsidy_dummy_09 subsidy_dummy_10 subsidy_dummy_11 subsidy_dummy_12, by (HHID)
la var subsidy_dummy_09 "=1 if received subsidy from fertilizer in 2009"
la var subsidy_dummy_10 "=1 if received subsidy from fertilizer in 2010"
la var subsidy_dummy_11 "=1 if received subsidy from fertilizer in 2011"
la var subsidy_dummy_12 "=1 if received subsidy from fertilizer in 2012"
save "${mwi_GHS_W2_created_data}\subsidized_by_years.dta", replace


**********************
*HH_ids
**********************



use "${mwi_GHS_W2_raw_data}\hh_mod_a_filt_13.dta",clear 
rename hh_a10a ta
rename hh_wgt weight
rename region region
lab var region "1=North, 2=Central, 3=South"
gen rural = (reside==2)
lab var rural "1=Household lives in a rural area"
keep occ y2_hhid region stratum district ta ea_id rural weight  
save "${mwi_GHS_W2_created_data}\hhids.dta", replace


********************
*Community Data
********************
use "${mwi_GHS_W2_raw_data}\com_mod_d_13.dta",clear 

merge 1:m ea_id using  "${mwi_GHS_W2_created_data}\hhids.dta"


*com_cd16a  distance to daily market   com_cd15 (1= market in commumity)
*com_cd16b  units of distance to daily market
*com_cd18a  distance to large weekly market  com_cd17 (1= market in commumity)
*com_cd18b  units of distance to weekly market


***daily market***
gen mrk_dist = com_cd16a 
tab mrk_dist,missing

replace mrk_dist = 0.001*mrk_dist if com_cd16b==1
*br com_cd16a com_cd16b mrk_dist
egen median_case = median(mrk_dist), by (region district stratum  ea_id)
egen median_district = median(mrk_dist), by (region district stratum )
egen median_stratum = median(mrk_dist), by (region district)
egen median_region = median(mrk_dist), by (region)


replace mrk_dist =0 if mrk_dist==. & com_cd15==1
tab mrk_dist, missing

replace mrk_dist = median_case if mrk_dist==. 
replace mrk_dist = median_district if mrk_dist==. 
replace mrk_dist = median_stratum if mrk_dist==. 
replace mrk_dist = median_region if mrk_dist==. 
tab mrk_dist, missing

replace mrk_dist= 48 if mrk_dist>=48 & mrk_dist<. 
tab mrk_dist, missing

***weekly market***
gen mrk2_dist = com_cd18a 
tab mrk2_dist,missing
replace mrk2_dist = 0.001*mrk2_dist if com_cd18b==1 | com_cd18b==3
*br com_cd16a com_cd16b mrk_dist

egen median2_case = median(mrk2_dist), by (region district stratum  ea_id)
egen median2_district = median(mrk2_dist), by (region district stratum)
egen median2_stratum = median(mrk2_dist), by (region district)
egen median2_region = median(mrk2_dist), by (region)


replace mrk2_dist =0 if mrk2_dist==. & com_cd17==1
tab mrk2_dist, missing

replace mrk2_dist = median_case if mrk2_dist==. 
replace mrk2_dist = median_district if mrk2_dist==. 
replace mrk2_dist = median_stratum if mrk2_dist==. 
replace mrk2_dist = median_region if mrk2_dist==. 
tab mrk2_dist, missing


sort region district stratum  ea_id
collapse (max) mrk_dist mrk2_dist, by (y2_hhid region district stratum  ea_id)
tab mrk_dist, missing
tab mrk2_dist, missing
la var mrk_dist "=distance to the daily market"
la var mrk2_dist "=distance to the weekly market"


save "${mwi_GHS_W2_created_data}\community", replace





*********************************************** 
*Purchased Fertilizer
***********************************************

use "${mwi_GHS_W2_raw_data}\ag_mod_f_13.dta",clear 
merge m:1 y2_hhid using  "${mwi_GHS_W2_created_data}\hhids.dta", gen (household)
merge m:1 y2_hhid using  "${mwi_GHS_W2_created_data}\community", keepusing (mrk_dist mrk2_dist)

ren y2_hhid HHID
*ag_f15 source of comercial fertilzer purchase1
*ag_f25 source of comercial fertilzer purchase2
*ag_f35 source of comercial fertilzer purchase3

*ag_f16a qty purchased1
*ag_f26a qty purchased2
*ag_f36a qty purchased3
*ag_f44a qty organic fertilizer


*ag_f16b qty units1
*ag_f26b qty units2
*ag_f36b qty units3

*ag_f19 value of fert1
*ag_f29 value of fert2

*ag_f0d input type codes for commercial (<=5 for fertilizer)



*****Coversion of fertilizer's to kilogram using 
tab ag_f16b
tab ag_f16b,nolabel
tab ag_f26b
tab ag_f26b,nolabel


replace ag_f16a = 0.001*ag_f16a if ag_f16b==1 
replace ag_f16a = 2*ag_f16a if ag_f16b==3 
replace ag_f16a = 3*ag_f16a if ag_f16b==4
replace ag_f16a = 5*ag_f16a if ag_f16b==5
replace ag_f16a = 10*ag_f16a if ag_f16b==6
replace ag_f16a = 50*ag_f16a if ag_f16b==7
replace ag_f16a = 0.001*ag_f16a if ag_f16b==9
tab ag_f16a,missing

replace ag_f26a = 0.001*ag_f26a if ag_f26b==1 
replace ag_f26a = 2*ag_f26a if ag_f26b==3 
replace ag_f26a = 3*ag_f26a if ag_f26b==4
replace ag_f26a = 5*ag_f26a if ag_f26b==5
replace ag_f26a = 10*ag_f26a if ag_f26b==6
replace ag_f26a = 50*ag_f26a if ag_f26b==7
tab ag_f26a,missing



***fertilzer total quantity, total value & total price****

gen com_fert1_qty=  ag_f16a if ag_f0d<=6
gen com_fert2_qty= ag_f26a if ag_f0d<=6

gen com_fert1_val= ag_f19 if ag_f0d<=6
gen com_fert2_val= ag_f29  if ag_f0d<=6
tab com_fert1_qty

*br ag_f16a ag_f19 ag_f0d com_fert1_qty com_fert1_val if ag_f0d>6

egen total_qty = rowtotal(com_fert1_qty com_fert2_qty)
tab  total_qty , missing

egen total_valuefert  = rowtotal(com_fert1_val com_fert2_val)
tab total_valuefert ,missing

gen tpricefert = total_valuefert /total_qty
tab tpricefert 

gen tpricefert_cens = tpricefert 
replace tpricefert_cens = 500 if tpricefert_cens > 500 & tpricefert_cens < .
replace tpricefert_cens = 5 if tpricefert_cens < 5
tab tpricefert_cens, missing






egen medianfert_pr_ea_id = median(tpricefert_cens), by (ea_id)
egen medianfert_pr_district  = median(tpricefert_cens), by (district )
egen medianfert_pr_stratum = median(tpricefert_cens), by (stratum)
egen medianfert_pr_region  = median(tpricefert_cens), by (region )



egen num_fert_pr_ea_id = count(tpricefert_cens), by (ea_id)
egen num_fert_pr_district  = count(tpricefert_cens), by (district )
egen num_fert_pr_stratum = count(tpricefert_cens), by (stratum)
egen num_fert_pr_region  = count(tpricefert_cens), by (region )




tab num_fert_pr_ea_id
tab num_fert_pr_district
tab num_fert_pr_stratum
tab num_fert_pr_region



gen tpricefert_cens_mrk = tpricefert_cens

replace tpricefert_cens_mrk = medianfert_pr_ea_id if tpricefert_cens_mrk ==. & num_fert_pr_ea_id >= 23
tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_district if tpricefert_cens_mrk ==. & num_fert_pr_district >= 23
tab tpricefert_cens_mrk ,missing

replace tpricefert_cens_mrk = medianfert_pr_stratum if tpricefert_cens_mrk ==. & num_fert_pr_stratum >= 23
tab tpricefert_cens_mrk ,missing

replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. & num_fert_pr_region >= 23
tab tpricefert_cens_mrk,missing



***********
*organic fertilizer
***********
gen org_fert = (ag_f43==1)
tab org_fert,missing




collapse (sum) total_qty total_valuefert (max) mrk_dist mrk2_dist org_fert tpricefert_cens_mrk, by(HHID)
label var org_fert  "1= if used organic fertilizer"
la var mrk_dist "=distance to the daily market in km"
la var mrk2_dist "=distance to the weekly market in km"
label var total_qty "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk  "price of commercial fertilizer purchased in naira"
sort HHID
save "${mwi_GHS_W2_created_data}\commercial_fert_2013.dta", replace






************************************************
*Savings 
************************************************

use "${mwi_GHS_W2_raw_data}\hh_mod_t_13.dta",clear 
ren y2_hhid HHID

*hh_t08 1 &2 if you can build up savings or save a little

gen informal_save = 1 if hh_t08==1 | hh_t08==2
tab informal_save,missing
replace informal_save =0 if informal_save==.
tab informal_save,missing

collapse (max)informal_save, by (HHID)
la var informal_save "=1 if you were able to save up a little"
save "${mwi_GHS_W2_created_data}\informal_savings.dta", replace




*******************************************************
*Credit access 
*******************************************************


use "${mwi_GHS_W2_raw_data}\hh_mod_s1_13.dta",clear 
ren y2_hhid HHID
*hh_s01 borrowed on credit
*hh_s04 source of credit
tab hh_s01
label list HH_S04
 gen formal_credit  =1 if hh_s01==1 & hh_s04 ==10 | hh_s04 ==11
 tab formal_credit,missing
 replace formal_credit =0 if formal_credit ==.
 tab formal_credit,missing
 

 
 gen informal_credit  =1 if  hh_s01==1 & hh_s04 <=9 | hh_s04 ==12
 tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
 tab informal_credit,missing


 collapse (max) formal_credit informal_credit, by (HHID)
 la var formal_credit "=1 if borrowed from formal credit group"
 la var informal_credit "=1 if borrowed from informal credit group"
save "${mwi_GHS_W2_created_data}\credit_access_2013.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${mwi_GHS_W2_raw_data}\ag_mod_t1_13.dta",clear 
ren y2_hhid HHID
ren ag_t01 ext_acess

tab ext_acess, missing
tab ext_acess, nolabel

replace ext_acess = 0 if ext_acess==2 | ext_acess==.
tab ext_acess, missing
collapse (max) ext_acess, by (HHID)
la var ext_acess "=1 if received advise from extension services"
save "${mwi_GHS_W2_created_data}\Extension_access_2013.dta", replace









*********************************
*Demographics 
*********************************



use "${mwi_GHS_W2_raw_data}\hh_mod_b_13.dta",clear 


merge 1:1 y2_hhid PID using "${mwi_GHS_W2_raw_data}\hh_mod_c_13.dta", gen (household)
merge m:1 y2_hhid using  "${mwi_GHS_W2_created_data}\hhids.dta"


ren y2_hhid HHID
*hh_b03 sex 
*hh_b04 relationshiop to head
*hh_b05a age (years)
*hhsize actual hhsize

sort HHID PID 
 
*gen num_mem_2013 = 1


******** female head****

gen femhead  = 0
replace femhead = 1 if hh_b03== 2 & hh_b04==1
tab femhead,missing

********Age of HHead***********
ren hh_b05a hh_age
gen hh_headage = hh_age if hh_b04==1

tab hh_headage

replace hh_headage = 100 if hh_headage > 100 & hh_headage < .
tab hh_headage
tab hh_headage, missing


************generating the median age**************



egen median_headage_ea_id = median(hh_headage), by (ea_id)
egen median_headage_district  = median(hh_headage), by (district )
egen median_headage_stratum  = median(hh_headage), by (stratum )
egen median_headage_region  = median(hh_headage), by (region )



egen num_headage_ea_id = count(hh_headage), by (ea_id)
egen num_headage_district  = count(hh_headage), by (district )
egen num_headage_stratum = count(hh_headage), by (stratum )
egen num_headage_region  = count(hh_headage), by (region )


tab num_headage_ea_id
tab num_headage_district
tab num_headage_stratum
tab num_headage_region



gen hh_headage_mrk  = hh_headage

replace hh_headage_mrk = median_headage_ea_id if hh_headage_mrk ==. & num_headage_ea_id >= 26
tab hh_headage_mrk,missing

replace hh_headage_mrk = median_headage_district if hh_headage_mrk ==. & num_headage_district >= 26
tab hh_headage_mrk,missing

replace hh_headage_mrk = median_headage_stratum if hh_headage_mrk ==. & num_headage_stratum >= 26
tab hh_headage_mrk,missing

replace hh_headage_mrk = median_headage_region if hh_headage_mrk ==. & num_headage_region >= 26
tab hh_headage_mrk,missing





********************Education****************************************************
*hh_c06 attend_school
*hh_c09 highest_education qualification



ren  hh_c06 attend_sch 
tab attend_sch
replace attend_sch = 0 if attend_sch ==2
tab attend_sch, nolabel
*tab s1q4 if s2q7==.

replace hh_c08= 0 if attend_sch==0
tab hh_c08
tab hh_b04 if _merge==1


*label list hh_c08
tab hh_c08 if hh_b04==1
replace hh_c08 = 2 if hh_c08==. &  hh_b04==1


*** Education Dummy Variable*****
 *label list hh_c08

gen pry_edu  = 1 if hh_c08 < 8 & hh_b04==1
tab pry_edu,missing
gen finish_pry  = 1 if hh_c08 >= 8 & hh_c08 < 14 & hh_b04==1
tab finish_pry,missing
gen finish_sec = 1 if hh_c08 >= 14 & hh_b04==1
tab finish_sec,missing

replace pry_edu  =0 if pry_edu==. & hh_b04==1
replace finish_pry  =0 if finish_pry==. & hh_b04==1
replace finish_sec  =0 if finish_sec==. & hh_b04==1
tab pry_edu  if hh_b04==1 , missing
tab finish_pry if hh_b04==1 , missing 
tab finish_sec if hh_b04==1 , missing

collapse (sum) hhsize (max) hh_headage_mrk  femhead  attend_sch  pry_edu  finish_pry  finish_sec , by (HHID)
la var hhsize "household size"
la var femhead  "=1 if head is female"
la var hh_headage_mrk  "age of household head in years"
la var attend_sch  "=1 if respondent attended school"
la var pry_edu  "=1 if household head attended pry school"
la var finish_pry  "=1 if household head finished pry school"
la var finish_sec  "=1 if household head finished sec school"
save "${mwi_GHS_W2_created_data}\demographics_2013.dta", replace

********************************* 
*Labor Age 
*********************************

use "${mwi_GHS_W2_raw_data}\hh_mod_b_13.dta",clear 

ren y2_hhid HHID
ren hh_b05a hh_age

gen worker = 1
replace worker  = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort HHID
collapse (sum) worker, by (HHID)
la var worker "number of members age 15 and older and less than 65"
sort HHID

save "${mwi_GHS_W2_created_data}\labor_age_2013.dta", replace


********************************
*Safety Net
********************************

use "${mwi_GHS_W2_raw_data}\hh_mod_r_13.dta",clear 
ren y2_hhid HHID
*hh_r01 received assistance
gen safety_net=1 if hh_r01==1 
tab safety_net,missing
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (HHID)
tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${mwi_GHS_W2_created_data}\safety_net_2013.dta", replace




**************
*Net Buyers and Sellers
***************
use "${mwi_GHS_W2_raw_data}\hh_mod_g1_13.dta",clear 
merge m:1 y2_hhid using  "${mwi_GHS_W2_created_data}\hhids.dta"
ren y2_hhid HHID
*hh_g04a from purchases
*hh_g06a from own production

//They are using the same conversion
*br hh_g04a hh_g04b hh_g06a hh_g06b if (hh_g04a !=. & hh_g04a !=0) & (hh_g06a !=. & hh_g06a !=0)
tab hh_g04a
tab hh_g06a

replace hh_g04a = 0 if hh_g04a<=0 |hh_g04a==.
tab hh_g04a,missing
replace hh_g06a = 0 if hh_g06a<=0 |hh_g06a==.
tab hh_g06a,missing

gen net_seller = 1 if hh_g06a > hh_g04a
tab net_seller,missing
replace net_seller=0 if net_seller==.
tab net_seller,missing

gen net_buyer = 1 if hh_g06a < hh_g04a
tab net_buyer,missing
replace net_buyer=0 if net_buyer==.
tab net_buyer,missing



collapse  (max) net_seller  net_buyer, by(HHID)
la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"
save "${mwi_GHS_W2_created_data}\net_buyer_seller_2013.dta", replace





*****************************
*Household Assests
****************************


use "${mwi_GHS_W2_raw_data}\hh_mod_l_13.dta",clear 
merge m:1 y2_hhid using  "${mwi_GHS_W2_created_data}\hhids.dta"
ren y2_hhid HHID
*hh_l03 qty of items
*hh_l05 scrap value of items

gen hhasset_value = hh_l03*hh_l05
tab hhasset_value,missing
sum hhasset_value,detail
replace hhasset_value = 1000000 if hhasset_value > 1000000 & hhasset_value <.
replace hhasset_value = 50 if hhasset_value <50
tab hhasset_value

************generating the mean vakue**************

egen mean_val_ea_id = mean(hhasset_value), by (ea_id)
egen mean_val_district  = mean(hhasset_value), by (district )
egen mean_val_stratum  = mean(hhasset_value), by (stratum )
egen mean_val_region = mean(hhasset_value), by (region)


egen num_val_ea_id = count(hhasset_value), by (ea_id)
egen num_val_district  = count(hhasset_value), by (district )
egen num_val_stratum  = count(hhasset_value), by (stratum )
egen num_val_region = count(hhasset_value), by (region)


tab num_val_ea_id
tab num_val_district
tab num_val_stratum
tab num_val_region




replace hhasset_value = mean_val_ea_id if hhasset_value ==. & num_val_ea_id >= 205
tab hhasset_value,missing
replace hhasset_value = mean_val_district if hhasset_value ==. & num_val_district >= 205
tab hhasset_value,missing
replace hhasset_value = mean_val_stratum if hhasset_value ==. & num_val_stratum >= 205
tab hhasset_value,missing
replace hhasset_value = mean_val_region if hhasset_value ==. & num_val_region >= 205
tab hhasset_value,missing





collapse (sum) hhasset_value, by (HHID)

la var hhasset_value "total value of household asset"
save "${mwi_GHS_W2_created_data}\hhasset_value_2013.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************
clear


use "${mwi_GHS_W2_raw_data}\ag_mod_c_13.dta",clear 
merge m:1 y2_hhid using  "${mwi_GHS_W2_created_data}\hhids.dta", gen (household)
gen season=0 //rainy

ren ag_c00 plot_id
* Counting acreage
gen area_acres_est = ag_c04a if ag_c04b == 1 										//Self-report in acres - rainy season 
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==.	//Self-report in square meters

* GPS MEASURE
gen area_acres_meas = ag_c04c														//GPS measure - rainy


gen field_size= (area_acres_meas* (1/2.47105))
tab field_size, missing


egen median_ea_id = median(field_size), by (ea_id)
egen median_district  = median(field_size), by (district )
egen median_stratum = median(field_size), by (stratum)
egen median_region  = median(field_size), by (region )



egen num_ea_id = count(field_size), by (ea_id)
egen num_district  = count(field_size), by (district )
egen num_stratum = count(field_size), by (stratum)
egen num_region  = count(field_size), by (region )




tab num_ea_id
tab num_district
tab num_stratum
tab num_region



replace field_size = median_ea_id if field_size ==.
tab field_size,missing

replace field_size = median_district if field_size ==. 
tab field_size ,missing

replace field_size = median_stratum if field_size ==. 
tab field_size ,missing

replace field_size = median_region if field_size ==.
tab field_size,missing






*replace field_size = (area_acres_est* (1/2.47105))  if field_size==. & area_acres_est!=. 

ren y2_hhid HHID
collapse (sum) field_size, by (HHID)
sort HHID
ren field_size land_holding 
label var land_holding  "land holding in hectares"
save "${mwi_GHS_W2_created_data}\land_holding_2013.dta", replace
















*******************************
*Soil Quality
*******************************

use "${mwi_GHS_W2_raw_data}\ag_mod_c_13.dta",clear 
merge m:1 y2_hhid using  "${mwi_GHS_W2_created_data}\hhids.dta", gen (household)
gen season=0 //rainy

ren ag_c00 plot_id
* Counting acreage
gen area_acres_est = ag_c04a if ag_c04b == 1 										//Self-report in acres - rainy season 
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==.	//Self-report in square meters

* GPS MEASURE
gen area_acres_meas = ag_c04c														//GPS measure - rainy


gen field_size= (area_acres_meas* (1/2.47105))
tab field_size, missing


egen median_ea_id = median(field_size), by (ea_id)
egen median_district  = median(field_size), by (district )
egen median_stratum = median(field_size), by (stratum)
egen median_region  = median(field_size), by (region )



egen num_ea_id = count(field_size), by (ea_id)
egen num_district  = count(field_size), by (district )
egen num_stratum = count(field_size), by (stratum)
egen num_region  = count(field_size), by (region )




tab num_ea_id
tab num_district
tab num_stratum
tab num_region



replace field_size = median_ea_id if field_size ==.
tab field_size,missing

replace field_size = median_district if field_size ==. 
tab field_size ,missing

replace field_size = median_stratum if field_size ==. 
tab field_size ,missing

replace field_size = median_region if field_size ==.
tab field_size,missing
*ren ag_c00 plot_id

ren y2_hhid HHID
keep HHID plot_id field_size occ
*collapse (sum) field_size, by (HHID)

egen any = rowmiss(plot_id)

drop if any==1
sort HHID
save "${mwi_GHS_W2_created_data}\field_size.dta", replace





use "${mwi_GHS_W2_raw_data}\ag_mod_d_13.dta" , clear
ren ag_d00 plot_id
ren y2_hhid HHID


egen any = rowmiss(plot_id)

drop if any==1



merge m:1 HHID occ using "${mwi_GHS_W2_created_data}\field_size.dta"

ren ag_d22 soil_quality


*how to get them my max fieldsize
egen max_fieldsize = max(field_size), by (HHID)
replace max_fieldsize= . if max_fieldsize!= max_fieldsize
order field_size soil_quality HHID max_fieldsize
sort HHID
keep if field_size== max_fieldsize
sort HHID occ field_size

duplicates report HHID

duplicates tag HHID, generate(dup)
tab dup
list field_size soil_quality dup


list HHID occ  field_size soil_quality dup if dup>0

egen soil_qty_rev = min(soil_quality) 
gen soil_qty_rev2 = soil_quality

replace soil_qty_rev2 = soil_qty_rev if dup>0

list HHID occ  field_size soil_quality soil_qty_rev soil_qty_rev2 dup if dup>0


collapse (mean) soil_qty_rev2 , by (HHID)
la define soil 1 "Good" 2 "fair" 3 "poor"

la value soil soil_qty_rev2

save "${mwi_GHS_W2_created_data}\soil_quality_2013.dta", replace




























************************* Merging Agricultural Datasets ********************

use "${mwi_GHS_W2_created_data}\commercial_fert_2013.dta", replace


*******All observations Merged*****


merge 1:1 HHID using "${mwi_GHS_W2_created_data}\subsidized_fert_2013.dta", gen (subsidized)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\informal_savings.dta", gen (savings)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\credit_access_2013.dta", gen (credit)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\Extension_access_2013.dta",  gen (extension)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\demographics_2013.dta",  gen (demographics)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\labor_age_2013.dta",  gen (labor)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\safety_net_2013.dta",  gen (safety)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\food_prices_2013.dta", gen (foodprices)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\geodata_2013.dta", gen (geodata)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\net_buyer_seller_2013.dta", gen (net)
sort HHID

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\soil_quality_2013.dta", gen (soil)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\hhasset_value_2013.dta",  gen (asset)
sort HHID
merge 1:1 HHID using "${mwi_GHS_W2_created_data}\land_holding_2013.dta"

gen year= 2013
sort HHID

save "${mwi_GHS_W2_created_data}\Malawi_wave2_completedata_2013.dta", replace

