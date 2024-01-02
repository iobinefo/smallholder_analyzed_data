










clear

global Nigeria_GHS_W2_raw_data 		"C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA" 
global Nigeria_GHS_W2_created_data  "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\nga_wave2012"

****************************
*Subsidized Fertilizer
****************************


use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Agriculture\sect11d_plantingw2.dta",clear 

*************Checking to confirm its the subsidized price *******************

*s11dq14 1st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq26 2st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq40     		source of org purchased fertilizer (1=govt, 2=private)
*s11dq16 s11dq28  qty of inorg purchased fertilizer
*s11dq19  s11dq29	value of inorg purchased fertilizer




encode s11dq14, gen(institute)
label list institute


encode s11dq26, gen(institute2)
label list institute2




gen pricefert = s11dq19/ s11dq16


gen subsidy_check = pricefert if institute ==1
sum subsidy,detail


gen private_check = pricefert if institute ==4
sum private,detail



*************Getting Subsidized quantity and Dummy Variable *******************
gen subsidy_qty1 = s11dq16 if institute ==1
tab subsidy_qty1
gen subsidy_qty2 = s11dq28 if institute2 ==1
tab subsidy_qty2


egen subsidy_qty_2012 = rowtotal(subsidy_qty1 subsidy_qty2)
tab subsidy_qty_2012,missing
sum subsidy_qty_2012,detail


gen subsidy_dummy_2012 = 0
replace subsidy_dummy_2012 = 1 if institute==1
tab subsidy_dummy_2012, missing
replace subsidy_dummy_2012 = 1 if institute2==1
tab subsidy_dummy_2012, missing



collapse (sum)subsidy_qty_2012 (max) subsidy_dummy_2012, by (hhid)
label var subsidy_qty_2012 "Quantity of Fertilizer Purchased in kg"
label var subsidy_dummy_2012 "=1 if acquired any subsidied fertilizer"
save "${Nigeria_GHS_W2_created_data}\subsidized_fert_2012.dta", replace




*********************************************** 
*Purchased Fertilizer
***********************************************

use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Agriculture\sect11d_plantingw2.dta",clear  

*s11dq14 1st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq26 2st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq40     		source of org purchased fertilizer (1=govt, 2=private)
*s11dq16 s11dq28  qty of inorg purchased fertilizer
*s11dq19  s11dq29	value of inorg purchased fertilizer




encode s11dq14, gen(institute)
label list institute


encode s11dq26, gen(institute2)
label list institute2




***fertilzer total quantity, total value & total price****

gen private_fert1_qty_2012 = s11dq16 if institute ==4
tab private_fert1_qty_2012, missing
gen private_fert2_qty_2012 = s11dq28 if institute2 ==4
tab private_fert2_qty_2012,missing

gen private_fert1_val_2012 = s11dq19 if institute ==4
tab private_fert1_val_2012,missing
gen private_fert2_val_2012 = s11dq29 if institute2 ==4
tab private_fert2_val_2012,missing

egen total_qty_2012 = rowtotal(private_fert1_qty_2012 private_fert2_qty_2012)
tab  total_qty_2012, missing

egen total_valuefert_2012 = rowtotal(private_fert1_val_2012 private_fert2_val_2012)
tab total_valuefert_2012,missing

gen tpricefert_2012 = total_valuefert_2012/total_qty_2012
tab tpricefert_2012

gen tpricefert_cens_2012 = tpricefert_2012 
replace tpricefert_cens_2012 = 650 if tpricefert_2012 > 650 & tpricefert_2012 < .
replace tpricefert_cens_2012 = 2 if tpricefert_2012 < 2
tab tpricefert_cens_2012, missing





egen medianfert_pr_ea = median(tpricefert_cens_2012), by (ea)

egen medianfert_pr_lga = median(tpricefert_cens_2012), by (lga)

egen num_fert_pr_ea = count(tpricefert_cens_2012), by (ea)

egen num_fert_pr_lga = count(tpricefert_cens_2012), by (lga)

egen medianfert_pr_state = median(tpricefert_cens_2012), by (state)
egen num_fert_pr_state = count(tpricefert_cens_2012), by (state)

egen medianfert_pr_zone = median(tpricefert_cens_2012), by (zone)
egen num_fert_pr_zone = count(tpricefert_cens_2012), by (zone)



tab medianfert_pr_ea
tab medianfert_pr_lga
tab medianfert_pr_state
tab medianfert_pr_zone



tab num_fert_pr_ea
tab num_fert_pr_lga
tab num_fert_pr_state
tab num_fert_pr_zone

gen tpricefert_cens_mrk_2012 = tpricefert_cens_2012

replace tpricefert_cens_mrk_2012 = medianfert_pr_ea if tpricefert_cens_mrk_2012 ==. & num_fert_pr_ea >= 7

tab tpricefert_cens_mrk_2012,missing


replace tpricefert_cens_mrk_2012 = medianfert_pr_lga if tpricefert_cens_mrk_2012 ==. & num_fert_pr_lga >= 7

tab tpricefert_cens_mrk_2012,missing



replace tpricefert_cens_mrk_2012 = medianfert_pr_state if tpricefert_cens_mrk_2012 ==. & num_fert_pr_state >= 7

tab tpricefert_cens_mrk_2012,missing


replace tpricefert_cens_mrk_2012 = medianfert_pr_zone if tpricefert_cens_mrk_2012 ==. & num_fert_pr_zone >= 7

tab tpricefert_cens_mrk_2012,missing






collapse (sum) total_qty_2012 total_valuefert_2012 (max) tpricefert_cens_mrk_2012, by(hhid)
label var total_qty_2012 "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert_2012 "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk_2012 "price of commercial fertilizer purchased in naira"
sort hhid
save "${Nigeria_GHS_W2_created_data}\purchased_fert_2012.dta", replace



************************************************
*Savings 
************************************************

use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect4a_plantingw2.dta",clear  

*s4aq1  1= formal bank
*s4aq9b s4aq9d s4aq9f  types of formal fin institute used to save money
*s4aq10 1= informal saving



ren s4aq1 formal_bank_2012
tab formal_bank_2012, missing
replace formal_bank_2012 =0 if formal_bank_2012 ==2 | formal_bank_2012 ==.
tab formal_bank_2012, nolabel
tab formal_bank_2012,missing

 gen formal_save_2012 = 1 if s4aq9b !=. | s4aq9d !=.| s4aq9f !=.
 tab formal_save_2012, missing
 replace formal_save_2012 = 0 if formal_save ==.
 tab formal_save_2012, missing

 ren s4aq10 informal_save_2012
 tab informal_save_2012, missing
 replace informal_save_2012 =0 if informal_save_2012 ==2 | informal_save_2012 ==.
 tab informal_save_2012, missing

 collapse (max) formal_bank_2012 formal_save_2012 informal_save_2012, by (hhid)
 la var formal_bank_2012 "=1 if respondent have an account in bank"
 la var formal_save_2012 "=1 if used formal saving group"
 la var informal_save_2012 "=1 if used informal saving group"
save "${Nigeria_GHS_W2_created_data}\savings_2012.dta", replace



*******************************************************
*Credit access 
*******************************************************

use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect4a_plantingw2.dta",clear  

*s4aq12b s4aq12d s4aq12f  types of formal fin institute used to borrow money
*s4aq13     1= borrowed from informal group




 gen formal_credit_2012 =1 if s4aq12b !=. | s4aq12d !=. | s4aq12f !=.
 tab formal_credit_2012,missing
 replace formal_credit_2012 =0 if formal_credit ==.
 tab formal_credit_2012,missing
 
 ren  s4aq13 informal_credit_2012
 tab informal_credit_2012, missing
 replace informal_credit_2012 =0 if informal_credit ==2 | informal_credit ==.
 tab informal_credit_2012,missing


 collapse (max) formal_credit_2012 informal_credit_2012, by (hhid)
 la var formal_credit_2012 "=1 if borrowed from formal credit group"
 la var informal_credit_2012 "=1 if borrowed from informal credit group"
save "${Nigeria_GHS_W2_created_data}\credit_2012.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Agriculture\sect11l1_plantingw2.dta",clear  



ren s11l1q1 ext_acess_2012

tab ext_acess_2012, missing
tab ext_acess_2012, nolabel

replace ext_acess_2012 = 0 if ext_acess_2012==2 | ext_acess_2012==.
tab ext_acess_2012, missing
collapse (max) ext_acess_2012, by (hhid)
la var ext_acess_2012 "=1 if received advise from extension services"
save "${Nigeria_GHS_W2_created_data}\extension_visit_2012.dta", replace




*********************************
*Demographics 
*********************************

use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect1_plantingw2.dta",clear 

merge 1:1 hhid indiv using "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect2_plantingw2.dta"

*s1q2   sex
*s1q3   relationship to hhead
*s1q6   age in years




sort hhid indiv 
 
gen num_mem_2012 = 1



******** female head****

gen femhead_2012 = 0
replace femhead_2012 = 1 if s1q2== 2 & s1q3==1
tab femhead_2012,missing

********Age of HHead***********
ren s1q6 hh_age
gen hh_headage_2012 = hh_age if s1q3==1

tab hh_headage_2012

replace hh_headage_2012 = 100 if hh_headage_2012 > 100 & hh_headage < .
tab hh_headage_2012
tab hh_headage_2012, missing

egen hh_headage_cens = median(hh_headage_2012)
tab hh_headage_cens

***** replacing the missing age values with the median age for household head
replace hh_headage_2012 = hh_headage_cens if hh_headage_2012 ==.
tab hh_headage_2012, missing
sum hh_headage_2012, detail



********************Education****************************************************

*s2q5  1= attended school
*s2q8  highest education level
*s1q3 relationship to hhead


ren s2q5 attend_sch_2012
tab attend_sch_2012
replace attend_sch_2012 = 0 if attend_sch_2012 ==2
tab attend_sch_2012, nolabel
*tab s1q4 if s2q7==.

replace s2q8= 0 if attend_sch_2012==0
tab s2q8
tab s1q3 if _merge==1

tab s2q8 if s1q3==1
replace s2q8 = 16 if s2q8==. &  s1q3==1

*** Education Dummy Variable*****

 label list S2Q8

gen pry_edu_2012 = 1 if s2q8 >= 1 & s2q8 < 16 & s1q3==1
gen finish_pry_2012 = 1 if s2q8 >= 16 & s2q8 < 26 & s1q3==1
gen finish_sec_2012 = 1 if s2q8 >= 26 & s2q8 < 43 & s1q3==1

replace pry_edu_2012 =0 if pry_edu_2012==. & s1q3==1
replace finish_pry_2012 =0 if finish_pry_2012==. & s1q3==1
replace finish_sec_2012 =0 if finish_sec==. & s1q3==1
tab pry_edu_2012 if s1q3==1 , missing
tab finish_pry_2012 if s1q3==1 , missing 
tab finish_sec_2012 if s1q3==1 , missing

collapse (sum) num_mem_2012 (max) hh_headage_2012 femhead_2012 attend_sch_2012 pry_edu_2012 finish_pry_2012 finish_sec_2012, by (hhid)
la var num_mem "household size"
la var femhead_2012 "=1 if head is female"
la var hh_headage_2012 "age of household head in years"
la var attend_sch_2012 "=1 if respondent attended school"
la var pry_edu_2012 "=1 if household head attended pry school"
la var finish_pry_2012 "=1 if household head finished pry school"
la var finish_sec_2012 "=1 if household head finished sec school"
save "${Nigeria_GHS_W2_created_data}\demographics_2012.dta", replace

********************************* 
*Labor Age 
*********************************
use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect1_plantingw2.dta",clear 

ren s1q6 hh_age

gen worker_2012 = 1
replace worker_2012 = 0 if hh_age < 15 | hh_age > 65

tab worker_2012,missing
sort hhid
collapse (sum) worker_2012, by (hhid)
la var worker_2012 "number of members age 15 and older and less than 65"
sort hhid

save "${Nigeria_GHS_W2_created_data}\labor_age_2012.dta", replace


********************************
*Safety Net
********************************

use "${Nigeria_GHS_W2_raw_data}\Post Harvest Wave 2\Household\sect14_harvestw2.dta",clear 

ren s14q1 safety_net_2012
replace safety_net_2012 =0 if safety_net_2012 ==2 | safety_net_2012==.
tab safety_net_2012,missing
collapse (max) safety_net_2012, by (hhid)
tab safety_net_2012
la var safety_net_2012 "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${Nigeria_GHS_W2_created_data}\safety_net_2012.dta", replace


**************************************
*Food Prices
**************************************
use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect7b_plantingw2.dta", clear

*s7bq3a   qty purchased by household (7days)
*s7bq3b s7bq3c     units purchased by household (7days)
*s7bq4    cost of purchase by household (7days)




*********Getting the price for maize only**************
* one congo is 1.5kg
*one derica is half a congo (0.75kg)
*one mudu is 1.5kg/5 (one congo is 5times one mudu) (0.3kg)
//   Unit           Conversion Factor for maize
//   Kilogram       1
//   gram        	0.001
//	 litre     		1
//	 cenlitre     	0.01
//	 congo          1.5
//	 derica         0.75
//	 mudu           0.30
//	 pieces	        0.35

gen conversion =1
replace conversion=1 if s7bq3b==1 | s7bq3b ==3
gen food_size=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion = food_size*0.001 if s7bq3b==2 |	s7bq3b==4 
replace conversion = food_size*0.30 if s7bq3b==5	
replace conversion = food_size*1.5 if s7bq3b==7
replace conversion = food_size*0.75 if s7bq3b==10 |	s7bq3b==11	
replace conversion = food_size*0.30 if s7bq3b==16				
tab conversion, missing	



gen food_price_maize = s7bq3a* conversion if item_cd==16

gen maize_price_2012 = s7bq4/food_price_maize if item_cd==16

*br  s7bq3b conversion s7bq3a s7bq4  food_price_maize maize_price_2012 item_cd if item_cd<=27

sum maize_price_2012,detail
tab maize_price_2012

replace maize_price_2012 = 700 if maize_price_2012 >700 & maize_price_2012<.
replace maize_price_2012 = 20 if maize_price_2012< 20
tab maize_price_2012,missing



egen median_pr_ea = median(maize_price_2012), by (ea)
egen median_pr_lga = median(maize_price_2012), by (lga)
egen median_pr_sector = median(maize_price_2012), by (sector)
egen median_pr_state = median(maize_price_2012), by (state)
egen median_pr_zone = median(maize_price_2012), by (zone)

egen num_pr_ea = count(maize_price_2012), by (ea)
egen num_pr_lga = count(maize_price_2012), by (lga)
egen num_pr_sector = count(maize_price_2012), by (sector)
egen num_pr_state = count(maize_price_2012), by (state)
egen num_pr_zone = count(maize_price_2012), by (zone)

tab num_pr_ea
tab num_pr_lga
tab num_pr_state
tab num_pr_zone


gen maize_price_mr_2012 = maize_price_2012

replace maize_price_mr_2012 = median_pr_ea if maize_price_mr_2012==. & num_pr_ea>=5
tab maize_price_mr_2012,missing

replace maize_price_mr_2012 = median_pr_lga if maize_price_mr_2012==. & num_pr_lga>=5
tab maize_price_mr_2012,missing
replace maize_price_mr_2012 = median_pr_sector if maize_price_mr_2012==. & num_pr_sector>=5
tab maize_price_mr_2012,missing

replace maize_price_mr_2012 = median_pr_state if maize_price_mr_2012==. & num_pr_state>=5
tab maize_price_mr_2012,missing

replace maize_price_mr_2012 = median_pr_zone if maize_price_mr_2012==. & num_pr_zone>=5
tab maize_price_mr_2012,missing



*********Getting the price for rice only**************
* one congo is 1.5kg
*one derica is half a congo (0.75kg)
*one mudu is 1.5kg/5 (one congo is 5times one mudu) (0.3kg)
//   Unit           Conversion Factor for maize
//   Kilogram       1
//   gram        	0.001
//	 litre     		1
//	 cenlitre     	0.01
//	 congo          1.5
//	 derica         0.75
//	 mudu           0.30
//	 pieces	        0.35




gen food_price_rice = s7bq3a* conversion if item_cd==13

gen rice_price_2012 = s7bq4/food_price_rice if item_cd==13 

*br  s7bq3b conversion s7bq3a food_price_rice s7bq4 rice_price_2012 item_cd if item_cd<=17

sum rice_price_2012,detail
tab rice_price_2012

replace rice_price_2012 = 900 if rice_price_2012 >900 & rice_price_2012<.
replace rice_price_2012 = 25 if rice_price_2012< 25
tab rice_price_2012,missing



egen median_rice_ea = median(rice_price_2012), by (ea)
egen median_rice_lga = median(rice_price_2012), by (lga)
egen median_rice_state = median(rice_price_2012), by (state)
egen median_rice_zone = median(rice_price_2012), by (zone)

egen num_rice_ea = count(rice_price_2012), by (ea)
egen num_rice_lga = count(rice_price_2012), by (lga)
egen num_rice_state = count(rice_price_2012), by (state)
egen num_rice_zone = count(rice_price_2012), by (zone)

tab num_rice_ea
tab num_rice_lga
tab num_rice_state
tab num_rice_zone


gen rice_price_mr_2012 = rice_price_2012

replace rice_price_mr_2012 = median_rice_ea if rice_price_mr_2012==. & num_rice_ea>=7
tab rice_price_mr_2012,missing

replace rice_price_mr_2012 = median_rice_lga if rice_price_mr_2012==. & num_rice_lga>=7
tab rice_price_mr_2012,missing

replace rice_price_mr_2012 = median_rice_state if rice_price_mr_2012==. & num_rice_state>=7
tab rice_price_mr_2012,missing

replace rice_price_mr_2012 = median_rice_zone if rice_price_mr_2012==. & num_rice_zone>=7
tab rice_price_mr_2012,missing


collapse  (max) maize_price_mr_2012 rice_price_mr_2012, by(hhid)
label var maize_price_mr_2012 "commercial price of maize in naira"
label var rice_price_mr_2012 "commercial price of rice in naira"
sort hhid
save "${Nigeria_GHS_W2_created_data}\food_prices_2012.dta", replace





*****************************
*Household Assests
****************************



use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect5a_plantingw2.dta",clear 

sort hhid item_cd

collapse (sum) s5q1, by (hhid item_cd)
tab item_cd,missing
save "${Nigeria_GHS_W2_created_data}\item_qty_2012.dta", replace


use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect5b_plantingw2.dta",clear 
sort hhid item_cd
collapse (mean) s5q4, by (hhid item_cd)
tab item_cd
save "${Nigeria_GHS_W2_created_data}\item_cost_2012.dta", replace

*******************Merging assest***********************
sort hhid item_cd
merge 1:1 hhid item_cd using "${Nigeria_GHS_W2_created_data}\item_qty_2012.dta"
drop _merge
gen hhasset_value_2012 = s5q4*s5q1
replace hhasset_value_2012 = 1000000 if hhasset_value_2012 > 1000000 & hhasset_value_2012 <.
replace hhasset_value_2012 = 200 if hhasset_value_2012 <200
egen hhasset_median = median(hhasset_value_2012)
tab hhasset_median
tab hhasset_value_2012,missing
replace hhasset_value_2012 = hhasset_median if hhasset_value_2012==.
tab hhasset_value_2012,missing
collapse (sum) hhasset_value_2012, by (hhid)

la var hhasset_value_2012 "total value of household asset"
save "${Nigeria_GHS_W2_created_data}\asset_value_2012.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************
*starting with planting
clear


*using conversion factors from LSMS-ISA Nigeria Wave 2 Basic Information Document (Waves 1 & 2 are identical)
*found at http://econ.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/EXTLSMS/0,,contentMDK:23635560~pagePK:64168445~piPK:64168309~theSitePK:3358997,00.html
*General Conversion Factors to Hectares
//		Zone   Unit         Conversion Factor
//		All    Plots        0.0667
//		All    Acres        0.4
//		All    Hectares     1
//		All    Sq Meters    0.0001
*Zone Specific Conversion Factors to Hectares
//		Zone           Conversion Factor
//				 Heaps      Ridges      Stands
//		1 		 0.00012 	0.0027 		0.00006
//		2 		 0.00016 	0.004 		0.00016
//		3 		 0.00011 	0.00494 	0.00004
//		4 		 0.00019 	0.0023 		0.00004
//		5 		 0.00021 	0.0023 		0.00013
//		6  		 0.00012 	0.00001 	0.00041
set obs 42 //6 zones x 7 units
egen zone=seq(), f(1) t(6) b(7)
egen area_unit=seq(), f(1) t(7)
gen conversion=1 if area_unit==6
gen area_size=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion = area_size*0.0667 if area_unit==4									//reported in plots
replace conversion = area_size*0.404686 if area_unit==5		    						//reported in acres
replace conversion = area_size*0.0001 if area_unit==7									//reported in square meters

replace conversion = area_size*0.00012 if area_unit==1 & zone==1						//reported in heaps
replace conversion = area_size*0.00016 if area_unit==1 & zone==2
replace conversion = area_size*0.00011 if area_unit==1 & zone==3
replace conversion = area_size*0.00019 if area_unit==1 & zone==4
replace conversion = area_size*0.00021 if area_unit==1 & zone==5
replace conversion = area_size*0.00012 if area_unit==1 & zone==6

replace conversion = area_size*0.0027 if area_unit==2 & zone==1							//reported in ridges
replace conversion = area_size*0.004 if area_unit==2 & zone==2
replace conversion = area_size*0.00494 if area_unit==2 & zone==3
replace conversion = area_size*0.0023 if area_unit==2 & zone==4
replace conversion = area_size*0.0023 if area_unit==2 & zone==5
replace conversion = area_size*0.00001 if area_unit==2 & zone==6

replace conversion = area_size*0.00006 if area_unit==3 & zone==1						//reported in stands
replace conversion = area_size*0.00016 if area_unit==3 & zone==2
replace conversion = area_size*0.00004 if area_unit==3 & zone==3
replace conversion = area_size*0.00004 if area_unit==3 & zone==4
replace conversion = area_size*0.00013 if area_unit==3 & zone==5
replace conversion = area_size*0.00041 if area_unit==3 & zone==6

drop area_size
save "${Nigeria_GHS_W2_created_data}\land_cf.dta", replace

 
 
 
 
 
 
 *************** Plot Size **********************

use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Agriculture\sect11a1_plantingw2",clear  
*merging in planting section to get cultivated status

merge 1:1 hhid plotid using  "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Agriculture\sect11b1_plantingw2"
*merging in harvest section to get areas for new plots
merge 1:1 hhid plotid using "${Nigeria_GHS_W2_raw_data}\Post Harvest Wave 2\Agriculture\secta1_harvestw2.dta", gen(plot_merge)


ren s11aq4a area_size
ren s11aq4b area_unit
ren sa1q9a area_size2
ren sa1q9b area_unit2
ren s11aq4c area_meas_sqm
ren sa1q9c area_meas_sqm2
gen cultivate = s11b1q27 ==1 
*assuming new plots are cultivated
replace cultivate = 1 if sa1q3==1

******Merging data with the conversion factor
merge m:1 zone area_unit using "${Nigeria_GHS_W2_created_data}\land_cf.dta", nogen keep(1 3) 


gen field_size= area_size*conversion
*replacing farmer reported with GPS if available
replace field_size = area_meas_sqm*0.0001 if area_meas_sqm!=.               				
gen gps_meas = (area_meas_sqm!=. | area_meas_sqm2!=.)
la var gps_meas "Plot was measured with GPS, 1=Yes"
 
 
 ***************Measurement in hectares for the additional plots from post-harvest************
 *farmer reported field size for post-harvest added fields
drop area_unit conversion
ren area_unit2 area_unit
******Merging data with the conversion factor
merge m:1 zone area_unit using "${Nigeria_GHS_W2_created_data}\land_cf.dta", nogen keep(1 3) 


replace field_size= area_size2*conversion if field_size==.
*replacing farmer reported with GPS if available
replace field_size = area_meas_sqm2*0.0001 if area_meas_sqm2!=.                
la var field_size "Area of plot (ha)"
ren plotid plot_id
sum field_size, detail
*Total land holding including cultivated and rented out
collapse (sum) field_size, by (hhid)
sort hhid
ren field_size land_holding_2012
label var land_holding_2012 "land holding in hectares"
save "${Nigeria_GHS_W2_created_data}\land_holding_2012.dta", replace

 






************************* Merging Agricultural Datasets ********************

use "${Nigeria_GHS_W2_created_data}\purchased_fert_2012.dta", replace


*******All observations Merged*****


merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\subsidized_fert_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\savings_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\credit_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\extension_visit_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\demographics_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\labor_age_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\safety_net_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\food_prices_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\asset_value_2012.dta", nogen

merge 1:1 hhid using "${Nigeria_GHS_W2_created_data}\land_holding_2012.dta"

save "${Nigeria_GHS_W2_created_data}\Nigeria_wave2_complete_data.dta.dta", replace


