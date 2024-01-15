










clear



global tza_GHS_W3_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\TZA_2012_NPS-R3_v01_M_STATA8_English_labels"
global tza_GHS_W3_created_data  "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2012"










************************
*Geodata Variables
************************

use "${tza_GHS_W3_raw_data }\HouseholdGeovars_Y3.dta", clear

ren y3_hhid HHID

ren soil02 plot_slope
ren soil01 plot_elevation
ren soil03  plot_wetness

tab1 plot_slope plot_elevation plot_wetness, missing


/*egen med_slope = median( plot_slope)
egen med_elevation = median( plot_elevation)
egen med_wetness = median( plot_wetness)



replace plot_slope= med_slope if plot_slope==.
replace plot_elevation= med_elevation if plot_elevation==.
replace plot_wetness= med_wetness if plot_wetness==.*/


collapse (sum) plot_slope plot_elevation plot_wetness, by (HHID)
sort HHID
la var plot_slope "slope of plot"
la var plot_elevation "Elevation of plot"
la var plot_wetness "Potential wetness index of plot"
save "${tza_GHS_W3_created_data}\geodata_2012.dta", replace




********************************
*Subsidized Fertilizer 
********************************

use "${tza_GHS_W3_raw_data }\AG_SEC_3A.dta",clear 

merge 1:1 y3_hhid plotnum using "${tza_GHS_W3_raw_data }\AG_SEC_3B.dta"

ren y3_hhid HHID
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


egen subsidy_qty = rowtotal(subsidy_qty1 subsidy_qty2 subsidy_qty3 subsidy_qty4)
*br subsidy_qty1 subsidy_qty2 subsidy_qty3 subsidy_qty4 subsidy_qty
tab subsidy_qty



gen subsidy_dummy = 1 if ag3a_50==1 | ag3b_50==1 | ag3a_57==1 |ag3b_57==1
tab subsidy_dummy
*br ag3a_50 ag3b_50 ag3a_57 ag3b_57 subsidy_dummy if ag3a_57==1 
replace subsidy_dummy=0 if subsidy_dummy==.
tab subsidy_dummy,missing



gen org_fert = 1 if ag3a_41==1 | ag3b_41==1
tab org_fert, missing
replace org_fert =0 if org_fert==.
tab org_fert,missing


collapse (sum)subsidy_qty (max) org_fert subsidy_dummy, by (HHID)
la var org_fert "1= if used organic fertilizer"
label var subsidy_qty "Quantity of Fertilizer Purchased with voucher in kg"
label var subsidy_dummy "=1 if acquired any fertilizer using voucher"
save "${tza_GHS_W3_created_data}\subsidized_fert_2012.dta", replace







********************************************************************************
*HOUSEHOLD IDS
********************************************************************************
use "${tza_GHS_W3_raw_data }/HH_SEC_A.dta", clear 
ren hh_a01_1 region 
ren hh_a01_2 region_name
ren hh_a02_1 district
ren hh_a02_2 district_name
ren hh_a03_1 ward 
ren hh_a03_2 ward_name
ren hh_a04_1 ea
ren hh_a09 y2_hhid
ren hh_a10 hh_split
ren y3_weight weight
gen rural = (y3_rural==1) 
keep y3_hhid region district ward ea rural weight strataid clusterid y2_hhid hh_split
lab var rural "1=Household lives in a rural area"
save "${tza_GHS_W3_created_data}\hhids.dta", replace







*********************************************** 
*Purchased Fertilizer
***********************************************

use "${tza_GHS_W3_raw_data }\AG_SEC_3A.dta",clear 

merge 1:1 y3_hhid plotnum using "${tza_GHS_W3_raw_data }\AG_SEC_3B.dta", gen (fertilizer)
merge m:1 y3_hhid using "${tza_GHS_W3_created_data}\hhids.dta"

ren y3_hhid HHID


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

gen dist = ag3a_02_3 
tab dist,missing

egen mediandist_ea_id = median(dist), by (ea)
egen mediandist_region  = median(dist), by (region )
egen mediandist_stratum = median(dist), by (strataid)
egen mediandist_district  = median(dist), by (district )



egen numdist_ea_id = count(dist), by (ea)
egen numdist_region  = count(dist), by (region )
egen numdist_stratum = count(dist), by (strataid)
egen numdist_district  = count(dist), by (district)


tab numdist_ea_id
tab numdist_region
tab numdist_stratum
tab numdist_district


gen dist_cens= dist

replace dist_cens = mediandist_ea_id if dist_cens ==. & numdist_ea_id >= 470
tab dist_cens,missing

replace dist_cens = mediandist_region if dist_cens ==. & numdist_region >= 470
tab dist_cens,missing

replace dist_cens = mediandist_stratum if dist_cens ==. & numdist_stratum >= 470
tab dist_cens ,missing

replace dist_cens = mediandist_district if dist_cens ==. & numdist_district >= 470
tab dist_cens ,missing


egen med_dist = median (dist)
replace dist_cens = med_dist if dist_cens==.
tab dist_cens,missing
sum dist_cens,detail


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

egen total_qty = rowtotal(com_fert1_qty com_fert2_qty com_fert3_qty com_fert4_qty)
tab  total_qty, missing

egen total_valuefert = rowtotal(com_fert1_val com_fert2_val com_fert3_val com_fert4_val)
tab total_valuefert,missing

gen tpricefert = total_valuefert/total_qty 
tab tpricefert


gen tpricefert_cens = tpricefert
replace tpricefert_cens = 2000 if tpricefert_cens > 2000 & tpricefert_cens < .
replace tpricefert_cens = 500 if tpricefert_cens < 500
tab tpricefert_cens, missing





egen medianfert_pr_ea_id = median(tpricefert_cens), by (ea)
egen medianfert_pr_region  = median(tpricefert_cens), by (region )
egen medianfert_pr_stratum = median(tpricefert_cens), by (strataid)
egen medianfert_pr_district  = median(tpricefert_cens), by (district )



egen num_fert_pr_ea_id = count(tpricefert_cens), by (ea)
egen num_fert_pr_region  = count(tpricefert_cens), by (region )
egen num_fert_pr_stratum = count(tpricefert_cens), by (strataid)
egen num_fert_pr_district  = count(tpricefert_cens), by (district)


tab num_fert_pr_ea_id
tab num_fert_pr_region
tab num_fert_pr_stratum
tab num_fert_pr_district


gen tpricefert_cens_mrk = tpricefert_cens

replace tpricefert_cens_mrk = medianfert_pr_ea_id if tpricefert_cens_mrk ==. & num_fert_pr_ea_id >= 29
tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. & num_fert_pr_region >= 29
tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_stratum if tpricefert_cens_mrk ==. & num_fert_pr_stratum >= 29
tab tpricefert_cens_mrk ,missing

replace tpricefert_cens_mrk = medianfert_pr_district if tpricefert_cens_mrk ==. & num_fert_pr_district >= 29
tab tpricefert_cens_mrk ,missing

egen mid_fert = median(tpricefert_cens)
replace tpricefert_cens_mrk = mid_fert if tpricefert_cens_mrk==.
tab tpricefert_cens_mrk,missing










collapse (sum) dist_cens  total_qty  total_valuefert  (max) tpricefert_cens_mrk, by(HHID)
la var dist_cens "Distance travelled from plot to market in km"
label var total_qty  "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk  "price of commercial fertilizer purchased in naira"
sort HHID
save "${tza_GHS_W3_created_data}\commercial_fert_2012.dta", replace




************************************************
*Savings 
************************************************


use "${tza_GHS_W3_raw_data}\HH_SEC_Q1.dta",clear 
ren y3_hhid HHID

* hh_q10   1=having a bank account
*hh_q01_1 1= uses m-pesa financial service
*hh_q01_2 1= uses z-pesa financial service
*hh_q01_3 1= uses Airtel(zap) financial service
*hh_q01_4 1= uses Tigo pesa financial service
*hh_q03_f 1=save for emergencies
*hh_q03_g 1= save for other everyday expenses
*hh_q03_h 1= save for unusually large expenses


gen formal_bank =1 if hh_q10==1
tab formal_bank, missing
replace formal_bank =0 if formal_bank ==. 
tab formal_bank,nolabel
tab formal_bank,missing

gen fin_service = 1 if hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1 | hh_q01_4==1
replace fin_service =0 if fin_service ==.
tab fin_service


gen formal_save  =1 if fin_service==1 & hh_q03_f==1 | hh_q03_g==1 | hh_q03_h==1
 tab formal_save, missing
 replace formal_save =0 if formal_save ==.
 tab formal_save, missing



 collapse (max) formal_bank  formal_save, by (HHID)
 la var formal_bank  "=1 if respondent have an account in bank"
 la var formal_save  "=1 if used formal saving group"
 *la var informal_save  "=1 if used informal saving group"
save "${tza_GHS_W3_created_data}\savings_2012.dta", replace



*******************************************************
*Credit access 
*******************************************************

use "${tza_GHS_W3_raw_data}\HH_SEC_P.dta",clear 
ren y3_hhid HHID
*hh_p06 value of borrowed credit
*hh_p03 source of credit (formal <=5)(informal >5)
tab hh_p06
tab hh_p03
tab hh_p03,nolabel
 gen formal_credit =1 if hh_p06!=. & hh_p03 <=5 
 tab formal_credit,missing
 replace formal_credit =0 if formal_credit ==.
 tab formal_credit,missing
 

 
 gen informal_credit =1 if hh_p06!=. & hh_p03 >5 
 tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
 tab informal_credit,missing


 collapse (max) formal_credit  informal_credit, by (HHID)
 la var formal_credit "=1 if borrowed from formal credit group"
 la var informal_credit "=1 if borrowed from informal credit group"
save "${tza_GHS_W3_created_data}\credit_access_2012.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${tza_GHS_W3_raw_data}\AG_SEC_12B.dta",clear 
ren y3_hhid HHID
ren ag12b_08 ext_acess 

tab ext_acess, missing
tab ext_acess, nolabel

replace ext_acess = 0 if ext_acess==2 | ext_acess==.
tab ext_acess, missing
collapse (max) ext_acess, by (HHID)
la var ext_acess "=1 if received advise from extension services"
save "${tza_GHS_W3_created_data}\Extension_access_2012.dta", replace




*********************************
*Demographics 
*********************************



use "${tza_GHS_W3_raw_data}\HH_SEC_B.dta",clear 


merge 1:1 y3_hhid indidy3 using "${tza_GHS_W3_raw_data}\HH_SEC_C.dta", gen (household)
merge m:1 y3_hhid using "${tza_GHS_W3_created_data}\hhids.dta"
ren y3_hhid HHID
*hh_b02 sex 
*hh_b05 relationshiop to head
*hh_b04 age (years)


sort HHID indidy3
 
gen num_mem = 1


******** female head****

gen femhead  = 0
replace femhead = 1 if hh_b02== 2 & hh_b05==1
tab femhead,missing

********Age of HHead***********
ren hh_b04 hh_age
gen hh_headage  = hh_age if hh_b05==1

tab hh_headage

replace hh_headage = 100 if hh_headage > 100 & hh_headage < .
tab hh_headage
tab hh_headage, missing


************generating the median age**************
egen median_headage_ea_id = median(hh_headage), by (ea)
egen median_headage_region  = median(hh_headage), by (region )
egen median_headage_stratum  = median(hh_headage), by (strataid )
egen median_headage_district  = median(hh_headage), by (district )

egen num_headage_ea_id = count(hh_headage), by (ea)
egen num_headage_region  = count(hh_headage), by (region )
egen num_headage_stratum = count(hh_headage), by (strataid )
egen num_headage_district  = count(hh_headage), by (district )



tab num_headage_ea_id
tab num_headage_region
tab num_headage_stratum
tab num_headage_district


gen hh_headage_mrk  = hh_headage

replace hh_headage_mrk = median_headage_ea_id if hh_headage_mrk ==. & num_headage_ea_id >= 257
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_region if hh_headage_mrk ==. & num_headage_region >= 257
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_stratum if hh_headage_mrk ==. & num_headage_stratum >= 257
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_district if hh_headage_mrk ==. & num_headage_district >= 257
tab hh_headage_mrk,missing

egen mid_age = median(hh_headage)
replace hh_headage_mrk = mid_age if hh_headage_mrk==.
tab hh_headage_mrk,missing


********************Education****************************************************
*hh_c03 1= if attend_school
*hh_c07 highest_education qualification
*hh_b05 relationshiop to head


ren  hh_c03 attend_sch 
tab attend_sch
replace attend_sch = 0 if attend_sch ==2
tab attend_sch, nolabel


replace hh_c07= 0 if attend_sch==0
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

gen pry_edu  = 1 if hh_c07 < 18 & hh_b05==1
tab pry_edu,missing
gen finish_pry  = 1 if hh_c07 >= 18 & hh_c07 < 32 & hh_b05==1
tab finish_pry,missing
gen finish_sec  = 1 if hh_c07 >= 32 & hh_b05==1
tab finish_sec,missing

replace pry_edu =0 if pry_edu==. & hh_b05==1
replace finish_pry =0 if finish_pry==. & hh_b05==1
replace finish_sec =0 if finish_sec==. & hh_b05==1
tab pry_edu if hh_b05==1 , missing
tab finish_pry if hh_b05==1 , missing 
tab finish_sec if hh_b05==1 , missing

collapse (sum) num_mem (max) hh_headage_mrk femhead attend_sch pry_edu finish_pry finish_sec, by (HHID)
la var num_mem "household size"
la var femhead "=1 if head is female"
la var hh_headage_mrk "age of household head in years"
la var attend_sch "=1 if respondent attended school"
la var pry_edu "=1 if household head attended pry school"
la var finish_pry "=1 if household head finished pry school"
la var finish_sec "=1 if household head finished sec school"
save "${tza_GHS_W3_created_data}\demographics_2012.dta", replace

********************************* 
*Labor Age 
*********************************

use "${tza_GHS_W3_raw_data}\HH_SEC_B.dta",clear 

ren y3_hhid HHID
ren hh_b04 hh_age

gen worker = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort HHID
collapse (sum) worker, by (HHID)
la var worker "number of members age 15 and older and less than 65"
sort HHID

save "${tza_GHS_W3_created_data}\labor_age_2012.dta", replace


********************************
*Safety Net
********************************

use "${tza_GHS_W3_raw_data}\HH_SEC_O1.dta",clear 
ren y3_hhid HHID
*hh_o01 received assistance
gen safety_net =1 if hh_o01==1 
tab safety_net,missing
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (HHID)
tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${tza_GHS_W3_created_data}\safety_net_2012.dta", replace


**************************************
*Food Prices
**************************************
use "${tza_GHS_W3_raw_data}\HH_SEC_J1.dta",clear 
merge m:1 y3_hhid using "${tza_GHS_W3_created_data}\hhids.dta"
ren y3_hhid HHID
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

label list itemcode

gen food_price_maize = hh_j03_2* conversion if itemcode==104

gen maize_price  = hh_j04/food_price_maize if itemcode==104

*br hh_j03_1 conversion hh_j03_2 hh_j04 food_price_maize maize_price itemcode if itemcode<=500

sum maize_price,detail
tab maize_price

replace maize_price = 2000 if maize_price >2000 & maize_price<.
*replace maize_price = 50 if maize_price< 50
tab maize_price,missing


egen median_pr_ea_id = median(maize_price), by (ea)
egen median_pr_region  = median(maize_price), by (region )
egen median_pr_stratum  = median(maize_price), by (strataid )
egen median_pr_district  = median(maize_price), by (district )




egen num_pr_ea_id = count(maize_price), by (ea)
egen num_pr_region = count(maize_price), by (region )
egen num_pr_stratum = count(maize_price), by (strataid )
egen num_pr_district  = count(maize_price), by (district )




tab num_pr_ea_id
tab num_pr_region
tab num_pr_stratum
tab num_pr_district




gen maize_price_mr  = maize_price

replace maize_price_mr = median_pr_ea_id if maize_price_mr==. & num_pr_ea_id >= 16
tab maize_price_mr,missing
replace maize_price_mr = median_pr_region if maize_price_mr==. & num_pr_region>= 16
tab maize_price_mr,missing
replace maize_price_mr = median_pr_stratum if maize_price_mr==.  & num_pr_stratum>= 16
tab maize_price_mr,missing
replace maize_price_mr = median_pr_district if maize_price_mr==. & num_pr_district>= 16
tab maize_price_mr,missing


egen mid_price = median(maize_price)


replace maize_price_mr = mid_price if maize_price_mr==.
tab maize_price_mr,missing




*********Getting the price for rice only**************

//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//19.millitre       0.001
//9. pieces	        0.35



gen food_price_rice = hh_j03_2* conversion if itemcode==101

gen rice_price = hh_j04/food_price_rice if itemcode==101

*br hh_j03_1 conversion hh_j03_2 hh_j04 food_price_rice rice_price itemcode if itemcode<=500

sum rice_price,detail
tab rice_price

*replace rice_price = 1000 if rice_price >1000 & rice_price<.
*replace rice_price = 25 if rice_price< 25
*tab rice_price,missing


egen medianr_pr_ea_id = median(rice_price), by (ea)
egen medianr_pr_region  = median(rice_price), by (region )
egen medianr_pr_stratum  = median(rice_price), by (strataid)
egen medianr_pr_district  = median(rice_price), by (district )




egen numr_pr_ea_id = count(rice_price), by (ea)
egen numr_pr_region = count(rice_price), by (region )
egen numr_pr_stratum = count(rice_price), by (strataid )
egen numr_pr_district  = count(rice_price), by (district )


tab numr_pr_ea_id
tab numr_pr_region
tab numr_pr_stratum
tab numr_pr_district




gen rice_price_mr  = rice_price

replace rice_price_mr = medianr_pr_ea_id if rice_price_mr==. & numr_pr_ea_id >= 1
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_region if rice_price_mr==. & numr_pr_region>= 1
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_stratum if rice_price_mr==.  & numr_pr_stratum>= 1
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_district if rice_price_mr==. & numr_pr_district>= 1
tab rice_price_mr,missing


egen midr_price = median(rice_price)


replace rice_price_mr = midr_price if rice_price_mr==.
tab rice_price_mr,missing






**************
*Net Buyers and Sellers
***************
*hh_j03_2 from purchases
*hh_j05_2 from own production

//They are using the same conversion
*br hh_j03_2 hh_j03_1 hh_j05_2 hh_j05_1 if (hh_j03_2 !=. & hh_j03_2 !=0) & (hh_j05_2 !=. & hh_j05_2 !=0)
tab hh_j03_2
tab hh_j05_2

replace hh_j03_2 = 0 if hh_j03_2<=0 |hh_j03_2==.
tab hh_j03_2,missing
replace hh_j05_2 = 0 if hh_j05_2<=0 |hh_j05_2==.
tab hh_j05_2,missing

gen net_seller = 1 if hh_j05_2 > hh_j03_2
tab net_seller,missing
replace net_seller=0 if net_seller==.
tab net_seller,missing

gen net_buyer = 1 if hh_j05_2 < hh_j03_2
tab net_buyer,missing
replace net_buyer=0 if net_buyer==.
tab net_buyer,missing



collapse  (max) net_seller net_buyer maize_price_mr rice_price_mr, by(HHID)
la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"
label var maize_price_mr "commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
sort HHID
save "${tza_GHS_W3_created_data}\food_prices_2012.dta", replace







*****************************
*Household Assests
****************************


use "${tza_GHS_W3_raw_data}\HH_SEC_M.dta",clear 
merge m:1 y3_hhid using "${tza_GHS_W3_created_data}\hhids.dta"
ren y3_hhid HHID
*hh_m01 qty of items
*hh_m04 scrap value of items

gen hhasset_value = hh_m01*hh_m04
tab hhasset_value
sum hhasset_value,detail
replace hhasset_value = 7800000  if hhasset_value > 7800000  & hhasset_value <.
replace hhasset_value = 2000 if hhasset_value <2000
tab hhasset_value,missing

************generating the mean vakue**************
egen mean_val_ea_id = mean(hhasset_value), by (ea)
egen mean_val_region = mean(hhasset_value), by (region)
egen mean_val_stratum  = mean(hhasset_value), by (strataid )
egen mean_val_district  = mean(hhasset_value), by (district )




egen num_val_ea_id = count(hhasset_value), by (ea)
egen num_val_region = count(hhasset_value), by (region)
egen num_val_stratum  = count(hhasset_value), by (strataid )
egen num_val_district  = count(hhasset_value), by (district )




tab num_val_ea_id
tab num_val_region
tab num_val_stratum
tab num_val_district






replace hhasset_value = mean_val_ea_id if hhasset_value ==. & num_val_ea_id >= 2099
tab hhasset_value,missing
replace hhasset_value = mean_val_region if hhasset_value ==. & num_val_region >= 2099
tab hhasset_value,missing
replace hhasset_value = mean_val_stratum if hhasset_value ==. & num_val_stratum >= 2099
tab hhasset_value,missing
replace hhasset_value = mean_val_district if hhasset_value ==. & num_val_district >= 2099
tab hhasset_value,missing

egen mid_asset = median(hhasset_value)
replace hhasset_value= mid_asset if hhasset_value==.
tab hhasset_value,missing



collapse (sum) hhasset_value, by (HHID)

la var hhasset_value "total value of household asset"
save "${tza_GHS_W3_created_data}\hhasset_value_2012.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************

use "${tza_GHS_W3_raw_data}\AG_SEC_2A.dta",clear
append using "${tza_GHS_W3_raw_data}\AG_SEC_2B.dta", gen (short)
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

ren y3_hhid HHID
collapse (sum) area_est_hectares area_meas_hectares , by (HHID)
sort HHID
ren area_est_hectares land_holding_est 
ren area_meas_hectares land_holding_meas 
label var land_holding_est  "land holding estimated in hectares"
label var land_holding_meas "land holding measured using gps in hectares"
save "${tza_GHS_W3_created_data}\land_holding_2012.dta", replace





*******************************
*Soil Quality
*******************************

use "${tza_GHS_W3_raw_data}\AG_SEC_3A.dta",clear 
ren y3_hhid HHID

ren ag3a_11 soil_quality
tab soil_quality, missing
egen med_soil = median(soil_quality)
replace soil_quality= med_soil if soil_quality==.
tab soil_quality, missing
collapse (max) soil_quality, by (HHID)
la var soil_quality "1=Good 2= Average 3=Bad "
save "${tza_GHS_W3_created_data}\soil_quality_2012.dta", replace




************************* Merging Agricultural Datasets ********************

use "${tza_GHS_W3_created_data}\commercial_fert_2012.dta", replace


*******All observations Merged*****

merge 1:1 HHID using "${tza_GHS_W3_created_data}\subsidized_fert_2012.dta", gen (subsidized)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\savings_2012.dta", gen (savings)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\credit_access_2012.dta", gen (credit)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\Extension_access_2012.dta", gen (extension)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\demographics_2012.dta", gen (demographics)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\labor_age_2012.dta", gen (labor)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\safety_net_2012.dta", gen (safety)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\food_prices_2012.dta", gen (foodprices)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\geodata_2012.dta", gen (geodata)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\soil_quality_2012.dta", gen (soil)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\hhasset_value_2012.dta", gen (hhasset)
sort HHID
merge 1:1 HHID using "${tza_GHS_W3_created_data}\land_holding_2012.dta"
gen year = 2012
sort HHID
save "${tza_GHS_W3_created_data}\tanzania_wave3_completedata_2012.dta", replace

