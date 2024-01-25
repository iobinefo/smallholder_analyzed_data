










clear



global tza_GHS_W5_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\TZA_2020_NPS-R5_v02_M_STATA14"
global tza_GHS_W5_created_data  "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2020"






********************************************************************************
*HOUSEHOLD IDS
********************************************************************************
use "${tza_GHS_W5_raw_data }/hh_sec_a.dta", clear 
ren hh_a01_1 region 
ren hh_a02_1 district
ren hh_a03_1 ward 
ren hh_a03_2 ward_name
ren hh_a03_3a village 
ren hh_a03_3b village_name
ren hh_a04_1 ea
*ren sdd_weights weight //sdd = y5
*ren sdd_hhid y5_hhid 
*gen rural = (sdd_rural==1) // was clustertype in w4
keep y5_hhid region district ward village ward_name village_name ea strataid clusterid
save "${tza_GHS_W5_created_data}\hhids.dta", replace





********************************************************************************
*Food Prices
********************************************************************************

use "${tza_GHS_W5_raw_data }\cm_sec_g.dta", clear
merge m:1 interview__key  using "${tza_GHS_W5_raw_data}\cm_sec_a.dta", gen (com)

ren id_01 region
ren id_02 district
ren id_04 ea



tab vil_loc_weight if item_id==2
tab vil_loc_price if item_id==2
*br vil_loc_unit_os vil_loc_weight vil_loc_price  item_id if item_id==2

gen maize_price = vil_loc_price  if item_id==2
sum maize_price,detail
tab maize_price

*replace maize_price = 900 if maize_price >900 & maize_price<. //bottom 5%
*replace maize_price = 50 if maize_price< 50
*tab maize_price,missing


egen median_pr_ea_id = median(maize_price), by (ea)
egen median_pr_ea  = median(maize_price), by (id_03 )
egen median_pr_ea_  = median(maize_price), by (id_05 )

egen median_pr_district  = median(maize_price), by (district )
egen median_pr_region  = median(maize_price), by (region )



egen num_pr_ea_id = count(maize_price), by (ea)
egen num_pr_district  = count(maize_price), by (district )
egen num_pr_region = count(maize_price), by (region )



tab num_pr_ea_id
tab num_pr_region
tab num_pr_district




gen maize_price_mr  = maize_price

replace maize_price_mr = median_pr_ea_id if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_ea if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_ea_ if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_district if maize_price_mr==.
tab maize_price_mr,missing
replace maize_price_mr = median_pr_region if maize_price_mr==. 
tab maize_price_mr,missing

egen mid_maize= median(maize_price)
replace maize_price_mr = mid_maize if maize_price_mr==.
tab maize_price_mr,missing




************rice
tab vil_loc_weight if item_id==1
tab vil_loc_price if item_id==1
*br vil_loc_unit_os vil_loc_weight vil_loc_price  item_id if item_id==2

gen rice_price = vil_loc_price  if item_id==1

sum rice_price,detail
tab rice_price

*replace rice_price = 1000 if rice_price >1000 & rice_price<.
*replace rice_price = 25 if rice_price< 25
*tab rice_price,missing


egen median_ea_id = median(rice_price), by (ea)
egen median_ea  = median(rice_price), by (id_03 )
egen median_ea_  = median(rice_price), by (id_05 )

egen median_district  = median(rice_price), by (district )
egen median_region  = median(rice_price), by (region )





gen rice_price_mr  = rice_price

replace rice_price_mr = median_pr_ea_id if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = median_pr_ea if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = median_pr_ea_ if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = median_pr_district if rice_price_mr==.
tab rice_price_mr,missing
replace rice_price_mr = median_pr_region if rice_price_mr==. 
tab rice_price_mr,missing

egen mid_rice= median(rice_price)
replace rice_price_mr = mid_rice if rice_price_mr==.
tab rice_price_mr,missing




sort region district ea
collapse  (max) maize_price_mr rice_price_mr id_03 id_05, by(region district ea)
label var maize_price_mr "commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
save "${tza_GHS_W5_created_data}\food_pr.dta", replace








use "${tza_GHS_W5_raw_data }/hh_sec_a.dta", clear 
ren hh_a01_1 region 
ren hh_a02_1 district
ren hh_a03_1 ward 
ren hh_a03_2 ward_name
ren hh_a03_3a village 
ren hh_a03_3b village_name
ren hh_a04_1 ea
*ren sdd_weights weight //sdd = y5
*ren sdd_hhid y5_hhid 
*gen rural = (sdd_rural==1) // was clustertype in w4
keep y5_hhid region district ward village ward_name village_name ea strataid clusterid

merge m:1 region district ea using "${tza_GHS_W5_created_data}\food_pr.dta"


****MAIZE

egen median_pr_ea_id = median(maize_price), by (ea)
egen median_pr_ea  = median(maize_price), by (id_03 )
egen median_pr_ea_  = median(maize_price), by (id_05 )

egen median_pr_district  = median(maize_price), by (district )
egen median_pr_region  = median(maize_price), by (region )



egen num_pr_ea_id = count(maize_price), by (ea)
egen num_pr_district  = count(maize_price), by (district )
egen num_pr_region = count(maize_price), by (region )



tab num_pr_ea_id
tab num_pr_region
tab num_pr_district



replace maize_price_mr = median_pr_ea_id if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_ea if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_ea_ if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_district if maize_price_mr==.
tab maize_price_mr,missing
replace maize_price_mr = median_pr_region if maize_price_mr==. 
tab maize_price_mr,missing





*****RICE


egen median_ea_id = median(rice_price), by (ea)
egen median_ea  = median(rice_price), by (id_03 )
egen median_ea_  = median(rice_price), by (id_05 )

egen median_district  = median(rice_price), by (district )
egen median_region  = median(rice_price), by (region )




replace rice_price_mr = median_pr_ea_id if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = median_pr_ea if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = median_pr_ea_ if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = median_pr_district if rice_price_mr==.
tab rice_price_mr,missing
replace rice_price_mr = median_pr_region if rice_price_mr==. 
tab rice_price_mr,missing



ren y5_hhid HHID
collapse  (max) maize_price_mr rice_price_mr, by(HHID)
label var maize_price_mr "commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
save "${tza_GHS_W5_created_data}\food_prices_2020.dta", replace



































*********************************************** 
*Purchased Fertilizer
***********************************************

use "${tza_GHS_W5_raw_data }\ag_sec_3a.dta",clear 

merge 1:1 y5_hhid plot_id using "${tza_GHS_W5_raw_data}\ag_sec_3b.dta", gen (fertilizer)
merge m:1 y5_hhid using "${tza_GHS_W5_created_data}\hhids.dta"


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

replace dist_cens = mediandist_ea_id if dist_cens ==. & numdist_ea_id >= 105
tab dist_cens,missing

replace dist_cens = mediandist_district if dist_cens ==. & numdist_district >= 105
tab dist_cens ,missing

replace dist_cens = mediandist_region if dist_cens ==. & numdist_region >= 105
tab dist_cens,missing

replace dist_cens = mediandist_stratum if dist_cens ==. & numdist_stratum >= 105
tab dist_cens ,missing






egen med_dist = median (dist)
replace dist_cens = med_dist if dist_cens==.
tab dist_cens,missing
sum dist_cens,detail


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


egen total_qty  = rowtotal(com_fert1_qty com_fert2_qty com_fert3_qty com_fert4_qty)
tab  total_qty , missing

egen total_valuefert = rowtotal(com_fert1_val com_fert2_val com_fert3_val com_fert4_val)
tab total_valuefert,missing

gen tpricefert  = total_valuefert /total_qty 
tab tpricefert 


gen tpricefert_cens  = tpricefert 
replace tpricefert_cens = 2750 if tpricefert_cens > 2750 & tpricefert_cens < .  //bottom 5%
replace tpricefert_cens = 600 if tpricefert_cens < 600 //top 5%
tab tpricefert_cens, missing



egen medianfert_pr_ea_id = median(tpricefert_cens), by (ea)
egen medianfert_pr_district  = median(tpricefert_cens), by (district )
egen medianfert_pr_region  = median(tpricefert_cens), by (region )
egen medianfert_pr_stratum = median(tpricefert_cens), by (strataid)


egen num_fert_pr_ea_id = count(tpricefert_cens), by (ea)
egen num_fert_pr_district  = count(tpricefert_cens), by (district)
egen num_fert_pr_region  = count(tpricefert_cens), by (region )

egen num_fert_pr_stratum = count(tpricefert_cens), by (strataid)




tab num_fert_pr_ea_id
tab num_fert_pr_district
tab num_fert_pr_region
tab num_fert_pr_stratum



gen tpricefert_cens_mrk = tpricefert_cens

replace tpricefert_cens_mrk = medianfert_pr_ea_id if tpricefert_cens_mrk ==. & num_fert_pr_ea_id >= 10
tab tpricefert_cens_mrk,missing
replace tpricefert_cens_mrk = medianfert_pr_district if tpricefert_cens_mrk ==. & num_fert_pr_district >= 10
tab tpricefert_cens_mrk ,missing
replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. & num_fert_pr_region >= 10
tab tpricefert_cens_mrk,missing
replace tpricefert_cens_mrk = medianfert_pr_stratum if tpricefert_cens_mrk ==. & num_fert_pr_stratum >= 10
tab tpricefert_cens_mrk ,missing






egen mid_fert = median(tpricefert_cens)
replace tpricefert_cens_mrk = mid_fert if tpricefert_cens_mrk==.
tab tpricefert_cens_mrk,missing



gen org_fert = 1 if ag3a_41==1 | ag3b_41==1
tab org_fert, missing
replace org_fert =0 if org_fert==.
tab org_fert,missing




collapse (sum) dist_cens total_qty total_valuefert (max) org_fert tpricefert_cens_mrk, by(HHID)
la var org_fert "1= if used organic fertilizer"
la var dist_cens  "Distance travelled from plot to market in km"
label var total_qty "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk "price of commercial fertilizer purchased in naira"
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


gen formal_bank =1 if hh_q10==1
tab formal_bank, missing
replace formal_bank =0 if formal_bank ==. 
tab formal_bank,nolabel
tab formal_bank,missing

gen fin_service = 1 if hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1 | hh_q01_4==1 | hh_q01_5==1 | hh_q01_6==1
replace fin_service =0 if fin_service ==.
tab fin_service


gen formal_save =1 if fin_service==1 & hh_q03_6==1 | hh_q03_7==1 | hh_q03_8==1
 tab formal_save, missing
 replace formal_save =0 if formal_save ==.
 tab formal_save, missing



 collapse (max) formal_bank  formal_save, by (HHID)
 la var formal_bank  "=1 if respondent have an account in bank"
 la var formal_save "=1 if used formal saving group"
 *la var informal_save "=1 if used informal saving group"
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
 gen formal_credit =1 if hh_p06!=. & hh_p03 <=5 
 tab formal_credit ,missing
 replace formal_credit =0 if formal_credit ==.
 tab formal_credit,missing
 

 
 gen informal_credit =1 if hh_p06!=. & hh_p03 >5 
 tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
 tab informal_credit,missing


 collapse (max) formal_credit informal_credit, by (HHID)
 la var formal_credit "=1 if borrowed from formal credit group"
 la var informal_credit "=1 if borrowed from informal credit group"
save "${tza_GHS_W5_created_data}\credit_access_2020.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${tza_GHS_W5_raw_data}\ag_sec_12b.dta",clear 
ren y5_hhid HHID
ren ag12b_08 ext_acess 

tab ext_acess, missing
tab ext_acess, nolabel

replace ext_acess = 0 if ext_acess==2 | ext_acess==.
tab ext_acess, missing
collapse (max) ext_acess, by (HHID)
la var ext_acess "=1 if received advise from extension services"
save "${tza_GHS_W5_created_data}\Extension_access_2020.dta", replace




*********************************
*Demographics 
*********************************



use "${tza_GHS_W5_raw_data}\hh_sec_b.dta",clear 
merge 1:1 y5_hhid indidy5 using "${tza_GHS_W5_raw_data}\hh_sec_c.dta", gen (household)
merge m:1 y5_hhid using "${tza_GHS_W5_created_data}\hhids.dta"

ren y5_hhid HHID
*hh_b02 sex 
*hh_b05 relationshiop to head
*hh_b04 age (years)


sort HHID indidy5
 
gen num_mem= 1


******** female head****

gen femhead= 0
replace femhead = 1 if hh_b02== 2 & hh_b05==1
tab femhead,missing

********Age of HHead***********
ren hh_b04 hh_age
gen hh_headage = hh_age if hh_b05==1

tab hh_headage

tab hh_headage, missing


************generating the median age**************
egen median_headage_ea_id = median(hh_headage), by (ea)
egen median_headage_district  = median(hh_headage), by (district )
egen median_headage_region  = median(hh_headage), by (region )
egen median_headage_stratum  = median(hh_headage), by (strataid )

egen num_headage_ea_id = count(hh_headage), by (ea)
egen num_headage_district  = count(hh_headage), by (district )
egen num_headage_region  = count(hh_headage), by (region )
egen num_headage_stratum = count(hh_headage), by (strataid )




tab num_headage_ea_id
tab num_headage_district
tab num_headage_region
tab num_headage_stratum



gen hh_headage_mrk  = hh_headage

replace hh_headage_mrk = median_headage_ea_id if hh_headage_mrk ==. & num_headage_ea_id >= 257
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_district if hh_headage_mrk ==. & num_headage_district >= 257
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_region if hh_headage_mrk ==. & num_headage_region >= 257
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_stratum if hh_headage_mrk ==. & num_headage_stratum >= 257
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



 *label list hh_c07
tab hh_c07 if hh_b05==1,missing
replace hh_c07 = 1 if hh_c07==. &  hh_b05==1
tab hh_c07 if hh_b05==1,missing
replace hh_c07 = 1 if hh_c07==0 &  hh_b05==1
tab hh_c07 if hh_b05==1,missing
*** Education Dummy Variable*****
 *label list hh_c07

gen pry_edu = 1 if hh_c07 < 18 & hh_b05==1
tab pry_edu,missing
gen finish_pry  = 1 if hh_c07 >= 18 & hh_c07 < 32 & hh_b05==1
tab finish_pry,missing
gen finish_sec = 1 if hh_c07 >= 32 & hh_b05==1
tab finish_sec,missing

replace pry_edu =0 if pry_edu==. & hh_b05==1
replace finish_pry =0 if finish_pry==. & hh_b05==1
replace finish_sec =0 if finish_sec==. & hh_b05==1
tab pry_edu if hh_b05==1 , missing
tab finish_pry if hh_b05==1 , missing 
tab finish_sec if hh_b05==1 , missing

collapse (sum) num_mem  (max) hh_headage_mrk femhead attend_sch pry_edu finish_pry finish_sec, by (HHID)
la var num_mem  "household size"
la var femhead "=1 if head is female"
la var hh_headage_mrk "age of household head in years"
la var attend_sch "=1 if respondent attended school"
la var pry_edu "=1 if household head attended pry school"
la var finish_pry "=1 if household head finished pry school"
la var finish_sec "=1 if household head finished sec school"
save "${tza_GHS_W5_created_data}\demographics_2020.dta", replace

********************************* 
*Labor Age 
*********************************

use "${tza_GHS_W5_raw_data}\hh_sec_b.dta",clear 

ren y5_hhid HHID
ren hh_b04 hh_age

gen worker= 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort HHID
collapse (sum) worker, by (HHID)
la var worker "number of members age 15 and older and less than 65"
sort HHID

save "${tza_GHS_W5_created_data}\labor_age_2020.dta", replace


********************************
*Safety Net
********************************

use "${tza_GHS_W5_raw_data}\hh_sec_o1.dta",clear 
ren y5_hhid HHID
*hh_o01 received assistance
gen safety_net =1 if hh_o01==1 
tab safety_net,missing
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (HHID)
tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${tza_GHS_W5_created_data}\safety_net_2020.dta", replace





**************
*Net Buyers and Sellers
***************
use "${tza_GHS_W5_raw_data}\HH_SEC_J1.dta",clear 
merge m:1 y5_hhid using "${tza_GHS_W5_created_data}\hhids.dta"
ren y5_hhid HHID
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



collapse  (max) net_seller net_buyer, by(HHID)
la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"
sort HHID
save "${tza_GHS_W5_created_data}\net_buyer_seller_2020.dta", replace







*****************************
*Household Assests
****************************


use "${tza_GHS_W5_raw_data}\hh_sec_m.dta",clear 
merge m:1 y5_hhid using "${tza_GHS_W5_created_data}\hhids.dta"

ren y5_hhid HHID
*hh_m01 qty of items
*hh_m04 scrap value of items

gen hhasset_value = hh_m01*hh_m04
tab hhasset_value
sum hhasset_value,detail
replace hhasset_value = 7200000  if hhasset_value > 7200000  & hhasset_value <. //bottom 4%
replace hhasset_value = 3000 if hhasset_value <3000   //top 4%
tab hhasset_value,missing

************generating the mean vakue**************
egen mean_val_ea_id = mean(hhasset_value), by (ea)
egen mean_val_district  = mean(hhasset_value), by (district )
egen mean_val_region = mean(hhasset_value), by (region)
egen mean_val_stratum  = mean(hhasset_value), by (strataid )




egen num_val_ea_id = count(hhasset_value), by (ea)
egen num_val_district  = count(hhasset_value), by (district )
egen num_val_region = count(hhasset_value), by (region)
egen num_val_stratum  = count(hhasset_value), by (strataid )




tab num_val_ea_id
tab num_val_region
tab num_val_stratum
tab num_val_district






replace hhasset_value = mean_val_ea_id if hhasset_value ==. & num_val_ea_id >= 2489
tab hhasset_value,missing
replace hhasset_value = mean_val_district if hhasset_value ==. & num_val_district >= 2489
tab hhasset_value,missing
replace hhasset_value = mean_val_region if hhasset_value ==. & num_val_region >= 2489
tab hhasset_value,missing
replace hhasset_value = mean_val_stratum if hhasset_value ==. & num_val_stratum >= 2489
tab hhasset_value,missing


egen mid_asset = median(hhasset_value)
replace hhasset_value= mid_asset if hhasset_value==.
tab hhasset_value,missing


collapse (sum) hhasset_value, by (HHID)

la var hhasset_value "total value of household asset"
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
ren area_est_hectares land_holding_est 
ren area_meas_hectares land_holding_meas 
label var land_holding_est "land holding estimated in hectares"
label var land_holding_meas "land holding measured using gps in hectares"
save "${tza_GHS_W5_created_data}\land_holding_2020.dta", replace




*******************************
*Soil Quality
*******************************
use "${tza_GHS_W5_raw_data}\ag_sec_02.dta",clear
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

keep y5_hhid plot_id area_est_hectares area_meas_hectares
 
 
 
merge 1:1 y5_hhid plot_id using "${tza_GHS_W5_raw_data}\ag_sec_3a.dta"
merge m:1 y5_hhid using "${tza_GHS_W5_created_data}\hhids.dta", gen(hhids)


ren y5_hhid HHID
ren plot_id plotnum
ren ag3a_11 soil_quality
tab soil_quality, missing


gen field_size= area_meas_hectares
tab field_size, missing


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
tab soil_qty_rev2,missing



replace soil_qty_rev2 =2 if soil_qty_rev2==1.5
replace soil_qty_rev2 =3 if soil_qty_rev2==2.5
tab soil_qty_rev2,missing


collapse (mean) soil_qty_rev2 , by (HHID)
la define soil 1 "Good" 2 "fair" 3 "poor"
la value soil soil_qty_rev2
la var soil_qty_rev2 "1=Good 2= Average 3=Bad "

save "${tza_GHS_W5_created_data}\soil_quality_2020.dta", replace



















************************* Merging Agricultural Datasets ********************

use "${tza_GHS_W5_created_data}\commercial_fert_2020.dta", replace


*******All observations Merged*****

merge 1:1 HHID using "${tza_GHS_W5_created_data}\savings_2020.dta", gen (savings)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\credit_access_2020.dta", gen (credit)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\Extension_access_2020.dta", gen (extension)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\demographics_2020.dta", gen (demographics)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\labor_age_2020.dta", gen (labor)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\safety_net_2020.dta", gen (safety)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\food_prices_2020.dta", gen (foodprices)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\net_buyer_seller_2020.dta", gen (net)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\soil_quality_2020.dta", gen (soil)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\hhasset_value_2020.dta", gen (hhasset)
sort HHID
merge 1:1 HHID using "${tza_GHS_W5_created_data}\land_holding_2020.dta"

gen year = 2020
sort HHID

save "${tza_GHS_W5_created_data}\tanzania_wave5_completedata_2020.dta", replace








*****************Appending all Tanzania Datasets*****************
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2010\tanzania_wave2_completedata_2010.dta",clear  

append using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2012\tanzania_wave3_completedata_2012.dta" 

append using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014\tanzania_wave4_completedata_2014.dta" 

append using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2020\tanzania_wave5_completedata_2020.dta" 


save "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\complete_files\Tanzania_complete_data.dta", replace





