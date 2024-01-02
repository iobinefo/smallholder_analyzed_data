










clear



global tza_GHS_W4_raw_data 		"C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\TZA_2014_NPS-R4_v03_M_STATA11"
global tza_GHS_W4_created_data  "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014"


********************************
*Subsidized Fertilizer 
********************************

use "${tza_GHS_W4_raw_data }\ag_sec_3a.dta",clear 

merge 1:1 y4_hhid plotnum using "${tza_GHS_W4_raw_data }\ag_sec_3b.dta"

ren y4_hhid HHID
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
*ag3a_50   ag3b_50 1= get a voucher(subsidy) for fert1
*ag3a_51   ag3b_51 total value of inorganic fert1
*ag3a_53_1   ag3b_53_1 institution where they bought inorg fert1
***********
*other inorganic fert
***********
*ag3a_54 ag3b_54   1=if used other inorganic fert
*ag3a_56 ag3b_56   qty of inorganic fert2
*ag3a_57 ag3b_57   1= get a voucher(subsidy) for fert2
*ag3a_58 ag3b_58   total value of inorganic fert2
*ag3a_59_1 ag3b_59_1  institution where they bought inorg fert2

*************Getting Subsidized quantity and Dummy Variable *******************

gen subsidy_qty1 = ag3a_49 if ag3a_50 ==1
tab subsidy_qty1
gen subsidy_qty2 = ag3b_49 if ag3b_50 ==1
tab subsidy_qty2
gen subsidy_qty3 = ag3a_56 if ag3a_57==1
tab subsidy_qty3
gen subsidy_qty4 = ag3b_56 if ag3b_57==1
tab subsidy_qty4


egen subsidy_qty_2014 = rowtotal(subsidy_qty1 subsidy_qty2 subsidy_qty3 subsidy_qty4)
*br subsidy_qty1 subsidy_qty2 subsidy_qty3 subsidy_qty4 subsidy_qty_2012
tab subsidy_qty_2014



gen subsidy_dummy_2014 = 1 if ag3a_50==1 | ag3b_50==1 | ag3a_57==1 |ag3b_57==1
tab subsidy_dummy_2014
*br ag3a_50 ag3b_50 ag3a_57 ag3b_57 subsidy_dummy_2014 if ag3a_57==1 
replace subsidy_dummy_2014=0 if subsidy_dummy_2014==.
tab subsidy_dummy_2014,missing




collapse (sum)subsidy_qty_2014 (max) subsidy_dummy_2014, by (HHID)
label var subsidy_qty_2014 "Quantity of Fertilizer Purchased with voucher in kg"
label var subsidy_dummy_2014 "=1 if acquired any fertilizer using voucher"
save "${tza_GHS_W4_created_data}\subsidized_fert_2014.dta", replace















*********************************************** 
*Purchased Fertilizer
***********************************************

use "${tza_GHS_W4_raw_data }\ag_sec_3a.dta",clear 

merge 1:1 y4_hhid plotnum using "${tza_GHS_W4_raw_data }\ag_sec_3b.dta"

ren y4_hhid HHID


****************
*inorganic fert variables
****************
*ag3a_47   ag3b_47  1= if used inorganic fert1
*ag3a_49   ag3b_49 qty of inorganic fert1
*ag3a_50   ag3b_50 1= get a voucher(subsidy) for fert1
*ag3a_51   ag3b_51 total value of inorganic fert1
*ag3a_53_1   ag3b_53_1 institution where they bought inorg fert1
***********
*other inorganic fert
***********
*ag3a_54 ag3b_54   1=if used other inorganic fert
*ag3a_56 ag3b_56   qty of inorganic fert2
*ag3a_57 ag3b_57   1= get a voucher(subsidy) for fert2
*ag3a_58 ag3b_58   total value of inorganic fert2
*ag3a_59_1 ag3b_59_1  institution where they bought inorg fert2


*ag3a_02_3  distance from plot to market in km

gen dist_2014 = ag3a_02_3 
tab dist_2014,missing

egen mediandist_pr_occ = median(dist_2014), by (occ)

egen num_dist_pr_occ = count(dist_2014), by (occ)


tab mediandist_pr_occ
tab num_dist_pr_occ



replace dist_2014 = mediandist_pr_occ if dist_2014 ==. 

tab dist_2014,missing
sum dist_2014,detail



***fertilzer total quantity, total value & total price****

gen com_fert1_qty = ag3a_49 if ag3a_50 ==2
tab com_fert1_qty
gen com_fert2_qty = ag3b_49 if ag3b_50 ==2
tab com_fert2_qty
gen com_fert3_qty = ag3a_56 if ag3a_57==2
tab com_fert3_qty
gen com_fert4_qty = ag3b_56 if ag3b_57==2
tab com_fert4_qty

gen com_fert1_val = ag3a_51 if ag3a_50 ==2
tab com_fert1_val
gen com_fert2_val = ag3b_51 if ag3b_50 ==2
tab com_fert2_val
gen com_fert3_val = ag3a_58 if ag3a_57==2
tab com_fert3_val
gen com_fert4_val = ag3b_58 if ag3b_57==2
tab com_fert4_val

*br com_fert1_qty com_fert1_val ag3a_50 com_fert2_qty com_fert2_val ag3b_50 com_fert3_qty com_fert3_val ag3a_57    

egen total_qty_2014 = rowtotal(com_fert1_qty com_fert2_qty com_fert3_qty com_fert4_qty)
tab  total_qty_2014, missing

egen total_valuefert_2014 = rowtotal(com_fert1_val com_fert2_val com_fert3_val com_fert4_val)
tab total_valuefert_2014,missing

gen tpricefert_2014 = total_valuefert_2014/total_qty_2014
tab tpricefert_2014


gen tpricefert_cens_2014 = tpricefert_2014
replace tpricefert_cens_2014 = 2200 if tpricefert_cens_2014 > 2200 & tpricefert_cens_2014 < .
replace tpricefert_cens_2014 = 400 if tpricefert_cens_2014 < 400
tab tpricefert_cens_2014, missing





egen medianfert_pr_occ = median(tpricefert_cens_2014), by (occ)

egen medianfert_pr_plotname  = median(tpricefert_cens_2014), by (plotname )

egen num_fert_pr_occ = count(tpricefert_cens_2014), by (occ)

egen num_fert_pr_plotname  = count(tpricefert_cens_2014), by (plotname )




tab medianfert_pr_occ
tab medianfert_pr_plotname



tab num_fert_pr_occ
tab num_fert_pr_plotname


gen tpricefert_cens_mrk_2014 = tpricefert_cens_2014

replace tpricefert_cens_mrk_2014 = medianfert_pr_occ if tpricefert_cens_mrk_2014 ==. & num_fert_pr_occ>= 129

tab tpricefert_cens_mrk_2014,missing

replace tpricefert_cens_mrk_2014 = medianfert_pr_plotname if tpricefert_cens_mrk_2014 ==. & num_fert_pr_plotname>= 129

tab tpricefert_cens_mrk_2014,missing

*egen median = median(tpricefert_cens_2010)
*replace tpricefert_cens_mrk_2010 =  median if tpricefert_cens_mrk_2010 ==.
*tab tpricefert_cens_mrk_2010,missing









collapse (sum) dist_2014 total_qty_2014 total_valuefert_2014 (max) tpricefert_cens_mrk_2014, by(HHID)
la var dist_2014 "Distance travelled from plot to market in km"
label var total_qty_2014 "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert_2014 "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk_2014 "price of commercial fertilizer purchased in naira"
sort HHID
save "${tza_GHS_W4_created_data}\commercial_fert_2014.dta", replace




************************************************
*Savings 
************************************************


use "${tza_GHS_W4_raw_data}\hh_sec_q1.dta",clear 
ren y4_hhid HHID

* hh_q10   1=having a bank account
*hh_q01_1 1= uses m-pesa financial service
*hh_q01_2 1= uses z-pesa financial service
*hh_q01_3 1= uses Airtel(zap) financial service
*hh_q01_4 1= uses Tigo pesa financial service
*hh_q03_f 1=save for emergencies
*hh_q03_g 1= save for other everyday expenses
*hh_q03_h 1= save for unusually large expenses


gen formal_bank_2014=1 if hh_q10==1
tab formal_bank_2014, missing
replace formal_bank_2014 =0 if formal_bank_2014 ==. 
tab formal_bank_2014,nolabel
tab formal_bank_2014,missing

gen fin_service = 1 if hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1 | hh_q01_4==1
replace fin_service =0 if fin_service ==.
tab fin_service


gen formal_save_2014 =1 if fin_service==1 & hh_q03_f==1 | hh_q03_g==1 | hh_q03_h==1
 tab formal_save_2014, missing
 replace formal_save_2014 =0 if formal_save_2014 ==.
 tab formal_save_2014, missing



 collapse (max) formal_bank_2014 formal_save_2014, by (HHID)
 la var formal_bank_2014 "=1 if respondent have an account in bank"
 la var formal_save_2014 "=1 if used formal saving group"
 *la var informal_save_2018 "=1 if used informal saving group"
save "${tza_GHS_W4_created_data}\savings_2014.dta", replace



*******************************************************
*Credit access 
*******************************************************

use "${tza_GHS_W4_raw_data}\hh_sec_p.dta",clear 
ren y4_hhid HHID
*hh_p06 value of borrowed credit
*hh_p03 source of credit (formal <=5)(informal >5)
tab hh_p06
tab hh_p03
tab hh_p03,nolabel
 gen formal_credit_2014 =1 if hh_p06!=. & hh_p03 <=5 
 tab formal_credit_2014,missing
 replace formal_credit_2014 =0 if formal_credit_2014 ==.
 tab formal_credit_2014,missing
 

 
 gen informal_credit_2014 =1 if hh_p06!=. & hh_p03 >5 
 tab informal_credit_2014,missing
replace informal_credit_2014 =0 if informal_credit_2014 ==.
 tab informal_credit_2014,missing


 collapse (max) formal_credit_2014 informal_credit_2014, by (HHID)
 la var formal_credit_2014 "=1 if borrowed from formal credit group"
 la var informal_credit_2014 "=1 if borrowed from informal credit group"
save "${tza_GHS_W4_created_data}\credit_access_2014.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${tza_GHS_W4_raw_data}\ag_sec_12b.dta",clear 
ren y4_hhid HHID
ren ag12b_08 ext_acess_2014

tab ext_acess_2014, missing
tab ext_acess_2014, nolabel

replace ext_acess_2014 = 0 if ext_acess_2014==2 | ext_acess_2014==.
tab ext_acess_2014, missing
collapse (max) ext_acess_2014, by (HHID)
la var ext_acess_2014 "=1 if received advise from extension services"
save "${tza_GHS_W4_created_data}\Extension_access_2014.dta", replace




*********************************
*Demographics 
*********************************



use "${tza_GHS_W4_raw_data}\hh_sec_b.dta",clear 


merge 1:1 y4_hhid indidy4 using "${tza_GHS_W4_raw_data}\hh_sec_c.dta"
ren y4_hhid HHID
*hh_b02 sex 
*hh_b05 relationshiop to head
*hh_b04 age (years)


sort HHID indidy4
 
gen num_mem_2014 = 1


******** female head****

gen femhead_2014 = 0
replace femhead_2014 = 1 if hh_b02== 2 & hh_b05==1
tab femhead_2014,missing

********Age of HHead***********
ren hh_b04 hh_age
gen hh_headage_2014 = hh_age if hh_b05==1

tab hh_headage_2014

replace hh_headage_2014 = 100 if hh_headage_2014 > 100 & hh_headage_2014 < .
tab hh_headage_2014
tab hh_headage_2014, missing


************generating the median age**************



egen median_headage_occ   = median(hh_headage_2014), by (occ)
egen median_headage_indidy4  = median(hh_headage_2014), by (indidy4)
*egen median_headage_qx_type = median(hh_headage_2014), by (qx_type)


egen num_headage_occ   = count(hh_headage_2014), by (occ)
egen num_headage_indidy4  = count(hh_headage_2014), by (indidy4)
*egen num_headage_qx_type = count(hh_headage_2014), by (qx_type)

tab median_headage_occ 
tab median_headage_indidy4
*tab median_headage_qx_type



tab num_headage_occ 
tab num_headage_indidy4
*tab num_headage_qx_type



gen hh_headage_mrk_2014 = hh_headage_2014

replace hh_headage_mrk_2014 = median_headage_indidy4 if hh_headage_mrk_2014 ==. 

tab hh_headage_mrk_2014,missing

*replace hh_headage_mrk_2012 = median_headage_occ if hh_headage_mrk_2012 ==.

*tab hh_headage_mrk_2012,missing


*replace hh_headage_mrk_2010 = median_headage_qx_type if hh_headage_mrk_2010 ==. & num_headage_qx_type >= 1385

*tab hh_headage_mrk_2010,missing

egen median = median(hh_headage_mrk_2014)
replace hh_headage_mrk_2014 =  median if hh_headage_mrk_2014 ==.
tab hh_headage_mrk_2014,missing


********************Education****************************************************
*hh_c03 1= if attend_school
*hh_c07 highest_education qualification
*hh_b05 relationshiop to head


ren  hh_c03 attend_sch_2014
tab attend_sch_2014
replace attend_sch_2014 = 0 if attend_sch_2014 ==2
tab attend_sch_2014, nolabel


replace hh_c07= 0 if attend_sch_2014==0
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

gen pry_edu_2014 = 1 if hh_c07 < 18 & hh_b05==1
tab pry_edu_2014,missing
gen finish_pry_2014 = 1 if hh_c07 >= 18 & hh_c07 < 32 & hh_b05==1
tab finish_pry_2014,missing
gen finish_sec_2014 = 1 if hh_c07 >= 32 & hh_b05==1
tab finish_sec_2014,missing

replace pry_edu_2014 =0 if pry_edu_2014==. & hh_b05==1
replace finish_pry_2014 =0 if finish_pry_2014==. & hh_b05==1
replace finish_sec_2014 =0 if finish_sec_2014==. & hh_b05==1
tab pry_edu_2014 if hh_b05==1 , missing
tab finish_pry_2014 if hh_b05==1 , missing 
tab finish_sec_2014 if hh_b05==1 , missing

collapse (sum) num_mem_2014 (max) hh_headage_mrk_2014 femhead_2014 attend_sch_2014 pry_edu_2014 finish_pry_2014 finish_sec_2014, by (HHID)
la var num_mem_2014 "household size"
la var femhead_2014 "=1 if head is female"
la var hh_headage_mrk_2014 "age of household head in years"
la var attend_sch_2014 "=1 if respondent attended school"
la var pry_edu_2014 "=1 if household head attended pry school"
la var finish_pry_2014 "=1 if household head finished pry school"
la var finish_sec_2014 "=1 if household head finished sec school"
save "${tza_GHS_W4_created_data}\demographics_2014.dta", replace

********************************* 
*Labor Age 
*********************************

use "${tza_GHS_W4_raw_data}\hh_sec_b.dta",clear 

ren y4_hhid HHID
ren hh_b04 hh_age

gen worker_2014 = 1
replace worker_2014 = 0 if hh_age < 15 | hh_age > 65

tab worker_2014,missing
sort HHID
collapse (sum) worker_2014, by (HHID)
la var worker_2014 "number of members age 15 and older and less than 65"
sort HHID

save "${tza_GHS_W4_created_data}\labor_age_2014.dta", replace


********************************
*Safety Net
********************************

use "${tza_GHS_W4_raw_data}\hh_sec_o1.dta",clear 
ren y4_hhid HHID
*hh_o01 received assistance
gen safety_net_2014 =1 if hh_o01==1 
tab safety_net_2014,missing
replace safety_net_2014 =0 if safety_net_2014==.
tab safety_net_2014,missing
collapse (max) safety_net_2014, by (HHID)
tab safety_net_2014
la var safety_net_2014 "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${tza_GHS_W4_created_data}\safety_net_2014.dta", replace


**************************************
*Food Prices
**************************************
use "${tza_GHS_W4_raw_data}\HH_SEC_J1.dta",clear 
ren y4_hhid HHID
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

gen maize_price_2014 = hh_j04/food_price_maize if itemcode==104

*br hh_j03_1 conversion hh_j03_2 hh_j04 food_price_maize maize_price_2014 itemcode if itemcode<=500

sum maize_price_2014,detail
tab maize_price_2014

*replace maize_price_2014 = 2000 if maize_price_2014 >2000 & maize_price_2014<.
*replace maize_price_2014 = 50 if maize_price_2014< 50
tab maize_price_2014,missing


egen medianfert_pr_itemcode = median(maize_price_2014), by (itemcode)
egen medianfert_pr_occ  = median(maize_price_2014), by (occ )


egen num_fert_pr_itemcode = count(maize_price_2014), by (itemcode)
egen num_fert_pr_occ = count(maize_price_2014), by (occ )


tab medianfert_pr_itemcode
tab medianfert_pr_occ



tab num_fert_pr_itemcode
tab num_fert_pr_occ


gen maize_price_mr_2014 = maize_price_2014

*replace maize_price_mr_2014 = medianfert_pr_occ if maize_price_mr_2014==. 
*tab maize_price_mr_2014,missing

replace maize_price_mr_2014 = medianfert_pr_itemcode if maize_price_mr_2014==. 
tab maize_price_mr_2014,missing

egen mid_maize = median(maize_price_mr_2014)
replace maize_price_mr_2014= mid_maize if maize_price_mr_2014==.
tab maize_price_mr_2014




*********Getting the price for rice only**************

//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//19.millitre       0.001
//9. pieces	        0.35



gen food_price_rice = hh_j03_2* conversion if itemcode==101

gen rice_price_2014 = hh_j04/food_price_rice if itemcode==101

*br hh_j03_1 conversion hh_j03_2 hh_j04 food_price_rice rice_price_2014 itemcode if itemcode<=500

sum rice_price_2014,detail
tab rice_price_2014

*replace rice_price_2014 = 1000 if rice_price_2014 >1000 & rice_price_2014<.
*replace rice_price_2014 = 25 if rice_price_2014< 25
*tab rice_price_2014,missing


egen median_pr_itemcode = median(rice_price_2014), by (itemcode)
egen median_pr_occ  = median(rice_price_2014), by (occ )



egen num_pr_itemcode = count(rice_price_2014), by (itemcode)
egen num_pr_occ = count(rice_price_2014), by (occ )



tab median_pr_itemcode



tab num_pr_itemcode
tab num_pr_occ

gen rice_price_mr_2014 = rice_price_2014

replace rice_price_mr_2014 = median_pr_itemcode if rice_price_mr_2014==. 
tab rice_price_mr_2014,missing
replace rice_price_mr_2014 = median_pr_occ if rice_price_mr_2014==. 
tab rice_price_mr_2014,missing
egen mid_rice = median(rice_price_mr_2014)
replace rice_price_mr_2014= mid_rice if rice_price_mr_2014==.
tab rice_price_mr_2014

collapse  (max) maize_price_mr_2014 rice_price_mr_2014, by(HHID)
label var maize_price_mr_2014 "commercial price of maize in naira"
label var rice_price_mr_2014 "commercial price of rice in naira"
sort HHID
save "${tza_GHS_W4_created_data}\food_prices_2014.dta", replace







*****************************
*Household Assests
****************************


use "${tza_GHS_W4_raw_data}\hh_sec_m.dta",clear 
ren y4_hhid HHID
*hh_m01 qty of items
*hh_m04 scrap value of items

gen hhasset_value_2014 = hh_m01*hh_m04
tab hhasset_value_2014
sum hhasset_value_2014,detail
replace hhasset_value_2014 = 7200000  if hhasset_value_2014 > 7200000  & hhasset_value_2014 <. //bottom 3%
replace hhasset_value_2014 = 2000 if hhasset_value_2014 <2000   //top 3%
tab hhasset_value_2014,missing

************generating the mean vakue**************
*ren  interview_status occ
egen mean_val_itemcode  = mean(hhasset_value_2014), by (itemcode )
egen mean_val_occ = mean(hhasset_value_2014), by (occ)


egen num_val_itemcode  = count(hhasset_value_2014), by (itemcode )
egen num_val_occ = count(hhasset_value_2014), by (occ)




tab mean_val_itemcode
*tab mean_val_HHID



tab num_val_itemcode
*tab num_val_HHID


replace hhasset_value_2014 = mean_val_itemcode if hhasset_value_2014 ==. 

tab hhasset_value_2014,missing
replace hhasset_value_2014 = mean_val_occ if hhasset_value_2014 ==. 

tab hhasset_value_2014,missing

egen mean = mean(hhasset_value_2014)
replace hhasset_value_2014 =  mean if hhasset_value_2014 ==.
tab hhasset_value_2014,missing


collapse (sum) hhasset_value_2014, by (HHID)

la var hhasset_value_2014 "total value of household asset"
save "${tza_GHS_W4_created_data}\hhasset_value_2014.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************

use "${tza_GHS_W4_raw_data}\ag_sec_2a.dta",clear
append using "${tza_GHS_W4_raw_data}\ag_sec_2b.dta", gen (short)
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

ren y4_hhid HHID
collapse (sum) area_est_hectares area_meas_hectares , by (HHID)
sort HHID
ren area_est_hectares land_holding_est_2014
ren area_meas_hectares land_holding_meas_2014
label var land_holding_est_2014 "land holding estimated in hectares"
label var land_holding_meas_2014 "land holding measured using gps in hectares"
save "${tza_GHS_W4_created_data}\land_holding_2014.dta", replace







************************* Merging Agricultural Datasets ********************

use "${tza_GHS_W4_created_data}\commercial_fert_2014.dta", replace


*******All observations Merged*****

merge 1:1 HHID using "${tza_GHS_W4_created_data}\subsidized_fert_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\savings_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\credit_access_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\Extension_access_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\demographics_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\labor_age_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\safety_net_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\food_prices_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\hhasset_value_2014.dta", nogen

merge 1:1 HHID using "${tza_GHS_W4_created_data}\land_holding_2014.dta"

save "${tza_GHS_W4_created_data}\tanzania_wave4_completedata_2014.dta", replace

