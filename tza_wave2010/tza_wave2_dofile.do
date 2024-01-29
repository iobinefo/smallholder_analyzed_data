







*if production is greater than purchase
*merge 1:m eaid using          ..........  keep using (community)

clear



global tza_GHS_W2_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\TZA_2010_NPS-R2_v02_M_STATA8"
global tza_GHS_W2_created_data  "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2010"





************************
*Geodata Variables
************************

use "${tza_GHS_W2_raw_data }\HH.Geovariables_Y2.dta", clear

ren y2_hhid HHID

ren soil02 plot_slope
ren soil01 plot_elevation
ren soil03  plot_wetness

tab1 plot_slope plot_elevation plot_wetness, missing


egen med_slope = median( plot_slope)
egen med_elevation = median( plot_elevation)
egen med_wetness = median( plot_wetness)



replace plot_slope= med_slope if plot_slope==.
replace plot_elevation= med_elevation if plot_elevation==.
replace plot_wetness= med_wetness if plot_wetness==.


collapse (sum) plot_slope plot_elevation plot_wetness, by (HHID)
sort HHID
la var plot_slope "slope of plot"
la var plot_elevation "Elevation of plot"
la var plot_wetness "Potential wetness index of plot"
save "${tza_GHS_W2_created_data}\geodata_2010.dta", replace








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

egen subsidy_qty= rowtotal(subsidy_qty1 subsidy_qty2 subsidy_qty3)
*br subsidy_qty1 subsidy_qty2 subsidy_qty3 subsidy_qty_2010
tab subsidy_qty
replace subsidy_qty = 0 if subsidy_qty ==.
tab subsidy_qty,missing


gen subsidy_dummy = 1 if ag3a_48==1 | ag3b_48==1 | ag3b_55==1
tab subsidy_dummy
*br ag3a_48 ag3b_48 ag3b_55 subsidy_dummy_2010 if ag3b_48==1 
replace subsidy_dummy=0 if subsidy_dummy==.
tab subsidy_dummy,missing

gen org_fert = 1 if ag3a_39==1 | ag3b_39==1
tab org_fert, missing
replace org_fert =0 if org_fert==.
tab org_fert,missing


collapse (sum)subsidy_qty (max) org_fert subsidy_dummy, by (HHID)
la var org_fert "1= if used organic fertilizer"
label var subsidy_qty "Quantity of Fertilizer Purchased with voucher in kg"
label var subsidy_dummy "=1 if acquired any fertilizer using voucher"
save "${tza_GHS_W2_created_data}\subsidized_fert_2010.dta", replace


****************************
*HH_ids
****************************

use "${tza_GHS_W2_raw_data }\HH_SEC_A.dta" ,clear 
gen region_name=region
label define region_name  1 "Dodoma" 2 "Arusha" 3 "Kilimanjaro" 4 "Tanga" 5 "Morogoro" 6 "Pwani" 7 "Dar es Salaam" 8 "Lindi" 9 "Mtwara" 10 "Ruvuma" 11 "Iringa" 12 "Mbeya" 13 "Singida" 14 "Tabora" 15 "Rukwa" 16 "Kigoma" 17 "Shinyanga" 18 "Kagera" 19 "Mwanza" 20 "Mara" 21 "Manyara" 22 "Njombe" 23 "Katavi" 24 "Simiyu" 25 "Geita" 51 "Kaskazini Unguja" 52 "Kusini Unguja" 53 "Minji/Magharibi Unguja" 54 "Kaskazini Pemba" 55 "Kusini Pemba"
label values region_name region_name
gen district_name=.
tostring district_name, replace
ren y2_weight weight
gen hh_split=2 if hh_a11==3 //split-off household
label define hh_split 1 "ORIGINAL HOUSEHOLD" 2 "SPLIT-OFF HOUSEHOLD"
label values hh_split hh_split
lab var hh_split "2=Split-off household" 
gen rural = (y2_rural==1)
keep y2_hhid region district ward region_name district_name ea rural weight strataid clusterid hh_split
lab var rural "1=Household lives in a rural area"
save "${tza_GHS_W2_created_data}\hhids.dta", replace






*********************************************** 
*Purchased Fertilizer
***********************************************


use "${tza_GHS_W2_raw_data }\AG_SEC3A.dta",clear 

merge 1:1 y2_hhid plotnum using "${tza_GHS_W2_raw_data }\AG_SEC3B.dta", gen (fertilizer)
merge m:1 y2_hhid using "${tza_GHS_W2_created_data}\hhids.dta",gen (hhids)

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

replace dist_cens = mediandist_ea_id if dist_cens ==. & numdist_ea_id >= 389
tab dist_cens,missing

replace dist_cens = mediandist_region if dist_cens ==. & numdist_region >= 389
tab dist_cens,missing

replace dist_cens = mediandist_stratum if dist_cens ==. & numdist_stratum >= 389
tab dist_cens ,missing

replace dist_cens = mediandist_district if dist_cens ==. & numdist_district >= 389
tab dist_cens ,missing


egen med_dist = median (dist)
replace dist_cens = med_dist if dist_cens==.
tab dist_cens,missing
sum dist_cens,detail

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

egen total_qty  = rowtotal(com_fert1_qty com_fert2_qty com_fert3_qty)
tab  total_qty, missing

egen total_valuefert  = rowtotal(com_fert1_val com_fert2_val com_fert3_val)
tab total_valuefert,missing

gen tpricefert  = total_valuefert /total_qty 
tab tpricefert


gen tpricefert_cens  = tpricefert 
replace tpricefert_cens = 2000 if tpricefert_cens > 2000 & tpricefert_cens < .
replace tpricefert_cens = 380 if tpricefert_cens < 380
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

replace tpricefert_cens_mrk = medianfert_pr_ea_id if tpricefert_cens_mrk ==. & num_fert_pr_ea_id >= 22
tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. & num_fert_pr_region >= 22
tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_stratum if tpricefert_cens_mrk ==. & num_fert_pr_stratum >= 22
tab tpricefert_cens_mrk ,missing

replace tpricefert_cens_mrk = medianfert_pr_district if tpricefert_cens_mrk ==. & num_fert_pr_district >= 22
tab tpricefert_cens_mrk ,missing

egen mid_fert = median(tpricefert_cens)
replace tpricefert_cens_mrk = mid_fert if tpricefert_cens_mrk==.
tab tpricefert_cens_mrk,missing








collapse (sum) dist_cens total_qty  total_valuefert (max) tpricefert_cens_mrk, by(HHID)
la var dist_cens  "Distance from plot to market in km"
label var total_qty "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk "price of commercial fertilizer purchased in naira"
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


gen formal_bank  =1 if hh_q18==1
tab formal_bank, missing
replace formal_bank =0 if formal_bank ==. 
tab formal_bank,nolabel
tab formal_bank,missing

gen fin_service = 1 if hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1
replace fin_service =0 if fin_service ==.
tab fin_service


gen formal_save  =1 if fin_service==1 & hh_q03_6==1 | hh_q03_7==1 | hh_q03_8==1
 tab formal_save, missing
 replace formal_save =0 if formal_save ==.
 tab formal_save, missing



 collapse (max) formal_bank  formal_save, by (HHID)
 la var formal_bank "=1 if respondent have an account in bank"
 la var formal_save "=1 if used formal saving group"
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
 gen formal_credit  =1 if hh_p06!=. & hh_p03 <=5 

 tab formal_credit,missing
 replace formal_credit =0 if formal_credit ==.
 
 tab formal_credit,missing
 

 
 gen informal_credit  =1 if hh_p06!=. & hh_p03 >5 
 tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
 tab informal_credit,missing


 collapse (max) formal_credit  informal_credit, by (HHID)
 la var formal_credit "=1 if borrowed from formal credit group"
 la var informal_credit  "=1 if borrowed from informal credit group"

save "${tza_GHS_W2_created_data}\credit_access_2010.dta", replace



******************************* 
*Extension Visit 
*******************************



use "${tza_GHS_W2_raw_data}\AG_SEC12B.dta",clear 

ren y2_hhid HHID
ren ag12b_07 ext_acess

tab ext_acess , missing
tab ext_acess, nolabel

replace ext_acess = 0 if ext_acess==2 | ext_acess==.
tab ext_acess, missing
collapse (max) ext_acess, by (HHID)
la var ext_acess "=1 if received advise from extension services"
save "${tza_GHS_W2_created_data}\Extension_access_2010.dta", replace




*********************************
*Demographics 
*********************************



use "${tza_GHS_W2_raw_data}\HH_SEC_B.dta",clear 


merge 1:1 y2_hhid indidy2 using "${tza_GHS_W2_raw_data}\HH_SEC_C.dta", gen (household)
merge m:1 y2_hhid using "${tza_GHS_W2_created_data}\hhids.dta"

ren y2_hhid HHID
*hh_b02 sex 
*hh_b05 relationshiop to head
*hh_b04 age (years)


sort HHID indidy2 
 
gen num_mem  = 1


******** female head****

gen femhead  = 0
replace femhead = 1 if hh_b02== 2 & hh_b05==1
tab femhead,missing

********Age of HHead***********
ren hh_b04 hh_age
gen hh_headage  = hh_age if hh_b05==1

tab hh_headage

replace hh_headage = 90 if hh_headage > 90 & hh_headage < .
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

replace hh_headage_mrk = median_headage_ea_id if hh_headage_mrk ==. & num_headage_ea_id >= 204
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_region if hh_headage_mrk ==. & num_headage_region >= 204
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_stratum if hh_headage_mrk ==. & num_headage_stratum >= 204
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_district if hh_headage_mrk ==. & num_headage_district >= 204
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
gen finish_pry = 1 if hh_c07 >= 18 & hh_c07 < 32 & hh_b05==1
tab finish_pry,missing
gen finish_sec  = 1 if hh_c07 >= 32 & hh_b05==1
tab finish_sec,missing

replace pry_edu =0 if pry_edu==. & hh_b05==1
replace finish_pry =0 if finish_pry==. & hh_b05==1
replace finish_sec =0 if finish_sec==. & hh_b05==1
tab pry_edu if hh_b05==1 , missing
tab finish_pry if hh_b05==1 , missing 
tab finish_sec if hh_b05==1 , missing

collapse (sum) num_mem  (max) hh_headage_mrk femhead attend_sch pry_edu finish_pry finish_sec, by (HHID)
la var num_mem  "household size"
la var femhead  "=1 if head is female"
la var hh_headage_mrk  "age of household head in years"
la var attend_sch  "=1 if respondent attended school"
la var pry_edu "=1 if household head attended pry school"
la var finish_pry "=1 if household head finished pry school"
la var finish_sec "=1 if household head finished sec school"
save "${tza_GHS_W2_created_data}\demographics_2010.dta", replace

********************************* 
*Labor Age 
*********************************

use "${tza_GHS_W2_raw_data}\HH_SEC_B.dta",clear 

ren y2_hhid HHID
ren hh_b04 hh_age

gen worker  = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort HHID
collapse (sum) worker, by (HHID)
la var worker "number of members age 15 and older and less than 65"
sort HHID

save "${tza_GHS_W2_created_data}\labor_age_2010.dta", replace


********************************
*Safety Net
********************************

use "${tza_GHS_W2_raw_data}\HH_SEC_O1.dta",clear 
ren y2_hhid HHID
*hh_o01_3 received assistance
gen safety_net =1 if hh_o01_3==1 
tab safety_net,missing
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (HHID)
tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${tza_GHS_W2_created_data}\safety_net_2010.dta", replace


**************************************
*Food Prices
**************************************
use "${tza_GHS_W2_raw_data}\COMSEC_CJ.dta",clear

ren id_04 ea
ren id_03 ward
ren id_02 district
ren id_01 region
*********Getting the price for maize only**************

//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001


gen conversion =1
replace conversion=1 if cm_j01a ==1 & itemid=="104"
gen food_size=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion = food_size*0.001 if cm_j01a ==2 & itemid=="104"



gen food_price_maize = cm_j01b* conversion if itemid=="104"

gen maize_price  = cm_j01c/food_price_maize if itemid=="104"

*br cm_j01a conversion cm_j01b cm_j01c food_price_maize maize_price itemname if itemid=="104"

sum maize_price,detail
tab maize_price, missing

replace maize_price = 800 if maize_price >800 & maize_price<.
*replace maize_price = 50 if maize_price< 50
tab maize_price,missing

egen median_pr_ea_id = median(maize_price), by (region district ward ea)
egen median_pr_ward  = median(maize_price), by (region district ward )
egen median_pr_district  = median(maize_price), by (region district )
egen median_pr_region  = median(maize_price), by (region )




egen num_pr_ea_id = count(maize_price), by (region district ward ea)
egen num_pr_ward = count(maize_price), by (region district ward)
egen num_pr_district = count(maize_price), by (region district )
egen num_pr_region  = count(maize_price), by (region )




tab num_pr_ea_id
tab num_pr_ward
tab num_pr_district
tab num_pr_region



gen maize_price_mr  = maize_price

replace maize_price_mr = median_pr_ea_id if maize_price_mr==. 
replace maize_price_mr = median_pr_ward if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_district if maize_price_mr==.  
tab maize_price_mr,missing
replace maize_price_mr = median_pr_region if maize_price_mr==.
tab maize_price_mr,missing



egen mid_price = median(maize_price)


replace maize_price_mr = mid_price if maize_price_mr==.
tab maize_price_mr,missing


*********Getting the price for maize only**************

//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001


gen conversion2 =1
replace conversion2=1 if cm_j01a ==1 & itemid=="101"
gen food_size2=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion2 = food_size2*0.001 if cm_j01a ==2 & itemid=="101"



gen food_price_rice = cm_j01b* conversion2 if itemid=="101"

gen rice_price  = cm_j01c/food_price_rice if itemid=="101"

*br cm_j01a conversion2 cm_j01b cm_j01c food_price_rice rice_price itemname if itemid=="101"

sum rice_price,detail
tab rice_price

*replace rice_price = 1000 if rice_price >1000 & rice_price<.
*replace rice_price = 25 if rice_price< 25
*tab rice_price,missing


egen medianr_pr_ea_id = median(rice_price), by (region district ward ea)
egen medianr_pr_ward  = median(rice_price), by (region district ward)
egen medianr_pr_district  = median(rice_price), by (region district)
egen medianr_pr_region  = median(rice_price), by (region )




egen numr_pr_ea_id = count(rice_price), by (region district ward ea)
egen numr_pr_ward = count(rice_price), by (region district ward )
egen numr_pr_district = count(rice_price), by (region district )
egen numr_pr_region  = count(rice_price), by (region )


tab numr_pr_ea_id
tab numr_pr_ward
tab numr_pr_district
tab numr_pr_region





gen rice_price_mr  = rice_price

replace rice_price_mr = medianr_pr_ea_id if rice_price_mr==.
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_ward if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_district if rice_price_mr==.  
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_region if rice_price_mr==. 
tab rice_price_mr,missing


egen midr_price = median(rice_price)
replace rice_price_mr = midr_price if rice_price_mr==.
tab rice_price_mr,missing



sort region district ea
collapse  (max) maize_price_mr rice_price_mr, by(region district ward ea)
save "${tza_GHS_W2_created_data}\food_2010.dta", replace




use "${tza_GHS_W2_raw_data }\HH_SEC_A.dta" ,clear 
ren y2_hhid HHID

//Just 580 matched
merge m:1 region district ward ea using "${tza_GHS_W2_created_data}\food_2010.dta",keepusing(maize_price_mr rice_price_mr)


egen median_pr_ea_id = median(maize_price), by (region district ward ea)
egen median_pr_ward  = median(maize_price), by (region district ward )
egen median_pr_district  = median(maize_price), by (region district )
egen median_pr_region  = median(maize_price), by (region )

replace maize_price_mr = median_pr_ea_id if maize_price_mr==. 
replace maize_price_mr = median_pr_ward if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_district if maize_price_mr==.  
tab maize_price_mr,missing
replace maize_price_mr = median_pr_region if maize_price_mr==.
tab maize_price_mr,missing

egen medianr_pr_ea_id = median(rice_price), by (region district ward ea)
egen medianr_pr_ward  = median(rice_price), by (region district ward)
egen medianr_pr_district  = median(rice_price), by (region district)
egen medianr_pr_region  = median(rice_price), by (region )


replace rice_price_mr = medianr_pr_ea_id if rice_price_mr==.
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_ward if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_district if rice_price_mr==.  
tab rice_price_mr,missing
replace rice_price_mr = medianr_pr_region if rice_price_mr==. 
tab rice_price_mr,missing
collapse  (max) maize_price_mr rice_price_mr, by(HHID)
label var maize_price_mr"commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
sort HHID
save "${tza_GHS_W2_created_data}\food_prices_2010.dta", replace




**************
*Net Buyers and Sellers
***************

use "${tza_GHS_W2_raw_data}\HH_SEC_K1.dta",clear 
merge m:1 y2_hhid using "${tza_GHS_W2_created_data}\hhids.dta"
ren y2_hhid HHID
*hh_k03_2 from purchases
*hh_k05_2 from own production

//They are using the same conversion
*br hh_k03_2 hh_k03_1 hh_k05_2 hh_k05_1 if (hh_k03_2 !=. & hh_k03_2 !=0) & (hh_k05_2 !=. & hh_k05_2 !=0)
tab hh_k03_2
tab hh_k05_2

replace hh_k03_2 = 0 if hh_k03_2<=0 |hh_k03_2==.
tab hh_k03_2,missing
replace hh_k05_2 = 0 if hh_k05_2<=0 |hh_k05_2==.
tab hh_k05_2,missing

gen net_seller = 1 if hh_k05_2 > hh_k03_2
tab net_seller,missing
replace net_seller=0 if net_seller==.
tab net_seller,missing

gen net_buyer = 1 if hh_k05_2 < hh_k03_2
tab net_buyer,missing
replace net_buyer=0 if net_buyer==.
tab net_buyer,missing




collapse  (max) net_seller net_buyer, by(HHID)
la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"

sort HHID
save "${tza_GHS_W2_created_data}\net_buyer_seller_2010.dta", replace






*****************************
*Household Assests
****************************


use "${tza_GHS_W2_raw_data}\AG_SEC11.dta",clear 
merge m:1 y2_hhid using "${tza_GHS_W2_created_data}\hhids.dta"
ren y2_hhid HHID
*ag11_01 qty of items
*ag11_02 scrap value of items

gen hhasset_value = ag11_01*ag11_02
tab hhasset_value,missing
sum hhasset_value,detail
replace hhasset_value = 1440000  if hhasset_value > 1440000  & hhasset_value <.
replace hhasset_value = 2000 if hhasset_value <2000
tab hhasset_value

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






replace hhasset_value = mean_val_ea_id if hhasset_value ==. & num_val_ea_id >= 260
tab hhasset_value,missing
replace hhasset_value = mean_val_region if hhasset_value ==. & num_val_region >= 260
tab hhasset_value,missing
replace hhasset_value = mean_val_stratum if hhasset_value ==. & num_val_stratum >= 260
tab hhasset_value,missing
replace hhasset_value = mean_val_district if hhasset_value ==. & num_val_district >= 260
tab hhasset_value,missing

egen mid_asset = median(hhasset_value)
replace hhasset_value= mid_asset if hhasset_value==.
tab hhasset_value,missing



collapse (sum) hhasset_value, by (HHID)

la var hhasset_value "total value of household asset"
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

gen field_size = area_acres_meas

tab field_size, missing
tab area_acres_est,missing
replace field_size = area_acres_est  if field_size==.  
tab field_size, missing

sum field_size, detail
*replace field_size = 0.52 if field_size==.
*tab field_size, missing


**************Top 95% is 4 hectares
gen field_size_ha = field_size* (1/2.47105)
tab field_size_ha, missing




ren y2_hhid HHID
collapse (sum)  field_size_ha , by (HHID)
sort HHID
label var field_size_ha "land holding measured using gps in hectares"
save "${tza_GHS_W2_created_data}\land_holding_2010.dta", replace







*******************************
*Soil Quality
*******************************
use "${tza_GHS_W2_raw_data}\AG_SEC2A.dta",clear 
append using "${tza_GHS_W2_raw_data}\AG_SEC2B.dta", gen(short)
ren plotnum plot_id
gen area_acres_est = ag2a_04
replace area_acres_est = ag2b_15 if area_acres_est==.
gen area_acres_meas = ag2a_09
replace area_acres_meas = ag2b_20 if area_acres_meas==.

gen field = area_acres_meas

tab field, missing
tab area_acres_est,missing
replace field = area_acres_est  if field==.  
tab field, missing

sum field, detail
*replace field = 0.52 if field_size==.
*tab field, missing


**************Top 95% is 4 hectares
gen field_size = field* (1/2.47105)
tab field_size, missing
ren plot_id plotnum
keep y2_hhid plotnum field_size

merge 1:1 y2_hhid plotnum using "${tza_GHS_W2_raw_data}\AG_SEC3A.dta"
merge m:1 y2_hhid using "${tza_GHS_W2_created_data}\hhids.dta", gen(hhids)



ren y2_hhid HHID
ren ag3a_10 soil_quality


egen max_fieldsize = max(field_size), by (HHID)
replace max_fieldsize= . if max_fieldsize!= max_fieldsize
order field_size soil_quality HHID max_fieldsize
sort HHID
keep if field_size== max_fieldsize
sort HHID plotnum field_size

duplicates report HHID

duplicates tag HHID, generate(dup)
tab dup
list field_size soil_quality dup


list HHID plotnum  field_size soil_quality dup if dup>0

egen soil_qty_rev = min(soil_quality) 
gen soil_qty_rev2 = soil_quality

replace soil_qty_rev2 = soil_qty_rev if dup>0

list HHID plotnum  field_size soil_quality soil_qty_rev soil_qty_rev2 dup if dup>0
tab soil_qty_rev2, missing



/* should i give them the median?

egen median_ea_id = median(soil_qty_rev2), by (region district ward ea)
egen median_ward  = median(soil_qty_rev2), by (region district ward )
egen median_district  = median(soil_qty_rev2), by (region district )
egen median_region  = median(soil_qty_rev2), by (region )

replace soil_qty_rev2 = median_ea_id if soil_qty_rev2==. 
replace soil_qty_rev2 = median_ward if soil_qty_rev2==. 
tab soil_qty_rev2,missing
replace soil_qty_rev2 = median_district if soil_qty_rev2==.  
tab soil_qty_rev2,missing
replace soil_qty_rev2 = median_region if soil_qty_rev2==.
tab soil_qty_rev2,missing*/





collapse (mean) soil_qty_rev2 , by (HHID)
la define soil 1 "Good" 2 "fair" 3 "poor"
la values soil soil_qty_rev2
la var soil_qty_rev2 "1=Good 2= Average 3=Bad "
save "${tza_GHS_W2_created_data}\soil_quality_2010.dta", replace








************************* Merging Agricultural Datasets ********************

use "${tza_GHS_W2_created_data}\commercial_fert_2010.dta", replace


*******All observations Merged*****

merge 1:1 HHID using "${tza_GHS_W2_created_data}\subsidized_fert_2010.dta", gen (subsidized)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\savings_2010.dta", gen (savings)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\credit_access_2010.dta", gen (credit)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\Extension_access_2010.dta", gen (extension)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\demographics_2010.dta", gen (demographics)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\labor_age_2010.dta", gen (labor)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\safety_net_2010.dta", gen (safety)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\food_prices_2010.dta", gen (foodprices)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\net_buyer_seller_2010.dta", gen (net)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\soil_quality_2010.dta", gen (soil)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\geodata_2010.dta", gen (geodata)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\hhasset_value_2010.dta", gen (hhasset)
sort HHID
merge 1:1 HHID using "${tza_GHS_W2_created_data}\land_holding_2010.dta"
gen year = 2010
sort HHID
save "${tza_GHS_W2_created_data}\tanzania_wave2_completedata_2010.dta", replace

