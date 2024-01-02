










clear



global mwi_GHS_W2_raw_data 		"C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\MWI_2010-2019_IHPS_v06_M_Stata (1)"
global mwi_GHS_W2_created_data  "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\mwi_wave2013"


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
replace subsidy_qty_2013 = 0.001*subsidy_qty_2013 if ag_e08b==1
tab subsidy_qty_2013,missing
replace subsidy_qty_2013 = 2*subsidy_qty_2013 if ag_e08b==3
tab subsidy_qty_2013,missing
replace subsidy_qty_2013 = 3*subsidy_qty_2013 if ag_e08b==4
tab subsidy_qty_2013,missing
replace subsidy_qty_2013 = 5*subsidy_qty_2013 if ag_e08b==5
tab subsidy_qty_2013,missing
replace subsidy_qty_2013 = 10*subsidy_qty_2013 if ag_e08b==6
tab subsidy_qty_2013,missing
replace subsidy_qty_2013 = 50*subsidy_qty_2013 if ag_e08b==7
tab subsidy_qty_2013,missing
replace subsidy_qty_2013 = 0 if subsidy_qty_2013==.

*checcking that the conversion is correct
*br ag_e08a ag_e08b subsidy_qty ag_e15 if  input_type<=11


*************Getting Subsidized Dummy Variable *******************

gen subsidy_dummy_2013 =1 if ag_e08a!=. & input_type<=11
tab subsidy_dummy_2013,missing
replace subsidy_dummy_2013=0 if subsidy_dummy_2013==.
tab subsidy_dummy_2013,missing



collapse (sum)subsidy_qty_2013 (max) subsidy_dummy_2013, by (HHID)
label var subsidy_qty_2013 "Quantity of Fertilizer Purchased with coupon in kg"
label var subsidy_dummy_2013 "=1 if acquired any fertilizer using coupon"
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













*********************************************** 
*Purchased Fertilizer
***********************************************

use "${mwi_GHS_W2_raw_data}\ag_mod_f_13.dta",clear 
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

egen total_qty_2013 = rowtotal(com_fert1_qty com_fert2_qty)
tab  total_qty_2013, missing

egen total_valuefert_2013 = rowtotal(com_fert1_val com_fert2_val)
tab total_valuefert_2013,missing

gen tpricefert_2013 = total_valuefert_2013/total_qty_2013
tab tpricefert_2013

gen tpricefert_cens_2013 = tpricefert_2013
replace tpricefert_cens_2013 = 500 if tpricefert_cens_2013 > 500 & tpricefert_cens_2013 < .
replace tpricefert_cens_2013 = 5 if tpricefert_cens_2013 < 5
tab tpricefert_cens_2013, missing





egen medianfert_pr_occ = median(tpricefert_cens_2013), by (occ)

egen medianfert_pr_qx_type  = median(tpricefert_cens_2013), by (qx_type )

egen num_fert_pr_occ = count(tpricefert_cens_2013), by (occ)

egen num_fert_pr_qx_type  = count(tpricefert_cens_2013), by (qx_type )


tab medianfert_pr_occ
tab medianfert_pr_qx_type



tab num_fert_pr_occ
tab num_fert_pr_qx_type



gen tpricefert_cens_mrk_2013 = tpricefert_cens_2013

replace tpricefert_cens_mrk_2013 = medianfert_pr_occ if tpricefert_cens_mrk_2013 ==.

tab tpricefert_cens_mrk_2013,missing

replace tpricefert_cens_mrk_2013 = medianfert_pr_qx_type if tpricefert_cens_mrk_2013 ==. 

tab tpricefert_cens_mrk_2013,missing









collapse (sum) total_qty_2013 total_valuefert_2013 (max) tpricefert_cens_mrk_2013, by(HHID)
label var total_qty_2013 "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert_2013 "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk_2013 "price of commercial fertilizer purchased in naira"
sort HHID
save "${mwi_GHS_W2_created_data}\commercial_fert_2013.dta", replace




************************************************
*Savings 
************************************************



/*use "${mwi_GHS_W1_raw_data}\ag_mod_f_10.dta",clear 

ren s4aq1 formal_bank_2018
tab formal_bank_2018, missing
replace formal_bank_2018 =0 if formal_bank_2018 ==2 | formal_bank_2018 ==.
tab formal_bank_2018, nolabel
tab formal_bank_2018,missing

 ren s4aq8 formal_save_2018
 tab formal_save_2018, missing
 replace formal_save_2018 =0 if formal_save_2018 ==2 | formal_save_2018 ==.
 tab formal_save_2018, missing

 ren s4aq10 informal_save_2018
 tab informal_save_2018, missing
 replace informal_save_2018 =0 if informal_save_2018 ==2 | informal_save_2018 ==.
 tab informal_save_2018, missing

 collapse (max) formal_bank_2018 formal_save_2018 informal_save_2018, by (hhid)
 la var formal_bank_2018 "=1 if respondent have an account in bank"
 la var formal_save_2018 "=1 if used formal saving group"
 la var informal_save_2018 "=1 if used informal saving group"
save "${mwi_GHS_W1_created_data}\commercial_fert_2010.dta", replace*/



*******************************************************
*Credit access 
*******************************************************


use "${mwi_GHS_W2_raw_data}\hh_mod_s1_13.dta",clear 
ren y2_hhid HHID
*hh_s01 borrowed on credit
*hh_s04 source of credit
tab hh_s01
label list HH_S04
 gen formal_credit_2013 =1 if hh_s01==1 & hh_s04 ==10 | hh_s04 ==11
 tab formal_credit_2013,missing
 replace formal_credit_2013 =0 if formal_credit_2013 ==.
 tab formal_credit_2013,missing
 

 
 gen informal_credit_2013 =1 if  hh_s01==1 & hh_s04 <=9 | hh_s04 ==12
 tab informal_credit_2013,missing
replace informal_credit_2013 =0 if informal_credit_2013 ==.
 tab informal_credit_2013,missing


 collapse (max) formal_credit_2013 informal_credit_2013, by (HHID)
 la var formal_credit_2013 "=1 if borrowed from formal credit group"
 la var informal_credit_2013 "=1 if borrowed from informal credit group"
save "${mwi_GHS_W2_created_data}\credit_access_2013.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${mwi_GHS_W2_raw_data}\ag_mod_t1_13.dta",clear 
ren y2_hhid HHID
ren ag_t01 ext_acess_2013

tab ext_acess_2013, missing
tab ext_acess_2013, nolabel

replace ext_acess_2013 = 0 if ext_acess_2013==2 | ext_acess_2013==.
tab ext_acess_2013, missing
collapse (max) ext_acess_2013, by (HHID)
la var ext_acess_2013 "=1 if received advise from extension services"
save "${mwi_GHS_W2_created_data}\Extension_access_2013.dta", replace




*********************************
*Demographics 
*********************************



use "${mwi_GHS_W2_raw_data}\hh_mod_b_13.dta",clear 


merge 1:1 y2_hhid PID using "${mwi_GHS_W2_raw_data}\hh_mod_c_13.dta"
ren y2_hhid HHID
*hh_b03 sex 
*hh_b04 relationshiop to head
*hh_b05a age (years)
*hhsize actual hhsize

sort HHID PID 
 
*gen num_mem_2013 = 1


******** female head****

gen femhead_2013 = 0
replace femhead_2013 = 1 if hh_b03== 2 & hh_b04==1
tab femhead_2013,missing

********Age of HHead***********
ren hh_b05a hh_age
gen hh_headage_2013 = hh_age if hh_b04==1

tab hh_headage_2013

replace hh_headage_2013 = 100 if hh_headage_2013 > 100 & hh_headage < .
tab hh_headage_2013
tab hh_headage_2013, missing


************generating the median age**************



egen median_headage_occ   = median(hh_headage_2013), by (occ )
egen median_headage_PID  = median(hh_headage_2013), by (PID )
egen median_headage_qx_type = median(hh_headage_2013), by (qx_type)


egen num_headage_occ   = count(hh_headage_2013), by (occ  )
egen num_headage_PID  = count(hh_headage_2013), by (PID )
egen num_headage_qx_type = count(hh_headage_2013), by (qx_type)

tab median_headage_occ 
tab median_headage_PID
tab median_headage_qx_type



tab num_headage_occ 
tab num_headage_PID
tab num_headage_qx_type



gen hh_headage_mrk_2013 = hh_headage_2013

replace hh_headage_mrk_2013 = median_headage_occ if hh_headage_mrk_2013 ==. & num_headage_occ >= 1

tab hh_headage_mrk_2013,missing
replace hh_headage_mrk_2013 = median_headage_PID if hh_headage_mrk_2013 ==. & num_headage_PID >= 1

tab hh_headage_mrk_2013,missing

replace hh_headage_mrk_2013 = median_headage_qx_type if hh_headage_mrk_2013 ==. & num_headage_qx_type >= 1

tab hh_headage_mrk_2013,missing




********************Education****************************************************
*hh_c06 attend_school
*hh_c09 highest_education qualification



ren  hh_c06 attend_sch_2013
tab attend_sch_2013
replace attend_sch_2013 = 0 if attend_sch_2013 ==2
tab attend_sch_2013, nolabel
*tab s1q4 if s2q7==.

replace hh_c08= 0 if attend_sch_2013==0
tab hh_c08
tab hh_b04 if _merge==1


*label list hh_c08
tab hh_c08 if hh_b04==1
replace hh_c08 = 2 if hh_c08==. &  hh_b04==1


*** Education Dummy Variable*****
 *label list hh_c08

gen pry_edu_2013 = 1 if hh_c08 < 8 & hh_b04==1
tab pry_edu_2013,missing
gen finish_pry_2013 = 1 if hh_c08 >= 8 & hh_c08 < 14 & hh_b04==1
tab finish_pry_2013,missing
gen finish_sec_2013 = 1 if hh_c08 >= 14 & hh_b04==1
tab finish_sec_2013,missing

replace pry_edu_2013 =0 if pry_edu_2013==. & hh_b04==1
replace finish_pry_2013 =0 if finish_pry_2013==. & hh_b04==1
replace finish_sec_2013 =0 if finish_sec_2013==. & hh_b04==1
tab pry_edu_2013 if hh_b04==1 , missing
tab finish_pry_2013 if hh_b04==1 , missing 
tab finish_sec_2013 if hh_b04==1 , missing

collapse (sum) hhsize (max) hh_headage_mrk_2013 femhead_2013 attend_sch_2013 pry_edu_2013 finish_pry_2013 finish_sec_2013, by (HHID)
la var hhsize "household size"
la var femhead_2013 "=1 if head is female"
la var hh_headage_mrk_2013 "age of household head in years"
la var attend_sch_2013 "=1 if respondent attended school"
la var pry_edu_2013 "=1 if household head attended pry school"
la var finish_pry_2013 "=1 if household head finished pry school"
la var finish_sec_2013 "=1 if household head finished sec school"
save "${mwi_GHS_W2_created_data}\demographics_2013.dta", replace

********************************* 
*Labor Age 
*********************************

use "${mwi_GHS_W2_raw_data}\hh_mod_b_13.dta",clear 

ren y2_hhid HHID
ren hh_b05a hh_age

gen worker_2013 = 1
replace worker_2013 = 0 if hh_age < 15 | hh_age > 65

tab worker_2013,missing
sort HHID
collapse (sum) worker_2013, by (HHID)
la var worker_2013 "number of members age 15 and older and less than 65"
sort HHID

save "${mwi_GHS_W2_created_data}\labor_age_2013.dta", replace


********************************
*Safety Net
********************************

use "${mwi_GHS_W2_raw_data}\hh_mod_r_13.dta",clear 
ren y2_hhid HHID
*hh_r01 received assistance
gen safety_net_2013 =1 if hh_r01==1 
tab safety_net_2013,missing
replace safety_net_2013 =0 if safety_net_2013==.
tab safety_net_2013,missing
collapse (max) safety_net_2013, by (HHID)
tab safety_net_2013
la var safety_net_2013 "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${mwi_GHS_W2_created_data}\safety_net_2013.dta", replace


**************************************
*Food Prices
**************************************
use "${mwi_GHS_W2_raw_data}\hh_mod_g1_13.dta",clear 
ren y2_hhid HHID
*hh_g04a   qty purchased by household (7days)
*hh_g04b hh_g04b_os     units purchased by household (7days)
*hh_g05    cost of purchase by household (7days)




*********Getting the price for maize only**************
* one congo is 1.5kg
*one derica is half a congo (0.75kg)
*one mudu is 1.5kg/5 (one congo is 5times one mudu) (0.3kg)
//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//2. 50kg     	    50
//3. 90kg     	    90
//4,5congo(pail)    1.5
//17.derica(tin)    0.75
//19.millitre       0.001
//9. pieces	        0.35

gen conversion =1
replace conversion=1 if hh_g04b=="1" | hh_g04b =="15"
gen food_size=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion = food_size*50 if hh_g04b=="2" 
replace conversion = food_size*90 if hh_g04b=="3" 
replace conversion = food_size*0.001 if hh_g04b=="18" |hh_g04b=="19" 
replace conversion = food_size*1.5 if hh_g04b=="4" |	hh_g04b=="5"
replace conversion = food_size*0.75 if hh_g04b=="17"
replace conversion = food_size*0.35 if hh_g04b=="9"			
tab conversion, missing

*label list HH_G02

gen food_price_maize = hh_g04a* conversion if hh_g02==104

gen maize_price_2013 = hh_g05/food_price_maize if hh_g02==104

*br hh_g04b conversion hh_g04a hh_g05 food_price_maize maize_price_2013 hh_g02 if hh_g02<=500

sum maize_price_2013,detail
tab maize_price_2013

*replace maize_price_2010 = 600 if maize_price_2010 >600 & maize_price_2010<.
*replace maize_price_2010 = 50 if maize_price_2010< 50
tab maize_price_2013,missing


egen medianfert_pr_occ = median(maize_price_2013), by (occ)
egen medianfert_pr_qx_type  = median(maize_price_2013), by (qx_type )


egen num_fert_pr_occ = count(maize_price_2013), by (occ)
egen num_fert_pr_qx_type = count(maize_price_2013), by (qx_type )


tab medianfert_pr_occ
tab medianfert_pr_qx_type



tab num_fert_pr_occ
tab num_fert_pr_qx_type


gen maize_price_mr_2013 = maize_price_2013

replace maize_price_mr_2013 = medianfert_pr_occ if maize_price_mr_2013==. 
tab maize_price_mr_2013,missing

replace maize_price_mr_2013 = medianfert_pr_qx_type if maize_price_mr_2013==. 
tab maize_price_mr_2013,missing



*********Getting the price for rice only**************
* one congo is 1.5kg
*one derica is half a congo (0.75kg)
*one mudu is 1.5kg/5 (one congo is 5times one mudu) (0.3kg)
//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//2. 50kg     	    50
//3. 90kg     	    90
//4,5congo(pail)    1.5
//17.derica(tin)    0.75
//19.millitre       0.001
//9. pieces	        0.35




gen food_price_rice = hh_g04a* conversion if hh_g02==106

gen rice_price_2013 = hh_g05/food_price_rice if hh_g02==106

*br hh_g04b conversion hh_g04a hh_g05 food_price_rice rice_price_2013 hh_g02 if hh_g02<=500

sum rice_price_2013,detail
tab rice_price_2013

replace rice_price_2013 = 900 if rice_price_2013 >900 & rice_price_2013<.
*replace rice_price_2013 = 30 if rice_price_2013< 30
tab rice_price_2013,missing


egen median_pr_occ = median(rice_price_2013), by (occ)
egen median_pr_qx_type  = median(rice_price_2013), by (qx_type )



egen num_pr_occ = count(rice_price_2013), by (occ)
egen num_pr_qx_type = count(rice_price_2013), by (qx_type )



tab median_pr_occ
tab median_pr_qx_type



tab num_pr_occ
tab num_pr_qx_type

gen rice_price_mr_2013 = rice_price_2013

replace rice_price_mr_2013 = median_pr_occ if rice_price_mr_2013==. 
tab rice_price_mr_2013,missing
replace rice_price_mr_2013 = median_pr_qx_type if rice_price_mr_2013==. 
tab rice_price_mr_2013,missing


collapse  (max) maize_price_mr_2013 rice_price_mr_2013, by(HHID)
label var maize_price_mr_2013 "commercial price of maize in naira"
label var rice_price_mr_2013 "commercial price of rice in naira"
sort HHID
save "${mwi_GHS_W2_created_data}\food_prices_2013.dta", replace





*****************************
*Household Assests
****************************


use "${mwi_GHS_W2_raw_data}\hh_mod_l_13.dta",clear 
ren y2_hhid HHID
*hh_l03 qty of items
*hh_l05 scrap value of items

gen hhasset_value_2013 = hh_l03*hh_l05
tab hhasset_value_2013,missing
sum hhasset_value_2013,detail
replace hhasset_value_2013 = 1000000 if hhasset_value_2013 > 1000000 & hhasset_value_2013 <.
replace hhasset_value_2013 = 50 if hhasset_value_2013 <50
tab hhasset_value_2013

************generating the mean vakue**************

egen mean_val_occ  = mean(hhasset_value_2013), by (occ )
egen mean_val_qx_type = mean(hhasset_value_2013), by (qx_type)


egen num_val_occ  = count(hhasset_value_2013), by (occ )
egen num_val_qx_type = count(hhasset_value_2013), by (qx_type)




tab mean_val_occ
tab mean_val_qx_type



tab num_val_occ
tab num_val_qx_type




replace hhasset_value_2013 = mean_val_occ if hhasset_value_2013 ==. & num_val_occ >= 835

tab hhasset_value_2013,missing

replace hhasset_value_2013 = mean_val_qx_type if hhasset_value_2013 ==. & num_val_qx_type >= 835

tab hhasset_value_2013,missing




collapse (sum) hhasset_value_2013, by (HHID)

la var hhasset_value_2013 "total value of household asset"
save "${mwi_GHS_W2_created_data}\hhasset_value_2013.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************
clear
 
 

use "${mwi_GHS_W2_raw_data}\ag_mod_p_13.dta",clear 

gen season=2 //perm
ren ag_p00 plot_id
ren ag_p0c crop_code
ren ag_p02a area
ren ag_p02b unit

drop if plot_id=="" //1,791 observations dropped
keep if strpos(plot_id, "T") & plot_id!="" 
collapse (max) area, by(y2_hhid plot_id crop_code season unit)
collapse (sum) area, by(y2_hhid plot_id season unit)
replace area=. if area==0 
drop if area==. & unit==.
gen area_acres_est = area if unit==1 											//Permanent crops in acres
replace area_acres_est = (area*2.47105) if unit == 2 & area_acres_est ==.		//Permanent crops in hectares
replace area_acres_est = (area*0.000247105) if unit == 3 & area_acres_est ==.	//Permanent crops in square meters
keep y2_hhid plot_id season area_acres_est
tempfile ag_perm
save `ag_perm'


use "${mwi_GHS_W2_raw_data}\ag_mod_c_13.dta",clear 
gen season=0 //rainy
append using "${mwi_GHS_W2_raw_data}\ag_mod_j_13.dta", gen(dry)
replace season=1 if season==. //dry
ren ag_c00 plot_id
replace plot_id=ag_j00 if plot_id=="" //971 real changes

* Counting acreage
gen area_acres_est = ag_c04a if ag_c04b == 1 										//Self-report in acres - rainy season 
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==.	//Self-report in square meters
replace area_acres_est = ag_j05a if ag_j05b==1 										//Replace with dry season measures if rainy season is not available
replace area_acres_est = (ag_j05a*2.47105) if ag_j05b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_j05a*0.000247105) if ag_j05b == 3 & area_acres_est ==.	//Self-report in square meters

* GPS MEASURE
gen area_acres_meas = ag_c04c														//GPS measure - rainy
replace area_acres_meas = ag_j05c if area_acres_meas==. 							//GPS measure - replace with dry if no rainy season measure

append using `ag_perm'
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season

gen field_size= (area_acres_est* (1/2.47105))
replace field_size = (area_acres_meas* (1/2.47105))  if field_size==. & area_acres_meas!=. 

ren y2_hhid HHID
collapse (sum) field_size, by (HHID)
sort HHID
ren field_size land_holding_2013
label var land_holding_2013 "land holding in hectares"
save "${mwi_GHS_W2_created_data}\land_holding_2013.dta", replace




*keep if area_acres_est !=. | area_acres_meas !=. //13,491 obs deleted - Keep if acreage or GPS measure info is available
*keep case_id plot_id season area_acres_est area_acres_meas field_size 			
*gen gps_meas = area_acres_meas!=. 
*lab var gps_meas "Plot was measured with GPS, 1=Yes"

*lab var area_acres_meas "Plot are in acres (GPSd)"
*lab var area_acres_est "Plot area in acres (estimated)"
*gen area_est_hectares= area_acres_est* (1/2.47105)  
*gen area_meas_hectares= area_acres_meas* (1/2.47105)
*lab var area_meas_hectares "Plot are in hectares (GPSd)"
*lab var area_est_hectares "Plot area in hectares (estimated)"
 






************************* Merging Agricultural Datasets ********************

use "${mwi_GHS_W2_created_data}\commercial_fert_2013.dta", replace


*******All observations Merged*****


merge 1:1 HHID using "${mwi_GHS_W2_created_data}\subsidized_fert_2013.dta", nogen

*merge 1:1 HHID using "${Nigeria_GHS_W4_created_data}\savings_2018.dta", nogen

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\credit_access_2013.dta", nogen

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\Extension_access_2013.dta", nogen

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\demographics_2013.dta", nogen

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\labor_age_2013.dta", nogen

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\safety_net_2013.dta", nogen

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\food_prices_2013.dta", nogen

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\hhasset_value_2013.dta", nogen

merge 1:1 HHID using "${mwi_GHS_W2_created_data}\land_holding_2013.dta"

save "${mwi_GHS_W2_created_data}\Malawi_wave2_completedata_2013.dta", replace

