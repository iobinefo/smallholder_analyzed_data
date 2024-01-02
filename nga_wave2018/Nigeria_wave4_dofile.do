










clear



global Nigeria_GHS_W4_raw_data 		"C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\NGA_2018_GHSP-W4_v03_M_Stata12 (1)"
global Nigeria_GHS_W4_created_data  "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\nga_wave2018"





*********************************************** 
*Used Fertilizer
***********************************************
use "${Nigeria_GHS_W4_raw_data}\secta11c2_harvestw4.dta",clear //plot level variables..... no question about agency where they purchased it
 

*s11dq1a      1= if used fertilizer on plot
*s11c2q36_1   1= if used npk on plot
*s11c2q36_2   1= if used urea on plot
*s11c2q36_99  1= if used other fert on plot
*s11c2q37a    qty of npk used 
*s11c2q37b    units of npk used 
*s11c2q37a_conv conversion factor
*s11c2q38a    qty of urea used
*s11c2q38b    units of urea used 
*s11c2q38a_conv  coversion factor
*s11c2q39a    qty of other fert
*s11c2q39b    units of other fert
*s11c2q39a_conv  conversion factor
*s11dq36      1= if used org fert on plot
*s11dq37a     qty of org used
*s11dq37b     units of org used
*s11c2q37_conv   conversion


*br s11c2q38a s11c2q38b s11c2q38a_conv

*****Coversion of fertilizer's units into kilogram using 

gen fert1 = s11c2q37a*s11c2q37a_conv 
gen fert2 = s11c2q38a*s11c2q38a_conv
gen fert3 = s11c2q39a*s11c2q39a_conv


****generate the total qty*************
egen total_qty_2018 = rowtotal(fert1 fert2 fert3)
tab  total_qty_2018

replace total_qty_2018 = 1000 if total_qty_2018> 1000
tab  total_qty_2018

collapse (max) total_qty_2018, by(hhid)
label var total_qty_2018 "quantity of inorganic fertilizer used in kg"
sort hhid
save "${Nigeria_GHS_W4_created_data}\total_qty_2018.dta", replace




*********************************************** 
*Purchased Fertilizer
***********************************************

use "${Nigeria_GHS_W4_raw_data}\secta11c3_harvestw4.dta",clear    //household level variables......... distance to purchase was also asked

*inputid  1= org fert| 2-4 inorg fert
*s11c3q2  1= hhold purchased inputs
*s11c3q4a qty of purchased inputs
*s11c3q4b units of purchased inputs
*s11c3q4_conv conversion factor
*s11c3q5  cost of inputs
*s11c3q6b institute of purchased
*s11c3q7  distance to institute (km)


******conversion to kg

gen input_kg = s11c3q4a*s11c3q4_conv

*br s11c3q4a s11c3q4b s11c3q4_conv input_kg

***getting the qty for inorg fertilizer

gen inorg_fert = input_kg if inputid >=2 & inputid <=4
*br input_kg inputid inorg_fert
tab inorg_fert

gen cost_fert = s11c3q5 if inputid >=2 & inputid <=4
*br s11c3q5 inputid cost_fert

gen tpricefert_2018 = cost_fert/inorg_fert
tab tpricefert_2018

gen tpricefert_cens_2018 = tpricefert_2018 
replace tpricefert_cens_2018 = 500 if tpricefert_cens_2018 > 500 & tpricefert_cens_2018 < .
replace tpricefert_cens_2018 = 40 if tpricefert_cens_2018 < 40
tab tpricefert_cens_2018, missing


egen medianfert_pr_ea = median(tpricefert_cens_2018), by (ea)
egen medianfert_pr_lga = median(tpricefert_cens_2018), by (lga)
egen medianfert_pr_state = median(tpricefert_cens_2018), by (state)
egen medianfert_pr_zone = median(tpricefert_cens_2018), by (zone)



egen num_fert_pr_ea = count(tpricefert_cens_2018), by (ea)
egen num_fert_pr_lga = count(tpricefert_cens_2018), by (lga)
egen num_fert_pr_state = count(tpricefert_cens_2018), by (state)
egen num_fert_pr_zone = count(tpricefert_cens_2018), by (zone)



tab medianfert_pr_ea
tab medianfert_pr_lga
tab medianfert_pr_state
tab medianfert_pr_zone



tab num_fert_pr_ea
tab num_fert_pr_lga
tab num_fert_pr_state
tab num_fert_pr_zone

gen tpricefert_cens_mrk_2018 = tpricefert_cens_2018

replace tpricefert_cens_mrk_2018 = medianfert_pr_ea if tpricefert_cens_mrk_2018 ==. & num_fert_pr_ea >= 7

tab tpricefert_cens_mrk_2018,missing


replace tpricefert_cens_mrk_2018 = medianfert_pr_lga if tpricefert_cens_mrk_2018 ==. & num_fert_pr_lga >= 7

tab tpricefert_cens_mrk_2018,missing



replace tpricefert_cens_mrk_2018 = medianfert_pr_state if tpricefert_cens_mrk_2018 ==. & num_fert_pr_state >= 7

tab tpricefert_cens_mrk_2018,missing


replace tpricefert_cens_mrk_2018 = medianfert_pr_zone if tpricefert_cens_mrk_2018 ==. & num_fert_pr_zone >= 7

tab tpricefert_cens_mrk_2018,missing


********Distance to institute of purchased fertilizer
gen distance_2018 = s11c3q7 if inputid >=2 & inputid <=4
tab distance_2018







collapse (max) distance_2018 tpricefert_cens_mrk_2018, by(hhid)
la var distance_2018 "Distance from farm to where you purchased inorg fertilizer"
label var tpricefert_cens_mrk_2018 "price of commercial fertilizer purchased in naira"
sort hhid
save "${Nigeria_GHS_W4_created_data}\purchased_fert_2018.dta", replace




************************************************
*Savings 
************************************************



use "${Nigeria_GHS_W4_raw_data}\sect4a1_plantingw4.dta",clear 

*s4aq1 1= have a bank acccount
*s4aq8 1= used commmercial bank savings
*s4aq10 1=  used informal savings

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
save "${Nigeria_GHS_W4_created_data}\savings_2018.dta", replace



*******************************************************
*Credit access 
*******************************************************

use "${Nigeria_GHS_W4_raw_data}\sect4c2_plantingw4.dta",clear 

*s4cq2b   type of loan lenders (=<4 formal banks)
*s4cq20   <=2 if loan was approved
 
tab s4cq2b
label list S4CQ20
 gen formal_credit_2018 =1 if s4cq20<=2 & s4cq2b <=4
 tab formal_credit_2018,missing
 replace formal_credit_2018 =0 if formal_credit_2018 ==.
 tab formal_credit_2018,missing
 
 
 gen informal_credit_2018 =1 if s4cq20<=2 & s4cq2b >=5
 tab informal_credit_2018,missing
replace informal_credit_2018 =0 if informal_credit_2018 ==.
 tab informal_credit_2018,missing


 collapse (max) formal_credit_2018 informal_credit_2018, by (hhid)
 la var formal_credit_2018 "=1 if borrowed from formal credit group"
 la var informal_credit_2018 "=1 if borrowed from informal credit group"
save "${Nigeria_GHS_W4_created_data}\credit_access_2018.dta", replace





******************************* 
*Extension Visit 
*******************************


use "${Nigeria_GHS_W4_raw_data}\sect11l1_plantingw4.dta",clear 


ren s11l1q1 ext_acess_2018

tab ext_acess_2018, missing
tab ext_acess_2018, nolabel

replace ext_acess_2018 = 0 if ext_acess_2018==2 | ext_acess_2018==.
tab ext_acess_2018, missing
collapse (max) ext_acess_2018, by (hhid)
la var ext_acess_2018 "=1 if received advise from extension services"
save "${Nigeria_GHS_W4_created_data}\extension_access_2018.dta", replace




*********************************
*Demographics 
*********************************



use "${Nigeria_GHS_W4_raw_data}\sect1_plantingw4.dta",clear 


merge 1:1 hhid indiv using "${Nigeria_GHS_W4_raw_data}\sect2_harvestw4.dta"

*s1q2 sex
*s1q3 relationship with hhead (1= head)
*s1q6 age (in years)
sort hhid indiv 
 
gen num_mem_2018 = 1


******** female head****

gen femhead_2018 = 0
replace femhead_2018 = 1 if s1q2== 2 & s1q3==1
tab femhead_2018,missing

********Age of HHead***********
ren s1q6 hh_age
gen hh_headage_2018 = hh_age if s1q3==1

tab hh_headage_2018

replace hh_headage_2018 = 100 if hh_headage_2018 > 100 & hh_headage < .
tab hh_headage_2018
tab hh_headage_2018, missing


************generating the median age**************

egen medianhh_pr_ea = median(hh_headage_2018), by (ea)

egen medianhh_pr_lga = median(hh_headage_2018), by (lga)

egen num_hh_pr_ea = count(hh_headage_2018), by (ea)

egen num_hh_pr_lga = count(hh_headage_2018), by (lga)

egen medianhh_pr_state = median(hh_headage_2018), by (state)
egen num_hh_pr_state = count(hh_headage_2018), by (state)

egen medianhh_pr_zone = median(hh_headage_2018), by (zone)
egen num_hh_pr_zone = count(hh_headage_2018), by (zone)


tab medianhh_pr_ea
tab medianhh_pr_lga
tab medianhh_pr_state
tab medianhh_pr_zone



tab num_hh_pr_ea
tab num_hh_pr_lga
tab num_hh_pr_state
tab num_hh_pr_zone



replace hh_headage_2018 = medianhh_pr_ea if hh_headage_2018 ==. & num_hh_pr_ea >= 30

tab hh_headage_2018,missing


replace hh_headage_2018 = medianhh_pr_lga if hh_headage_2018 ==. & num_hh_pr_lga >= 30

tab hh_headage_2018,missing



replace hh_headage_2018 = medianhh_pr_state if hh_headage_2018 ==. & num_hh_pr_state >= 30

tab hh_headage_2018,missing


replace hh_headage_2018 = medianhh_pr_zone if hh_headage_2018 ==. & num_hh_pr_zone >= 30

tab hh_headage_2018,missing

sum hh_headage_2018, detail



********************Education****************************************************
*s2aq6 attend school
*s2aq9 highest level of edu completed
*s1q3 relationship with hhead (1= head)

ren  s2aq6 attend_sch_2018
tab attend_sch_2018
replace attend_sch_2018 = 0 if attend_sch_2018 ==2
tab attend_sch_2018, nolabel
*tab s1q4 if s2q7==.

replace s2aq9= 0 if attend_sch_2018==0
tab s2aq9
tab s1q3 if _merge==1

tab s2aq9 if s1q3==1
replace s2aq9 = 16 if s2aq9==. &  s1q3==1

*** Education Dummy Variable*****

 label list S2AQ9

gen pry_edu_2018 = 1 if s2aq9 >= 1 & s2aq9 < 16 & s1q3==1
gen finish_pry_2018 = 1 if s2aq9 >= 16 & s2aq9 < 26 & s1q3==1
gen finish_sec_2018 = 1 if s2aq9 >= 26 & s2aq9 & s1q3==1
replace finish_sec_2018 =0 if s2aq9==51 | s2aq9==52 & s1q3==1

replace pry_edu_2018 =0 if pry_edu_2018==. & s1q3==1
replace finish_pry_2018 =0 if finish_pry_2018==. & s1q3==1
replace finish_sec_2018 =0 if finish_sec_2018==. & s1q3==1
tab pry_edu_2018 if s1q3==1 , missing
tab finish_pry_2018 if s1q3==1 , missing 
tab finish_sec_2018 if s1q3==1 , missing

collapse (sum) num_mem_2018 (max) hh_headage_2018 femhead_2018 attend_sch_2018 pry_edu_2018 finish_pry_2018 finish_sec_2018, by (hhid)
la var num_mem "household size"
la var femhead_2018 "=1 if head is female"
la var hh_headage_2018 "age of household head in years"
la var attend_sch_2018 "=1 if respondent attended school"
la var pry_edu_2018 "=1 if household head attended pry school"
la var finish_pry_2018 "=1 if household head finished pry school"
la var finish_sec_2018 "=1 if household head finished sec school"
save "${Nigeria_GHS_W4_created_data}\demographics_2018.dta", replace

********************************* 
*Labor Age 
*********************************
use "${Nigeria_GHS_W4_raw_data}\sect1_plantingw4.dta",clear 

ren s1q6 hh_age

gen worker_2018 = 1
replace worker_2018 = 0 if hh_age < 15 | hh_age > 65

tab worker_2018,missing
sort hhid
collapse (sum) worker_2018, by (hhid)
la var worker_2018 "number of members age 15 and older and less than 65"
sort hhid

save "${Nigeria_GHS_W4_created_data}\laborage_2018.dta", replace


********************************
*Safety Net
********************************

use "${Nigeria_GHS_W4_raw_data}\sect14a_harvestw4.dta",clear 

*s14q1a__1 1= received cash 
*s14q1a__2 1= received food 
*s14q1a__3 1= received other kinds
**s14q1a__4 1= received from institutes 

gen safety_net_2018 =1 if s14q1a__1==1 | s14q1a__2==1 | s14q1a__3==1 | s14q1a__4==1

replace safety_net_2018 =0 if safety_net_2018==.
tab safety_net_2018,missing
collapse (max) safety_net_2018, by (hhid)
tab safety_net_2018
la var safety_net_2018 "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${Nigeria_GHS_W4_created_data}\safety_net_2018.dta", replace







**************************************
*Food Prices
**************************************
use "${Nigeria_GHS_W4_raw_data}\sect7b_plantingw4.dta", clear

*s7bq9a   qty purchased by household (7days)
*s7bq9_cvn conversion factor
*s7bq10    cost of purchase by household (7days)





gen food_price_maize = s7bq9a* s7bq9_cvn if item_cd==16

gen maize_price_2018 = s7bq10/food_price_maize if item_cd==16

*br s7bq9b s7bq9a s7bq9_cvn  food_price_maize s7bq10 maize_price_2018 item_cd if item_cd<=27

sum maize_price_2018,detail
tab maize_price_2018

replace maize_price_2018 = 700 if maize_price_2018 >700 & maize_price_2018<.

tab maize_price_2018,missing



egen median_pr_ea = median(maize_price_2018), by (ea)
egen median_pr_lga = median(maize_price_2018), by (lga)
egen median_pr_sector = median(maize_price_2018), by (sector)
egen median_pr_state = median(maize_price_2018), by (state)
egen median_pr_zone = median(maize_price_2018), by (zone)

egen num_pr_ea = count(maize_price_2018), by (ea)
egen num_pr_lga = count(maize_price_2018), by (lga)
egen num_pr_sector = count(maize_price_2018), by (sector)
egen num_pr_state = count(maize_price_2018), by (state)
egen num_pr_zone = count(maize_price_2018), by (zone)

tab num_pr_ea
tab num_pr_lga
tab num_pr_state
tab num_pr_zone


gen maize_price_mr_2018 = maize_price_2018

replace maize_price_mr_2018 = median_pr_ea if maize_price_mr_2018==. & num_pr_ea>=8
tab maize_price_mr_2018,missing

replace maize_price_mr_2018 = median_pr_lga if maize_price_mr_2018==. & num_pr_lga>=8
tab maize_price_mr_2018,missing

replace maize_price_mr_2018 = median_pr_state if maize_price_mr_2018==. & num_pr_state>=8
tab maize_price_mr_2018,missing

replace maize_price_mr_2018 = median_pr_zone if maize_price_mr_2018==. & num_pr_zone>=8
tab maize_price_mr_2018,missing
replace maize_price_mr_2018 = median_pr_sector if maize_price_mr_2018==. & num_pr_sector>=8
tab maize_price_mr_2018,missing



*********Getting the price for rice only**************



gen food_price_rice = s7bq9a* s7bq9_cvn if item_cd==13

gen rice_price_2018 = s7bq10/food_price_rice if item_cd==13 

*br s7bq9b s7bq9a s7bq9_cvn  food_price_rice s7bq10 rice_price_2018 item_cd if item_cd<=27

sum rice_price_2018,detail
tab rice_price_2018

replace rice_price_2018 = 750 if rice_price_2018 >750 & rice_price_2018<.  //one percent
replace rice_price_2018 = 100 if rice_price_2018< 100
tab rice_price_2018,missing



egen median_rice_ea = median(rice_price_2018), by (ea)
egen median_rice_lga = median(rice_price_2018), by (lga)
egen median_rice_state = median(rice_price_2018), by (state)
egen median_rice_zone = median(rice_price_2018), by (zone)

egen num_rice_ea = count(rice_price_2018), by (ea)
egen num_rice_lga = count(rice_price_2018), by (lga)
egen num_rice_state = count(rice_price_2018), by (state)
egen num_rice_zone = count(rice_price_2018), by (zone)

tab num_rice_ea
tab num_rice_lga
tab num_rice_state
tab num_rice_zone


gen rice_price_mr_2018 = rice_price_2018

replace rice_price_mr_2018 = median_rice_ea if rice_price_mr_2018==. & num_rice_ea>=26
tab rice_price_mr_2018,missing

replace rice_price_mr_2018 = median_rice_lga if rice_price_mr_2018==. & num_rice_lga>=26
tab rice_price_mr_2018,missing

replace rice_price_mr_2018 = median_rice_state if rice_price_mr_2018==. & num_rice_state>=26
tab rice_price_mr_2018,missing

replace rice_price_mr_2018 = median_rice_zone if rice_price_mr_2018==. & num_rice_zone>=26
tab rice_price_mr_2018,missing


collapse  (max) maize_price_mr_2018 rice_price_mr_2018, by(hhid)
label var maize_price_mr_2018 "commercial price of maize in naira"
label var rice_price_mr_2018 "commercial price of rice in naira"
sort hhid
save "${Nigeria_GHS_W4_created_data}\food_prices_2018.dta", replace





*****************************
*Household Assests
****************************


use "${Nigeria_GHS_W4_raw_data}\sect5_plantingw4.dta",clear 

sort hhid item_cd

*s5q1 qty of item
*s5q4 value of item

gen hhasset_value_2018 = s5q4*s5q1
tab hhasset_value_2018,missing
sum hhasset_value_2018,detail
replace hhasset_value_2018 = 1000000 if hhasset_value_2018 > 2000000 & hhasset_value_2018 <.
replace hhasset_value_2018 = 200 if hhasset_value_2018 <200


************generating the mean vakue**************

egen mean_val_ea = mean(hhasset_value_2018), by (ea)

egen mean_val_lga = mean(hhasset_value_2018), by (lga)

egen num_val_pr_ea = count(hhasset_value_2018), by (ea)

egen num_val_pr_lga = count(hhasset_value_2018), by (lga)

egen mean_val_state = mean(hhasset_value_2018), by (state)
egen num_val_pr_state = count(hhasset_value_2018), by (state)

egen mean_val_zone = mean(hhasset_value_2018), by (zone)
egen num_val_pr_zone = count(hhasset_value_2018), by (zone)


tab mean_val_ea
tab mean_val_lga
tab mean_val_state
tab mean_val_zone



tab num_val_pr_ea
tab num_val_pr_lga
tab num_val_pr_state
tab num_val_pr_zone



replace hhasset_value_2018 = mean_val_ea if hhasset_value_2018 ==. & num_val_pr_ea >= 309

tab hhasset_value_2018,missing


replace hhasset_value_2018 = mean_val_lga if hhasset_value_2018 ==. & num_val_pr_lga >= 309

tab hhasset_value_2018,missing



replace hhasset_value_2018 = mean_val_state if hhasset_value_2018 ==. & num_val_pr_state >= 309

tab hhasset_value_2018,missing


replace hhasset_value_2018 = mean_val_zone if hhasset_value_2018 ==. & num_val_pr_zone >= 309

tab hhasset_value_2018,missing

sum hhasset_value_2018, detail



collapse (sum) hhasset_value_2018, by (hhid)

la var hhasset_value_2018 "total value of household asset"
save "${Nigeria_GHS_W4_created_data}\household_asset_2018.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************
clear
 
 
 
 *************** Plot Size **********************

//ALT IMPORTANT NOTE: As of W4, the implied area conversions for farmer estimated units (including hectares) are markedly different from previous waves. I recommend excluding plots that do not have GPS measured areas from any area-based productivity estimates.
use "${Nigeria_GHS_W4_raw_data}/sect11a1_plantingw4.dta", clear
*merging in planting section to get cultivated status
merge 1:1 hhid plotid using "${Nigeria_GHS_W4_raw_data}/sect11b1_plantingw4.dta", nogen
*merging in harvest section to get areas for new plots
merge 1:1 hhid plotid using "${Nigeria_GHS_W4_raw_data}/secta1_harvestw4.dta", gen(plot_merge)
 
ren s11aq4aa area_size
ren s11aq4b area_unit
ren sa1q11 area_size2 //GPS measurement, no units in file
//ren sa1q9b area_unit2 //Not in file
ren s11aq4c area_meas_sqm
//ren sa1q9c area_meas_sqm2
gen cultivate = s11b1q27 ==1 


gen field_size= area_size if area_unit==6
replace field_size = area_size*0.0667 if area_unit==4									//reported in plots
replace field_size = area_size*0.404686 if area_unit==5		    						//reported in acres
replace field_size = area_size*0.0001 if area_unit==7									//reported in square meters

replace field_size = area_size*0.00012 if area_unit==1 & zone==1						//reported in heaps
replace field_size = area_size*0.00016 if area_unit==1 & zone==2
replace field_size = area_size*0.00011 if area_unit==1 & zone==3
replace field_size = area_size*0.00019 if area_unit==1 & zone==4
replace field_size = area_size*0.00021 if area_unit==1 & zone==5
replace field_size = area_size*0.00012 if area_unit==1 & zone==6

replace field_size = area_size*0.0027 if area_unit==2 & zone==1							//reported in ridges
replace field_size = area_size*0.004 if area_unit==2 & zone==2
replace field_size = area_size*0.00494 if area_unit==2 & zone==3
replace field_size = area_size*0.0023 if area_unit==2 & zone==4
replace field_size = area_size*0.0023 if area_unit==2 & zone==5
replace field_size = area_size*0.00001 if area_unit==2 & zone==6

replace field_size = area_size*0.00006 if area_unit==3 & zone==1						//reported in stands
replace field_size = area_size*0.00016 if area_unit==3 & zone==2
replace field_size = area_size*0.00004 if area_unit==3 & zone==3
replace field_size = area_size*0.00004 if area_unit==3 & zone==4
replace field_size = area_size*0.00013 if area_unit==3 & zone==5
replace field_size = area_size*0.00041 if area_unit==3 & zone==6



/*ALT 02.23.23*/ gen area_est = field_size
*replacing farmer reported with GPS if available
replace field_size = area_meas_sqm*0.0001 if area_meas_sqm!=.               				
gen gps_meas = (area_meas_sqm!=.)
la var gps_meas "Plot was measured with GPS, 1=Yes"
ren plotid plot_id
*Total land holding including cultivated and rented out
collapse (sum) field_size, by (hhid)
sort hhid
ren field_size land_holding_2018
label var land_holding_2018 "land holding in hectares"
save "${Nigeria_GHS_W4_created_data}\land_holding_2018.dta", replace

 






************************* Merging Agricultural Datasets ********************

use "${Nigeria_GHS_W4_created_data}\purchased_fert_2018.dta", replace


*******All observations Merged*****


merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\total_qty_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\savings_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\credit_access_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\extension_access_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\demographics_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\laborage_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\safety_net_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\food_prices_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\household_asset_2018.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}\land_holding_2018.dta"

save "${Nigeria_GHS_W4_created_data}\Nigeria_wave4_completedata_2018.dta", replace

