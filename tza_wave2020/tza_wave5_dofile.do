










clear



global tza_GHS_W5_raw_data 		"C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\TZA_2020_NPS-R5_v02_M_STATA14"
global tza_GHS_W5_created_data  "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2020"













*********************************************** 
*Purchased Fertilizer
***********************************************

use "${tza_GHS_W5_raw_data }\ag_sec_3a.dta",clear 

merge 1:1 y5_hhid plot_id using "${tza_GHS_W5_raw_data}\ag_sec_3b.dta"

ren y5_hhid HHID
****************
*organic fert variables
****************
*ag3a_41  ag3b_41 1= if organic fert was purchased
*ag3a_42  ag3b_42 qty of organic fert
*ag3a_43 ag3b_43  1= if org fertilizer was purchsed
*ag3a_44 ag3b_44 qty of purchased org fert
*ag3a_45 ag3b_45 value of purchased org fert
* ag3a_46_1 ag3b_46_1 institution where they bought org fert

****************
*inorganic fert variables
****************
*ag3a_47   ag3b_47  1= if used inorganic fert1
*ag3a_49   ag3b_49 qty of inorganic fert1

*ag3a_51   ag3b_51 total value of inorganic fert1
*ag3a_53_1   ag3b_53_1 institution where they bought inorg fert1
***********
*other inorganic fert
***********
*ag3a_54 ag3b_54   1=if used other inorganic fert
*ag3a_56 ag3b_56   qty of inorganic fert2

*ag3a_58 ag3b_58   total value of inorganic fert2
*ag3a_59_1 ag3b_59_1  institution where they bought inorg fert2



*ag3a_02_3  distance from plot to market in km

gen dist_2020 = ag3a_02_3 
tab dist_2020,missing

egen dist_median = median(dist_2020)

replace dist_2020 = dist_median if dist_2020 ==. 

tab dist_2020,missing
sum dist_2020,detail


***fertilzer total quantity, total value & total price****

gen com_fert1_qty = ag3a_49 
tab com_fert1_qty
gen com_fert2_qty = ag3b_49 
tab com_fert2_qty
gen com_fert3_qty = ag3a_56
tab com_fert3_qty
gen com_fert4_qty = ag3b_56 
tab com_fert4_qty

gen com_fert1_val = ag3a_51 
tab com_fert1_val
gen com_fert2_val = ag3b_51 
tab com_fert2_val
gen com_fert3_val = ag3a_58
tab com_fert3_val
gen com_fert4_val = ag3b_58 
tab com_fert4_val


egen total_qty_2020 = rowtotal(com_fert1_qty com_fert2_qty com_fert3_qty com_fert4_qty)
tab  total_qty_2020, missing

egen total_valuefert_2020 = rowtotal(com_fert1_val com_fert2_val com_fert3_val com_fert4_val)
tab total_valuefert_2020,missing

gen tpricefert_2020 = total_valuefert_2020/total_qty_2020
tab tpricefert_2020


gen tpricefert_cens_2020 = tpricefert_2020
replace tpricefert_cens_2020 = 2750 if tpricefert_cens_2020 > 2750 & tpricefert_cens_2020 < .  //bottom 5%
replace tpricefert_cens_2020 = 600 if tpricefert_cens_2020 < 600 //top 5%
tab tpricefert_cens_2020, missing



ren interview__key occ


egen medianfert_pr_occ = median(tpricefert_cens_2020), by (occ)

egen medianfert_pr_plot_id  = median(tpricefert_cens_2020), by (plot_id )

egen num_fert_pr_occ = count(tpricefert_cens_2020), by (occ)

egen num_fert_pr_plot_id  = count(tpricefert_cens_2020), by (plot_id )




tab medianfert_pr_occ
tab medianfert_pr_plot_id



tab num_fert_pr_occ
tab num_fert_pr_plot_id


gen tpricefert_cens_mrk_2020 = tpricefert_cens_2020

replace tpricefert_cens_mrk_2020 = medianfert_pr_occ if tpricefert_cens_mrk_2020 ==. 

tab tpricefert_cens_mrk_2020,missing

replace tpricefert_cens_mrk_2020 = medianfert_pr_plot_id if tpricefert_cens_mrk_2020 ==. 

tab tpricefert_cens_mrk_2020,missing

egen median = median(tpricefert_cens_mrk_2020)
replace tpricefert_cens_mrk_2020 =  median if tpricefert_cens_mrk_2020 ==.
tab tpricefert_cens_mrk_2020,missing









collapse (sum) dist_2020 total_qty_2020 total_valuefert_2020 (max) tpricefert_cens_mrk_2020, by(HHID)
la var dist_2020 "Distance travelled from plot to market in km"
label var total_qty_2020 "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert_2020 "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk_2020 "price of commercial fertilizer purchased in naira"
sort HHID
save "${tza_GHS_W5_created_data}\commercial_fert_2020.dta", replace




************************************************
*Savings 
************************************************


use "${tza_GHS_W5_raw_data}\hh_sec_q1.dta",clear 
ren y5_hhid HHID

* hh_q10   1=having a bank account
*hh_q01_1 1= uses m-pesa financial service
*hh_q01_2 1= uses z-pesa financial service
*hh_q01_3 1= uses Airtel(zap) financial service
*hh_q01_4 1= uses Tigo pesa financial service
*hh_q01_5 1= uses T pesa financial service
*hh_q01_6 1= uses Hallo pesa financial service
*hh_q03_6 1=save for emergencies
*hh_q03_7 1= save for other everyday expenses
*hh_q03_8 1= save for unusually large expenses


gen formal_bank_2020=1 if hh_q10==1
tab formal_bank_2020, missing
replace formal_bank_2020 =0 if formal_bank_2020 ==. 
tab formal_bank_2020,nolabel
tab formal_bank_2020,missing

gen fin_service = 1 if hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1 | hh_q01_4==1 | hh_q01_5==1 | hh_q01_6==1
replace fin_service =0 if fin_service ==.
tab fin_service


gen formal_save_2020 =1 if fin_service==1 & hh_q03_6==1 | hh_q03_7==1 | hh_q03_8==1
 tab formal_save_2020, missing
 replace formal_save_2020 =0 if formal_save_2020 ==.
 tab formal_save_2020, missing



 collapse (max) formal_bank_2020 formal_save_2020, by (HHID)
 la var formal_bank_2020 "=1 if respondent have an account in bank"
 la var formal_save_2020 "=1 if used formal saving group"
 *la var informal_save_2018 "=1 if used informal saving group"
save "${tza_GHS_W5_created_data}\savings_2020.dta", replace



*******************************************************
*Credit access 
*******************************************************

use "${tza_GHS_W5_raw_data}\hh_sec_p.dta",clear 
ren y5_hhid HHID
*hh_p06 value of borrowed credit
*hh_p03 source of credit (formal <=5)(informal >5)
tab hh_p06
tab hh_p03
tab hh_p03,nolabel
 gen formal_credit_2020 =1 if hh_p06!=. & hh_p03 <=5 
 tab formal_credit_2020,missing
 replace formal_credit_2020 =0 if formal_credit_2020 ==.
 tab formal_credit_2020,missing
 

 
 gen informal_credit_2020 =1 if hh_p06!=. & hh_p03 >5 
 tab informal_credit_2020,missing
replace informal_credit_2020 =0 if informal_credit_2020 ==.
 tab informal_credit_2020,missing


 collapse (max) formal_credit_2020 informal_credit_2020, by (HHID)
 la var formal_credit_2020 "=1 if borrowed from formal credit group"
 la var informal_credit_2020 "=1 if borrowed from informal credit group"
save "${tza_GHS_W5_created_data}\credit_access_2020.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${tza_GHS_W5_raw_data}\ag_sec_12b.dta",clear 
ren y5_hhid HHID
ren ag12b_08 ext_acess_2020

tab ext_acess_2020, missing
tab ext_acess_2020, nolabel

replace ext_acess_2020 = 0 if ext_acess_2020==2 | ext_acess_2020==.
tab ext_acess_2020, missing
collapse (max) ext_acess_2020, by (HHID)
la var ext_acess_2020 "=1 if received advise from extension services"
save "${tza_GHS_W5_created_data}\Extension_access_2020.dta", replace




*********************************
*Demographics 
*********************************



use "${tza_GHS_W5_raw_data}\hh_sec_b.dta",clear 


merge 1:1 y5_hhid indidy5 using "${tza_GHS_W5_raw_data}\hh_sec_c.dta"
ren y5_hhid HHID
*hh_b02 sex 
*hh_b05 relationshiop to head
*hh_b04 age (years)


sort HHID indidy5
 
gen num_mem_2020 = 1


******** female head****

gen femhead_2020 = 0
replace femhead_2020 = 1 if hh_b02== 2 & hh_b05==1
tab femhead_2020,missing

********Age of HHead***********
ren hh_b04 hh_age
gen hh_headage_2020 = hh_age if hh_b05==1

tab hh_headage_2020

tab hh_headage_2020, missing


************generating the median age**************


ren y4_hhid indidy4


egen median_headage_indidy4  = median(hh_headage_2020), by (indidy4)
egen num_headage_indidy4  = count(hh_headage_2020), by (indidy4)



tab median_headage_indidy4
tab num_headage_indidy4




gen hh_headage_mrk_2020 = hh_headage_2020

replace hh_headage_mrk_2020 = median_headage_indidy4 if hh_headage_mrk_2020 ==. 

tab hh_headage_mrk_2020,missing




********************Education****************************************************
*hh_c03 1= if attend_school
*hh_c07 highest_education qualification
*hh_b05 relationshiop to head


ren  hh_c03 attend_sch_2020
tab attend_sch_2020
replace attend_sch_2020 = 0 if attend_sch_2020 ==2
tab attend_sch_2020, nolabel


replace hh_c07= 0 if attend_sch_2020==0
tab hh_c07
tab hh_b05 if _merge==1



 *label list hh_c07
tab hh_c07 if hh_b05==1,missing
replace hh_c07 = 1 if hh_c07==. &  hh_b05==1
tab hh_c07 if hh_b05==1,missing
replace hh_c07 = 1 if hh_c07==0 &  hh_b05==1
tab hh_c07 if hh_b05==1,missing
*** Education Dummy Variable*****
 *label list hh_c07

gen pry_edu_2020 = 1 if hh_c07 < 18 & hh_b05==1
tab pry_edu_2020,missing
gen finish_pry_2020 = 1 if hh_c07 >= 18 & hh_c07 < 32 & hh_b05==1
tab finish_pry_2020,missing
gen finish_sec_2020 = 1 if hh_c07 >= 32 & hh_b05==1
tab finish_sec_2020,missing

replace pry_edu_2020 =0 if pry_edu_2020==. & hh_b05==1
replace finish_pry_2020 =0 if finish_pry_2020==. & hh_b05==1
replace finish_sec_2020 =0 if finish_sec_2020==. & hh_b05==1
tab pry_edu_2020 if hh_b05==1 , missing
tab finish_pry_2020 if hh_b05==1 , missing 
tab finish_sec_2020 if hh_b05==1 , missing

collapse (sum) num_mem_2020 (max) hh_headage_mrk_2020 femhead_2020 attend_sch_2020 pry_edu_2020 finish_pry_2020 finish_sec_2020, by (HHID)
la var num_mem_2020 "household size"
la var femhead_2020 "=1 if head is female"
la var hh_headage_mrk_2020 "age of household head in years"
la var attend_sch_2020 "=1 if respondent attended school"
la var pry_edu_2020 "=1 if household head attended pry school"
la var finish_pry_2020 "=1 if household head finished pry school"
la var finish_sec_2020 "=1 if household head finished sec school"
save "${tza_GHS_W5_created_data}\demographics_2020.dta", replace

********************************* 
*Labor Age 
*********************************

use "${tza_GHS_W5_raw_data}\hh_sec_b.dta",clear 

ren y5_hhid HHID
ren hh_b04 hh_age

gen worker_2020 = 1
replace worker_2020 = 0 if hh_age < 15 | hh_age > 65

tab worker_2020,missing
sort HHID
collapse (sum) worker_2020, by (HHID)
la var worker_2020 "number of members age 15 and older and less than 65"
sort HHID

save "${tza_GHS_W5_created_data}\labor_age_2020.dta", replace


********************************
*Safety Net
********************************

use "${tza_GHS_W5_raw_data}\hh_sec_o1.dta",clear 
ren y5_hhid HHID
*hh_o01 received assistance
gen safety_net_2020 =1 if hh_o01==1 
tab safety_net_2020,missing
replace safety_net_2020 =0 if safety_net_2020==.
tab safety_net_2020,missing
collapse (max) safety_net_2020, by (HHID)
tab safety_net_2020
la var safety_net_2020 "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${tza_GHS_W5_created_data}\safety_net_2020.dta", replace


**************************************
*Food Prices
**************************************
use "${tza_GHS_W5_raw_data}\HH_SEC_J1.dta",clear 
ren y5_hhid HHID
*hh_j03_2   qty purchased by household (7days)
*hh_j03_1    units purchased by household (7days)
*hh_j04    cost of purchase by household (7days)




*********Getting the price for maize only**************

//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//19.millitre       0.001
//9. pieces	        0.35

gen conversion =1
replace conversion=1 if hh_j03_1==1 | hh_j03_1 ==3
gen food_size=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion = food_size*0.001 if hh_j03_1==2 |hh_j03_1==4 
replace conversion = food_size*0.35 if hh_j03_1==5
			
tab conversion, missing

*label list itemcode

gen food_price_maize = hh_j03_2* conversion if itemcode==104

gen maize_price_2020 = hh_j04/food_price_maize if itemcode==104

*br hh_j03_1 conversion hh_j03_2 hh_j04 food_price_maize maize_price_2020 itemcode if itemcode<=500

sum maize_price_2020,detail
tab maize_price_2020

*replace maize_price_2020 = 2000 if maize_price_2020 >2000 & maize_price_2020<.
*replace maize_price_2020 = 50 if maize_price_2020< 50
tab maize_price_2020,missing


egen medianfert_pr_itemcode = median(maize_price_2020), by (itemcode)



egen num_fert_pr_itemcode = count(maize_price_2020), by (itemcode)



tab medianfert_pr_itemcode




tab num_fert_pr_itemcode



gen maize_price_mr_2020 = maize_price_2020


replace maize_price_mr_2020 = medianfert_pr_itemcode if maize_price_mr_2020==. 
tab maize_price_mr_2020,missing

egen mid_maize = median(maize_price_mr_2020)
replace maize_price_mr_2020= mid_maize if maize_price_mr_2020==.
tab maize_price_mr_2020




*********Getting the price for rice only**************

//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//19.millitre       0.001
//9. pieces	        0.35



gen food_price_rice = hh_j03_2* conversion if itemcode==102

gen rice_price_2020 = hh_j04/food_price_rice if itemcode==102

*br hh_j03_1 conversion hh_j03_2 hh_j04 food_price_rice rice_price_2020 itemcode if itemcode<=500

sum rice_price_2020,detail
tab rice_price_2020

*replace rice_price_2020 = 1000 if rice_price_2020 >1000 & rice_price_2020<.
*replace rice_price_2020 = 25 if rice_price_2020< 25
tab rice_price_2020,missing


egen median_pr_itemcode = median(rice_price_2020), by (itemcode)



egen num_pr_itemcode = count(rice_price_2020), by (itemcode)



tab median_pr_itemcode



tab num_pr_itemcode


gen rice_price_mr_2020 = rice_price_2020

replace rice_price_mr_2020 = median_pr_itemcode if rice_price_mr_2020==. 
tab rice_price_mr_2020,missing

egen mid_rice = median(rice_price_mr_2020)
replace rice_price_mr_2020= mid_rice if rice_price_mr_2020==.
tab rice_price_mr_2020

collapse  (max) maize_price_mr_2020 rice_price_mr_2020, by(HHID)
label var maize_price_mr_2020 "commercial price of maize in naira"
label var rice_price_mr_2020 "commercial price of rice in naira"
sort HHID
save "${tza_GHS_W5_created_data}\food_prices_2020.dta", replace







*****************************
*Household Assests
****************************


use "${tza_GHS_W5_raw_data}\hh_sec_m.dta",clear 
ren y5_hhid HHID
*hh_m01 qty of items
*hh_m04 scrap value of items

gen hhasset_value_2020 = hh_m01*hh_m04
tab hhasset_value_2020
sum hhasset_value_2020,detail
replace hhasset_value_2020 = 7200000  if hhasset_value_2020 > 7200000  & hhasset_value_2020 <. //bottom 4%
replace hhasset_value_2020 = 3000 if hhasset_value_2020 <3000   //top 4%
tab hhasset_value_2020,missing

************generating the mean vakue**************
*ren  interview_status occ
egen mean_val_itemcode  = mean(hhasset_value_2020), by (itemcode )

egen num_val_itemcode  = count(hhasset_value_2020), by (itemcode )





tab mean_val_itemcode
tab num_val_itemcode



replace hhasset_value_2020 = mean_val_itemcode if hhasset_value_2020 ==. 

tab hhasset_value_2020,missing



egen mean = mean(hhasset_value_2020)
replace hhasset_value_2020 =  mean if hhasset_value_2020 ==.
tab hhasset_value_2020,missing


collapse (sum) hhasset_value_2020, by (HHID)

la var hhasset_value_2020 "total value of household asset"
save "${tza_GHS_W5_created_data}\hhasset_value_2020.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************

use "${tza_GHS_W5_raw_data}\ag_sec_02.dta",clear

*ren plotnum plot_id
gen area_acres_est = ag2a_04
*replace area_acres_est = ag2b_15 if area_acres_est==.
gen area_acres_meas = ag2a_09
*replace area_acres_meas = ag2b_20 if area_acres_meas==.
*keep if area_acres_est !=.
*keep y2_hhid plot_id area_acres_est area_acres_meas
lab var area_acres_meas "Plot are in acres (GPSd)"
lab var area_acres_est "Plot area in acres (estimated)"
gen area_est_hectares=area_acres_est* (1/2.47105)  
gen area_meas_hectares= area_acres_meas* (1/2.47105)

ren y5_hhid HHID
collapse (sum) area_est_hectares area_meas_hectares , by (HHID)
sort HHID
ren area_est_hectares land_holding_est_2020
ren area_meas_hectares land_holding_meas_2020
label var land_holding_est_2020 "land holding estimated in hectares"
label var land_holding_meas_2020 "land holding measured using gps in hectares"
save "${tza_GHS_W5_created_data}\land_holding_2020.dta", replace





************************* Merging Agricultural Datasets ********************

use "${tza_GHS_W5_created_data}\commercial_fert_2020.dta", replace


*******All observations Merged*****

merge 1:1 HHID using "${tza_GHS_W5_created_data}\savings_2020.dta", nogen

merge 1:1 HHID using "${tza_GHS_W5_created_data}\credit_access_2020.dta", nogen

merge 1:1 HHID using "${tza_GHS_W5_created_data}\Extension_access_2020.dta", nogen

merge 1:1 HHID using "${tza_GHS_W5_created_data}\demographics_2020.dta", nogen

merge 1:1 HHID using "${tza_GHS_W5_created_data}\labor_age_2020.dta", nogen

merge 1:1 HHID using "${tza_GHS_W5_created_data}\safety_net_2020.dta", nogen

merge 1:1 HHID using "${tza_GHS_W5_created_data}\food_prices_2020.dta", nogen

merge 1:1 HHID using "${tza_GHS_W5_created_data}\hhasset_value_2020.dta", nogen

merge 1:1 HHID using "${tza_GHS_W5_created_data}\land_holding_2020.dta"

save "${tza_GHS_W5_created_data}\tanzania_wave5_completedata_2020.dta", replace








*****************Appending all Malawi Datasets*****************
use "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2010\tanzania_wave2_completedata_2010.dta",clear  

append using "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2012\tanzania_wave3_completedata_2012.dta" 

append using "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014\tanzania_wave4_completedata_2014.dta" 

append using "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2020\tanzania_wave5_completedata_2020.dta" 


save "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\complete_files\Tanzania_complete_data.dta", replace






























