










clear



global tza_GHS_W2_raw_data 		"C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\TZA_2010_NPS-R2_v02_M_STATA8"
global tza_GHS_W2_created_data  "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2010"


********************************
*Subsidized Fertilizer 
********************************

use "${tza_GHS_W2_raw_data }\AG_SEC3A.dta",clear 

merge 1:1 y2_hhid plotnum using "${tza_GHS_W2_raw_data }\AG_SEC3B.dta"

ren y2_hhid HHID
****************
*organic fert variables
****************
*ag3a_40  ag3b_40 qty of organic fert
*ag3a_41 ag3b_41 1= if organic fert was purchased
*ag3a_42 ag3b_42 qty of purchased org fert
*ag3a_43 ag3b_43 value of purchased org fert
* ag3a_44_1 ag3b_44_1 institution where they bought org fert

****************
*inorganic fert variables
****************
*ag3a_46 ag3b_45 1= if used inorganic fert1
*ag3a_47 ag3b_47 qty of inorganic fert1
*ag3a_48 ag3b_48 1= get a voucher(subsidy) for fert1
*ag3a_49 ag3b_49 total value of inorganic fert1
*ag3a_51_1 ag3b_51_1 institution where they bought inorg fert1
***********
*other inorganic fert
***********
*ag3b_52 1=if used other inorganic fert
*ag3b_54 qty of inorganic fert2
*ag3b_55 1= get a voucher(subsidy) for fert2
*ag3b_56 total value of inorganic fert2
*ag3b_57_1 institution where they bought inorg fert2

*************Getting Subsidized quantity and Dummy Variable *******************

gen subsidy_qty1 = ag3a_47 if ag3a_48 ==1
tab subsidy_qty1
gen subsidy_qty2 = ag3b_47 if ag3b_48 ==1
tab subsidy_qty2
gen subsidy_qty3 = ag3b_54 if ag3b_55==1
tab subsidy_qty3

egen subsidy_qty_2010 = rowtotal(subsidy_qty1 subsidy_qty2 subsidy_qty3)
*br subsidy_qty1 subsidy_qty2 subsidy_qty3 subsidy_qty_2010
tab subsidy_qty_2010
replace subsidy_qty_2010 = 0 if subsidy_qty_2010 ==.
tab subsidy_qty_2010,missing


gen subsidy_dummy_2010 = 1 if ag3a_48==1 | ag3b_48==1 | ag3b_55==1
tab subsidy_dummy_2010
*br ag3a_48 ag3b_48 ag3b_55 subsidy_dummy_2010 if ag3b_48==1 
replace subsidy_dummy_2010=0 if subsidy_dummy_2010==.
tab subsidy_dummy_2010,missing




collapse (sum)subsidy_qty_2010 (max) subsidy_dummy_2010, by (HHID)
label var subsidy_qty_2010 "Quantity of Fertilizer Purchased with voucher in kg"
label var subsidy_dummy_2010 "=1 if acquired any fertilizer using voucher"
save "${tza_GHS_W2_created_data}\subsidized_fert_2010.dta", replace















*********************************************** 
*Purchased Fertilizer
***********************************************


use "${tza_GHS_W2_raw_data }\AG_SEC3A.dta",clear 

merge 1:1 y2_hhid plotnum using "${tza_GHS_W2_raw_data }\AG_SEC3B.dta"

ren y2_hhid HHID



****************
*inorganic fert variables
****************
*ag3a_46 ag3b_45 1= if used inorganic fert1
*ag3a_47 ag3b_47 qty of inorganic fert1
*ag3a_48 ag3b_48 1= get a voucher(subsidy) for fert1
*ag3a_49 ag3b_49 total value of inorganic fert1
*ag3a_51_1 ag3b_51_1 institution where they bought inorg fert1
***********
*other inorganic fert
***********
*ag3b_52 1=if used other inorganic fert
*ag3b_54 qty of inorganic fert2
*ag3b_55 1= get a voucher(subsidy) for fert2
*ag3b_56 total value of inorganic fert2
*ag3b_57_1 institution where they bought inorg fert2

*ag3a_02_3  distance from plot to market in km

gen dist_2010 = ag3a_02_3 
tab dist_2010,missing
egen med_dist = median (dist)
replace dist_2010 = med_dist if dist_2010==.
tab dist_2010,missing
sum dist_2010,detail




***fertilzer total quantity, total value & total price****

gen com_fert1_qty = ag3a_47 if ag3a_48 ==2
tab com_fert1_qty
gen com_fert2_qty = ag3b_47 if ag3b_48 ==2
tab com_fert2_qty
gen com_fert3_qty = ag3b_54 if ag3b_55==2
tab com_fert3_qty

gen com_fert1_val = ag3a_49 if ag3a_48 ==2
tab com_fert1_val
gen com_fert2_val = ag3b_49 if ag3b_48 ==2
tab com_fert2_val
gen com_fert3_val = ag3b_56 if ag3b_55==2
tab com_fert3_val

*br com_fert1_qty com_fert1_val ag3a_48 com_fert2_qty com_fert2_val ag3b_48 com_fert3_qty com_fert3_val ag3b_55    

egen total_qty_2010 = rowtotal(com_fert1_qty com_fert2_qty com_fert3_qty)
tab  total_qty_2010, missing

egen total_valuefert_2010 = rowtotal(com_fert1_val com_fert2_val com_fert3_val)
tab total_valuefert_2010,missing

gen tpricefert_2010 = total_valuefert_2010/total_qty_2010
tab tpricefert_2010


gen tpricefert_cens_2010 = tpricefert_2010
replace tpricefert_cens_2010 = 2000 if tpricefert_cens_2010 > 2000 & tpricefert_cens_2010 < .
replace tpricefert_cens_2010 = 380 if tpricefert_cens_2010 < 380
tab tpricefert_cens_2010, missing





egen medianfert_pr_plot = median(tpricefert_cens_2010), by (plotnum)

*egen medianfert_pr_hhid  = median(tpricefert_cens_2010), by (HHID )

egen num_fert_pr_plot = count(tpricefert_cens_2010), by (plotnum)

*egen num_fert_pr_hhid  = count(tpricefert_cens_2010), by (HHID )




tab medianfert_pr_plot
*tab medianfert_pr_hhid



tab num_fert_pr_plot
*tab num_fert_pr_hhid


gen tpricefert_cens_mrk_2010 = tpricefert_cens_2010

replace tpricefert_cens_mrk_2010 = medianfert_pr_plot if tpricefert_cens_mrk_2010 ==.

tab tpricefert_cens_mrk_2010,missing

*replace tpricefert_cens_mrk_2010 = medianfert_pr_hhid if tpricefert_cens_mrk_2010 ==. 

*tab tpricefert_cens_mrk_2010,missing
egen median = median(tpricefert_cens_2010)
replace tpricefert_cens_mrk_2010 =  median if tpricefert_cens_mrk_2010 ==.
tab tpricefert_cens_mrk_2010,missing









collapse (sum) dist_2010 total_qty_2010 total_valuefert_2010 (max) tpricefert_cens_mrk_2010, by(HHID)
la var dist_2010 "Distance from plot to market in km"
label var total_qty_2010 "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert_2010 "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk_2010 "price of commercial fertilizer purchased in naira"
sort HHID
save "${tza_GHS_W2_created_data}\commercial_fert_2010.dta", replace




************************************************
*Savings 
************************************************


use "${tza_GHS_W2_raw_data}\HH_SEC_Q.dta",clear 
ren y2_hhid HHID

*hh_q18   1=having a bank account
*hh_q01_1 1= uses m-pesa financial service
*hh_q01_2 1= uses z-pesa financial service
*hh_q01_3 1= uses zap financial service
*hh_q03_6 1=save for emergencies
*hh_q03_7 1= save for other everyday expenses
*hh_q03_8 1= save for unusually large expenses


gen formal_bank_2010 =1 if hh_q18==1
tab formal_bank_2010, missing
replace formal_bank_2010 =0 if formal_bank_2010 ==. 
tab formal_bank_2010,nolabel
tab formal_bank_2010,missing

gen fin_service = 1 if hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1
replace fin_service =0 if fin_service ==.
tab fin_service


gen formal_save_2010 =1 if fin_service==1 & hh_q03_6==1 | hh_q03_7==1 | hh_q03_8==1
 tab formal_save_2010, missing
 replace formal_save_2010 =0 if formal_save_2010 ==.
 tab formal_save_2010, missing



 collapse (max) formal_bank_2010 formal_save_2010, by (HHID)
 la var formal_bank_2010 "=1 if respondent have an account in bank"
 la var formal_save_2010 "=1 if used formal saving group"
 *la var informal_save_2018 "=1 if used informal saving group"
save "${tza_GHS_W2_created_data}\savings_2010.dta", replace



*******************************************************
*Credit access 
*******************************************************

use "${tza_GHS_W2_raw_data}\HH_SEC_P.dta",clear 
ren y2_hhid HHID
*hh_p06 value of borrowed credit
*hh_p03 source of credit (formal <=5)(informal >5)
tab hh_p06
tab hh_p03
tab hh_p03,nolabel
 gen formal_credit_2010 =1 if hh_p06!=. & hh_p03 <=5 
 tab formal_credit_2010,missing
 replace formal_credit_2010 =0 if formal_credit_2010 ==.
 tab formal_credit_2010,missing
 

 
 gen informal_credit_2010 =1 if hh_p06!=. & hh_p03 >5 
 tab informal_credit_2010,missing
replace informal_credit_2010 =0 if informal_credit_2010 ==.
 tab informal_credit_2010,missing


 collapse (max) formal_credit_2010 informal_credit_2010, by (HHID)
 la var formal_credit_2010 "=1 if borrowed from formal credit group"
 la var informal_credit_2010 "=1 if borrowed from informal credit group"
save "${tza_GHS_W2_created_data}\credit_access_2010.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${tza_GHS_W2_raw_data}\AG_SEC12B.dta",clear 
ren y2_hhid HHID
ren ag12b_07 ext_acess_2010

tab ext_acess_2010, missing
tab ext_acess_2010, nolabel

replace ext_acess_2010 = 0 if ext_acess_2010==2 | ext_acess_2010==.
tab ext_acess_2010, missing
collapse (max) ext_acess_2010, by (HHID)
la var ext_acess_2010 "=1 if received advise from extension services"
save "${tza_GHS_W2_created_data}\Extension_access_2010.dta", replace




*********************************
*Demographics 
*********************************



use "${tza_GHS_W2_raw_data}\HH_SEC_B.dta",clear 


merge 1:1 y2_hhid indidy2 using "${tza_GHS_W2_raw_data}\HH_SEC_C.dta"
ren y2_hhid HHID
*hh_b02 sex 
*hh_b05 relationshiop to head
*hh_b04 age (years)


sort HHID indidy2 
 
gen num_mem_2010 = 1


******** female head****

gen femhead_2010 = 0
replace femhead_2010 = 1 if hh_b02== 2 & hh_b05==1
tab femhead_2010,missing

********Age of HHead***********
ren hh_b04 hh_age
gen hh_headage_2010 = hh_age if hh_b05==1

tab hh_headage_2010

replace hh_headage_2010 = 90 if hh_headage_2010 > 90 & hh_headage_2010 < .
tab hh_headage_2010
tab hh_headage_2010, missing


************generating the median age**************


ren hhid_2008 occ
egen median_headage_occ   = median(hh_headage_2010), by (occ )
egen median_headage_indidy2  = median(hh_headage_2010), by (indidy2 )
*egen median_headage_qx_type = median(hh_headage_2010), by (qx_type)


egen num_headage_occ   = count(hh_headage_2010), by (occ  )
egen num_headage_indidy2  = count(hh_headage_2010), by (indidy2 )
*egen num_headage_qx_type = count(hh_headage_2010), by (qx_type)

tab median_headage_occ 
tab median_headage_indidy2
*tab median_headage_qx_type



tab num_headage_occ 
tab num_headage_indidy2
*tab num_headage_qx_type



gen hh_headage_mrk_2010 = hh_headage_2010

replace hh_headage_mrk_2010 = median_headage_occ if hh_headage_mrk_2010 ==. 

tab hh_headage_mrk_2010,missing
*replace hh_headage_mrk_2010 = median_headage_indidy2 if hh_headage_mrk_2010 ==. & num_headage_indidy2 >= 1385

*tab hh_headage_mrk_2010,missing

*replace hh_headage_mrk_2010 = median_headage_qx_type if hh_headage_mrk_2010 ==. & num_headage_qx_type >= 1385

*tab hh_headage_mrk_2010,missing

egen median = median(hh_headage_mrk_2010)
replace hh_headage_mrk_2010 =  median if hh_headage_mrk_2010 ==.
tab hh_headage_mrk_2010,missing


********************Education****************************************************
*hh_c03 1= if attend_school
*hh_c07 highest_education qualification
*hh_b05 relationshiop to head


ren  hh_c03 attend_sch_2010
tab attend_sch_2010
replace attend_sch_2010 = 0 if attend_sch_2010 ==2
tab attend_sch_2010, nolabel


replace hh_c07= 0 if attend_sch_2010==0
tab hh_c07
tab hh_b05 if _merge==1



 label list hh_c07
tab hh_c07 if hh_b05==1,missing
replace hh_c07 = 1 if hh_c07==. &  hh_b05==1
tab hh_c07 if hh_b05==1,missing
replace hh_c07 = 1 if hh_c07==0 &  hh_b05==1
tab hh_c07 if hh_b05==1,missing
*** Education Dummy Variable*****
 label list hh_c07

gen pry_edu_2010 = 1 if hh_c07 < 18 & hh_b05==1
tab pry_edu_2010,missing
gen finish_pry_2010 = 1 if hh_c07 >= 18 & hh_c07 < 32 & hh_b05==1
tab finish_pry_2010,missing
gen finish_sec_2010 = 1 if hh_c07 >= 32 & hh_b05==1
tab finish_sec_2010,missing

replace pry_edu_2010 =0 if pry_edu_2010==. & hh_b05==1
replace finish_pry_2010 =0 if finish_pry_2010==. & hh_b05==1
replace finish_sec_2010 =0 if finish_sec_2010==. & hh_b05==1
tab pry_edu_2010 if hh_b05==1 , missing
tab finish_pry_2010 if hh_b05==1 , missing 
tab finish_sec_2010 if hh_b05==1 , missing

collapse (sum) num_mem_2010 (max) hh_headage_mrk_2010 femhead_2010 attend_sch_2010 pry_edu_2010 finish_pry_2010 finish_sec_2010, by (HHID)
la var num_mem_2010 "household size"
la var femhead_2010 "=1 if head is female"
la var hh_headage_mrk_2010 "age of household head in years"
la var attend_sch_2010 "=1 if respondent attended school"
la var pry_edu_2010 "=1 if household head attended pry school"
la var finish_pry_2010 "=1 if household head finished pry school"
la var finish_sec_2010 "=1 if household head finished sec school"
save "${tza_GHS_W2_created_data}\demographics_2010.dta", replace

********************************* 
*Labor Age 
*********************************

use "${tza_GHS_W2_raw_data}\HH_SEC_B.dta",clear 

ren y2_hhid HHID
ren hh_b04 hh_age

gen worker_2010 = 1
replace worker_2010 = 0 if hh_age < 15 | hh_age > 65

tab worker_2010,missing
sort HHID
collapse (sum) worker_2010, by (HHID)
la var worker_2010 "number of members age 15 and older and less than 65"
sort HHID

save "${tza_GHS_W2_created_data}\labor_age_2010.dta", replace


********************************
*Safety Net
********************************

use "${tza_GHS_W2_raw_data}\HH_SEC_O1.dta",clear 
ren y2_hhid HHID
*hh_o01_3 received assistance
gen safety_net_2010 =1 if hh_o01_3==1 
tab safety_net_2010,missing
replace safety_net_2010 =0 if safety_net_2010==.
tab safety_net_2010,missing
collapse (max) safety_net_2010, by (HHID)
tab safety_net_2010
la var safety_net_2010 "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${tza_GHS_W2_created_data}\safety_net_2010.dta", replace


**************************************
*Food Prices
**************************************
use "${tza_GHS_W2_raw_data}\HH_SEC_K1.dta",clear 
ren y2_hhid HHID
*hh_k03_2   qty purchased by household (7days)
*hh_k03_1    units purchased by household (7days)
*hh_k04    cost of purchase by household (7days)




*********Getting the price for maize only**************

//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//19.millitre       0.001
//9. pieces	        0.35

gen conversion =1
replace conversion=1 if hh_k03_1==1 | hh_k03_1 ==3
gen food_size=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion = food_size*0.001 if hh_k03_1==2 |hh_k03_1==4 
replace conversion = food_size*0.35 if hh_k03_1==5
			
tab conversion, missing

label list itemcode

gen food_price_maize = hh_k03_2* conversion if itemcode==104

gen maize_price_2010 = hh_k04/food_price_maize if itemcode==104

*br hh_k03_1 conversion hh_k03_2 hh_k04 food_price_maize maize_price_2010 itemcode if itemcode<=500

sum maize_price_2010,detail
tab maize_price_2010

*replace maize_price_2010 = 600 if maize_price_2010 >600 & maize_price_2010<.
*replace maize_price_2010 = 50 if maize_price_2010< 50
tab maize_price_2010,missing

*ren interview_status occ
egen medianfert_pr_itemcode = median(maize_price_2010), by (itemcode)
*egen medianfert_pr_qx_type  = median(maize_price_2010), by (qx_type )


egen num_fert_pr_itemcode = count(maize_price_2010), by (itemcode)
*egen num_fert_pr_qx_type = count(maize_price_2010), by (qx_type )


tab medianfert_pr_itemcode
*tab medianfert_pr_qx_type



tab num_fert_pr_itemcode
*tab num_fert_pr_qx_type


gen maize_price_mr_2010 = maize_price_2010

replace maize_price_mr_2010 = medianfert_pr_itemcode if maize_price_mr_2010==. 
tab maize_price_mr_2010,missing

egen mid_maize = median(maize_price_mr_2010)
replace maize_price_mr_2010= mid_maize if maize_price_mr_2010==.
tab maize_price_mr_2010
*replace maize_price_mr_2010 = medianfert_pr_qx_type if maize_price_mr_2010==. 
*tab maize_price_mr_2010,missing



*********Getting the price for rice only**************

//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//19.millitre       0.001
//9. pieces	        0.35



gen food_price_rice = hh_k03_2* conversion if itemcode==101

gen rice_price_2010 = hh_k04/food_price_rice if itemcode==101

*br hh_k03_1 conversion hh_k03_2 hh_k04 food_price_rice rice_price_2019 itemcode if itemcode<=500

sum rice_price_2010,detail
tab rice_price_2010

*replace rice_price_2010 = 1000 if rice_price_2010 >1000 & rice_price_2010<.
*replace rice_price_2010 = 25 if rice_price_2010< 25
*tab rice_price_2010,missing


egen median_pr_itemcode = median(rice_price_2010), by (itemcode)
*egen median_pr_qx_type  = median(rice_price_2010), by (qx_type )



egen num_pr_itemcode = count(rice_price_2010), by (itemcode)
*egen num_pr_qx_type = count(rice_price_2010), by (qx_type )



tab median_pr_itemcode



tab num_pr_itemcode
*tab num_pr_qx_type

gen rice_price_mr_2010 = rice_price_2010

replace rice_price_mr_2010 = median_pr_itemcode if rice_price_mr_2010==. 
tab rice_price_mr_2010,missing
*replace rice_price_mr_2010 = median_pr_qx_type if rice_price_mr_2010==. 
*tab rice_price_mr_2010,missing
egen mid_rice = median(rice_price_mr_2010)
replace rice_price_mr_2010= mid_rice if rice_price_mr_2010==.
tab rice_price_mr_2010

collapse  (max) maize_price_mr_2010 rice_price_mr_2010, by(HHID)
label var maize_price_mr_2010 "commercial price of maize in naira"
label var rice_price_mr_2010 "commercial price of rice in naira"
sort HHID
save "${tza_GHS_W2_created_data}\food_prices_2010.dta", replace






*****************************
*Household Assests
****************************


use "${tza_GHS_W2_raw_data}\AG_SEC11.dta",clear 
ren y2_hhid HHID
*ag11_01 qty of items
*ag11_02 scrap value of items

gen hhasset_value_2010 = ag11_01*ag11_02
tab hhasset_value_2010,missing
sum hhasset_value_2010,detail
replace hhasset_value_2010 = 1440000  if hhasset_value_2010 > 1440000  & hhasset_value_2010 <.
replace hhasset_value_2010 = 2000 if hhasset_value_2010 <2000
tab hhasset_value_2010

************generating the mean vakue**************
*ren  interview_status occ
egen mean_val_itemcode  = mean(hhasset_value_2010), by (itemcode )
*egen mean_val_HHID = mean(hhasset_value_2010), by (HHID)


egen num_val_itemcode  = count(hhasset_value_2010), by (itemcode )
*egen num_val_HHID = count(hhasset_value_2010), by (HHID)




tab mean_val_itemcode
*tab mean_val_HHID



tab num_val_itemcode
*tab num_val_HHID




*replace hhasset_value_2010 = mean_val_HHID if hhasset_value_2010 ==. & mean_val_HHID >= 7

*tab hhasset_value_2010,missing

replace hhasset_value_2010 = mean_val_itemcode if hhasset_value_2010 ==. 

tab hhasset_value_2010,missing




collapse (sum) hhasset_value_2010, by (HHID)

la var hhasset_value_2010 "total value of household asset"
save "${tza_GHS_W2_created_data}\hhasset_value_2010.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************

use "${tza_GHS_W2_raw_data}\AG_SEC2A.dta",clear 
append using "${tza_GHS_W2_raw_data}\AG_SEC2B.dta", gen(short)
ren plotnum plot_id
gen area_acres_est = ag2a_04
replace area_acres_est = ag2b_15 if area_acres_est==.
gen area_acres_meas = ag2a_09
replace area_acres_meas = ag2b_20 if area_acres_meas==.
*keep if area_acres_est !=.
*keep y2_hhid plot_id area_acres_est area_acres_meas


lab var area_acres_meas "Plot are in acres (GPSd)"
lab var area_acres_est "Plot area in acres (estimated)"
gen area_est_hectares=area_acres_est* (1/2.47105)  
gen area_meas_hectares= area_acres_meas* (1/2.47105)


ren y2_hhid HHID
collapse (sum) area_est_hectares area_meas_hectares , by (HHID)
sort HHID
ren area_est_hectares land_holding_est_2010
ren area_meas_hectares land_holding_meas_2010
label var land_holding_est_2010 "land holding estimated in hectares"
label var land_holding_meas_2010 "land holding measured using gps in hectares"
save "${tza_GHS_W2_created_data}\land_holding_2010.dta", replace















************************* Merging Agricultural Datasets ********************

use "${tza_GHS_W2_created_data}\commercial_fert_2010.dta", replace


*******All observations Merged*****

merge 1:1 HHID using "${tza_GHS_W2_created_data}\subsidized_fert_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\savings_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\credit_access_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\Extension_access_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\demographics_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\labor_age_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\safety_net_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\food_prices_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\hhasset_value_2010.dta", nogen

merge 1:1 HHID using "${tza_GHS_W2_created_data}\land_holding_2010.dta"

save "${tza_GHS_W2_created_data}\tanzania_wave2_completedata_2010.dta", replace

