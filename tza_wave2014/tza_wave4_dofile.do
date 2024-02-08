










clear



global tza_GHS_W4_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\TZA_2014_NPS-R4_v03_M_STATA11"
global tza_GHS_W4_created_data  "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014"



****************************
*AG FILTER
****************************






use "${tza_GHS_W4_raw_data }\ag_filters.dta", clear
keep y4_hhid ag2a_01
rename (ag2a_01) (ag_rainy_14)
save "${tza_GHS_W4_created_data}\ag_rainy_14.dta", replace

*merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_20.dta", gen(filter)

*keep if ag_rainy_14==1


****************
*food prices
***************



use "${tza_GHS_W4_raw_data }\com_sec_cg.dta",clear
merge m:1 y4_cluster  using "${tza_GHS_W4_raw_data}\com_sec_a1a2.dta", gen (com)



ren id_01 region
ren id_02 district
ren id_05 ea


 
tab cm_g_weight if item_code==104
tab cm_g_price if item_code==104
*br cm_g_weight cm_g_price item_name  item_code if item_code==104

gen maize_price = cm_g_price/cm_g_weight  if item_code==104
sum maize_price,detail
tab maize_price

replace maize_price = 800 if maize_price >800 & maize_price<. //bottom 1%
tab maize_price,missing


egen median_pr_ea_id = median(maize_price), by (ea)
egen median_pr_district  = median(maize_price), by (district )
egen median_pr_region  = median(maize_price), by (region )



gen maize_price_mr  = maize_price

replace maize_price_mr = median_pr_ea_id if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_district if maize_price_mr==.
tab maize_price_mr,missing
replace maize_price_mr = median_pr_region if maize_price_mr==. 
tab maize_price_mr,missing

*egen mid_maize= median(maize_price)
*replace maize_price_mr = mid_maize if maize_price_mr==.
*tab maize_price_mr,missing




************rice
 
tab cm_g_weight if item_code==102
tab cm_g_price if item_code==102
*br cm_g_weight cm_g_price item_name  item_code if item_code==102

gen rice_price = cm_g_price/cm_g_weight  if item_code==102

sum rice_price,detail
tab rice_price

replace rice_price = 1000 if rice_price >1000 & rice_price<. //bottom 5%
replace rice_price = 250 if rice_price< 250                    //top 5%
tab rice_price,missing


egen median_ea_id = median(rice_price), by (ea)
egen median_district  = median(rice_price), by (district )
egen median_region  = median(rice_price), by (region )





gen rice_price_mr  = rice_price

replace rice_price_mr = median_pr_ea_id if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = median_pr_district if rice_price_mr==.
tab rice_price_mr,missing
replace rice_price_mr = median_pr_region if rice_price_mr==. 
tab rice_price_mr,missing

egen mid_rice= median(rice_price)
replace rice_price_mr = mid_rice if rice_price_mr==.
tab rice_price_mr,missing




sort region district ea
collapse  (max) maize_price_mr rice_price_mr, by(region district ea)
label var maize_price_mr "commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
save "${tza_GHS_W4_created_data}\food_pr.dta", replace







use "${tza_GHS_W4_raw_data }/hh_sec_a.dta", clear 
ren hh_a01_1 region 
ren hh_a01_2 region_name
ren hh_a02_1 district
ren hh_a02_2 district_name
ren hh_a03_1 ward 
ren hh_a03_2 ward_name
ren hh_a03_3a village 
ren hh_a03_3b village_name
ren hh_a04_1 ea
ren y4_weights weight
gen rural = (clustertype==1)
keep y4_hhid region district ward village region_name district_name ward_name village_name ea rural weight strataid clusterid
lab var rural "1=Household lives in a rural area"

merge m:1 region district ea using "${tza_GHS_W4_created_data}\food_pr.dta"

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1

****MAIZE

egen median_pr_ea_id = median(maize_price), by (ea)
egen median_pr_district  = median(maize_price), by (district )
egen median_pr_region  = median(maize_price), by (region )




replace maize_price_mr = median_pr_ea_id if maize_price_mr==. 
tab maize_price_mr,missing
replace maize_price_mr = median_pr_district if maize_price_mr==.
tab maize_price_mr,missing
replace maize_price_mr = median_pr_region if maize_price_mr==. 
tab maize_price_mr,missing





*****RICE


egen median_ea_id = median(rice_price), by (ea)
egen median_district  = median(rice_price), by (district )
egen median_region  = median(rice_price), by (region )




replace rice_price_mr = median_pr_ea_id if rice_price_mr==. 
tab rice_price_mr,missing
replace rice_price_mr = median_pr_district if rice_price_mr==.
tab rice_price_mr,missing
replace rice_price_mr = median_pr_region if rice_price_mr==. 
tab rice_price_mr,missing



ren y4_hhid HHID
collapse  (max) maize_price_mr rice_price_mr, by(HHID)
label var maize_price_mr "commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
save "${tza_GHS_W4_created_data}\food_prices_2014.dta", replace


























********************************
*Subsidized Fertilizer 
********************************

use "${tza_GHS_W4_raw_data }\ag_sec_3a.dta",clear 

merge 1:1 y4_hhid plotnum using "${tza_GHS_W4_raw_data }\ag_sec_3b.dta"

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
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


egen subsidy_qty = rowtotal(subsidy_qty1 subsidy_qty2 subsidy_qty3 subsidy_qty4)
*br subsidy_qty1 subsidy_qty2 subsidy_qty3 subsidy_qty4 subsidy_qty
tab subsidy_qty



gen subsidy_dummy = 1 if ag3a_50==1 | ag3b_50==1 | ag3a_57==1 |ag3b_57==1
tab subsidy_dummy
*br ag3a_50 ag3b_50 ag3a_57 ag3b_57 subsidy_dummy_2014 if ag3a_57==1 
replace subsidy_dummy=0 if subsidy_dummy==.
tab subsidy_dummy,missing



gen org_fert = 1 if ag3a_41==1 | ag3b_41==1
tab org_fert, missing
replace org_fert =0 if org_fert==.
tab org_fert,missing

collapse (sum) subsidy_qty (max) org_fert subsidy_dummy, by (HHID)
la var org_fert "1= if used organic fertilizer"
label var subsidy_qty "Quantity of Fertilizer Purchased with voucher in kg"
label var subsidy_dummy "=1 if acquired any fertilizer using voucher"
save "${tza_GHS_W4_created_data}\subsidized_fert_2014.dta", replace





********************************************************************************
*HOUSEHOLD IDS
********************************************************************************
use "${tza_GHS_W4_raw_data }/hh_sec_a.dta", clear 
ren hh_a01_1 region 
ren hh_a01_2 region_name
ren hh_a02_1 district
ren hh_a02_2 district_name
ren hh_a03_1 ward 
ren hh_a03_2 ward_name
ren hh_a03_3a village 
ren hh_a03_3b village_name
ren hh_a04_1 ea
ren y4_weights weight
gen rural = (clustertype==1)
keep y4_hhid region district ward village region_name district_name ward_name village_name ea rural weight strataid clusterid
lab var rural "1=Household lives in a rural area"
save "${tza_GHS_W4_created_data}\hhids.dta", replace










*********************************************** 
*Purchased Fertilizer
***********************************************

use "${tza_GHS_W4_raw_data }\ag_sec_3a.dta",clear 
merge 1:1 y4_hhid plotnum using "${tza_GHS_W4_raw_data }\ag_sec_3b.dta", gen (fertilizer)
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\hhids.dta"

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1

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

gen dist  = ag3a_02_3 
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

replace dist_cens = mediandist_ea_id if dist_cens ==. & numdist_ea_id >= 795
tab dist_cens,missing

replace dist_cens = mediandist_stratum if dist_cens ==. & numdist_stratum >= 795
tab dist_cens ,missing

replace dist_cens = mediandist_region if dist_cens ==. & numdist_region >= 795
tab dist_cens,missing

replace dist_cens = mediandist_district if dist_cens ==. & numdist_district >= 795
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

egen total_qty  = rowtotal(com_fert1_qty com_fert2_qty com_fert3_qty com_fert4_qty)
tab  total_qty , missing

egen total_valuefert  = rowtotal(com_fert1_val com_fert2_val com_fert3_val com_fert4_val)
tab total_valuefert ,missing

gen tpricefert  = total_valuefert /total_qty 
tab tpricefert 


gen tpricefert_cens  = tpricefert 
replace tpricefert_cens = 2200 if tpricefert_cens > 2200 & tpricefert_cens < .
replace tpricefert_cens = 400 if tpricefert_cens < 400
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

replace tpricefert_cens_mrk = medianfert_pr_ea_id if tpricefert_cens_mrk ==. & num_fert_pr_ea_id >= 45
tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_stratum if tpricefert_cens_mrk ==. & num_fert_pr_stratum >= 45
tab tpricefert_cens_mrk ,missing

replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. & num_fert_pr_region >= 45
tab tpricefert_cens_mrk,missing


replace tpricefert_cens_mrk = medianfert_pr_district if tpricefert_cens_mrk ==. & num_fert_pr_district >= 45
tab tpricefert_cens_mrk ,missing

egen mid_fert = median(tpricefert_cens)
replace tpricefert_cens_mrk = mid_fert if tpricefert_cens_mrk==.
tab tpricefert_cens_mrk,missing











collapse (sum)  total_qty total_valuefert  (max) dist_cens tpricefert_cens_mrk, by(HHID)
la var dist_cens "Distance travelled from plot to market in km"
label var total_qty "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk "price of commercial fertilizer purchased in naira"
sort HHID
save "${tza_GHS_W4_created_data}\commercial_fert_2014.dta", replace




************************************************
*Savings 
************************************************


use "${tza_GHS_W4_raw_data}\hh_sec_q1.dta",clear 
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1

ren y4_hhid HHID

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



 collapse (max) formal_bank formal_save, by (HHID)
 la var formal_bank  "=1 if respondent have an account in bank"
 la var formal_save "=1 if used formal saving group"
 *la var informal_save "=1 if used informal saving group"
save "${tza_GHS_W4_created_data}\savings_2014.dta", replace



*******************************************************
*Credit access 
*******************************************************

use "${tza_GHS_W4_raw_data}\hh_sec_p.dta",clear 
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
ren y4_hhid HHID
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
 la var informal_credit "=1 if borrowed from informal credit group"
save "${tza_GHS_W4_created_data}\credit_access_2014.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${tza_GHS_W4_raw_data}\ag_sec_12b.dta",clear
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1 
ren y4_hhid HHID
ren ag12b_08 ext_acess 

tab ext_acess, missing
tab ext_acess, nolabel

replace ext_acess = 0 if ext_acess==2 | ext_acess==.
tab ext_acess, missing
collapse (max) ext_acess, by (HHID)
la var ext_acess "=1 if received advise from extension services"
save "${tza_GHS_W4_created_data}\Extension_access_2014.dta", replace




*********************************
*Demographics 
*********************************



use "${tza_GHS_W4_raw_data}\hh_sec_b.dta",clear 
merge 1:1 y4_hhid indidy4 using "${tza_GHS_W4_raw_data}\hh_sec_c.dta", gen (household)
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\hhids.dta"

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
ren y4_hhid HHID
*hh_b02 sex 
*hh_b05 relationshiop to head
*hh_b04 age (years)


sort HHID indidy4
 
gen num_mem  = 1


******** female head****

gen femhead = 0
replace femhead = 1 if hh_b02== 2 & hh_b05==1
tab femhead,missing

********Age of HHead***********
ren hh_b04 hh_age
gen hh_headage = hh_age if hh_b05==1

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

replace hh_headage_mrk = median_headage_ea_id if hh_headage_mrk ==. & num_headage_ea_id >= 456
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_region if hh_headage_mrk ==. & num_headage_region >= 456
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_stratum if hh_headage_mrk ==. & num_headage_stratum >= 456
tab hh_headage_mrk,missing
replace hh_headage_mrk = median_headage_district if hh_headage_mrk ==. & num_headage_district >= 456
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
gen finish_sec  = 1 if hh_c07 >= 32 & hh_b05==1
tab finish_sec,missing

replace pry_edu =0 if pry_edu==. & hh_b05==1
replace finish_pry =0 if finish_pry==. & hh_b05==1
replace finish_sec =0 if finish_sec==. & hh_b05==1
tab pry_edu if hh_b05==1 , missing
tab finish_pry if hh_b05==1 , missing 
tab finish_sec if hh_b05==1 , missing

collapse (sum) num_mem  (max) weight hh_headage_mrk femhead attend_sch pry_edu finish_pry finish_sec, by (HHID)
la var num_mem  "household size"
la var femhead "=1 if head is female"
la var hh_headage_mrk "age of household head in years"
la var attend_sch "=1 if respondent attended school"
la var pry_edu "=1 if household head attended pry school"
la var finish_pry "=1 if household head finished pry school"
la var finish_sec "=1 if household head finished sec school"
save "${tza_GHS_W4_created_data}\demographics_2014.dta", replace

********************************* 
*Labor Age 
*********************************

use "${tza_GHS_W4_raw_data}\hh_sec_b.dta",clear 
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
ren y4_hhid HHID
ren hh_b04 hh_age

gen worker = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort HHID
collapse (sum) worker, by (HHID)
la var worker "number of members age 15 and older and less than 65"
sort HHID

save "${tza_GHS_W4_created_data}\labor_age_2014.dta", replace


********************************
*Safety Net
********************************

use "${tza_GHS_W4_raw_data}\hh_sec_o1.dta",clear 
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
ren y4_hhid HHID
*hh_o01 received assistance
gen safety_net  =1 if hh_o01==1 
tab safety_net,missing
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (HHID)
tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${tza_GHS_W4_created_data}\safety_net_2014.dta", replace


**************
*Net Buyers and Sellers
***************
use "${tza_GHS_W4_raw_data}\HH_SEC_J1.dta",clear 
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\hhids.dta"

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
ren y4_hhid HHID
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
save "${tza_GHS_W4_created_data}\net_buyer_seller_2014.dta", replace







*****************************
*Household Assests
****************************


use "${tza_GHS_W4_raw_data}\hh_sec_m.dta",clear 
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\hhids.dta"

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1

*hh_m01 qty of items
*hh_m04 scrap value of items

gen hhasset_value = hh_m01*hh_m04
tab hhasset_value
sum hhasset_value,detail

replace hhasset_value = 7200000  if hhasset_value > 7200000  & hhasset_value <. //bottom 3%
replace hhasset_value = 2000 if hhasset_value <2000   //top 3%
tab hhasset_value,missing


collapse (sum) hhasset_value, by (y4_hhid)
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\hhids.dta"

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1

foreach v of varlist  hhasset_value  {
	_pctile `v' [aw=weight] , p(5 95) 
	gen `v'_w=`v'
	replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}

tab hhasset_value
tab hhasset_value_w, missing
sum hhasset_value hhasset_value_w, detail







ren y4_hhid HHID

keep HHID hhasset_value hhasset_value_w
la var hhasset_value "total value of household asset"
save "${tza_GHS_W4_created_data}\hhasset_value_2014.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************

use "${tza_GHS_W4_raw_data}\ag_sec_2a.dta",clear
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
*append using "${tza_GHS_W4_raw_data}\ag_sec_2b.dta", gen (short)

gen area_acres_est = ag2a_04
*replace area_acres_est = ag2b_15 if area_acres_est==.
gen area_acres_meas = ag2a_09
*replace area_acres_meas = ag2b_20 if area_acres_meas==.







gen field_size = area_acres_meas

tab field_size, missing
tab area_acres_est,missing
replace field_size = area_acres_est  if field_size==.  
tab field_size, missing

sum field_size, detail
replace field_size = 1.1 if field_size==.
tab field_size, missing


**************Top 95% is 2.5 hectares
gen field_size_ha = field_size* (1/2.47105)
tab field_size_ha, missing



collapse (sum) field_size_ha , by (y4_hhid)

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\hhids.dta", gen(hhids)

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1

foreach v of varlist  field_size_ha  {
	_pctile `v' [aw=weight] , p(5 95) 
	gen `v'_w=`v'
	replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}

tab field_size_ha
tab field_size_ha_w, missing
sum field_size_ha field_size_ha_w, detail



ren y4_hhid HHID
sort HHID
keep HHID field_size_ha field_size_ha_w
label var field_size_ha "land holding measured using gps in hectares"
save "${tza_GHS_W4_created_data}\land_holding_2014.dta", replace




*******************************
*Soil Quality
*******************************
use "${tza_GHS_W4_raw_data}\ag_sec_2a.dta",clear
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
drop filter
*append using "${tza_GHS_W4_raw_data}\ag_sec_2b.dta", gen (short)

gen area_acres_est = ag2a_04
*replace area_acres_est = ag2b_15 if area_acres_est==.
gen area_acres_meas = ag2a_09
*replace area_acres_meas = ag2b_20 if area_acres_meas==.







gen field = area_acres_meas

tab field, missing
tab area_acres_est,missing
replace field = area_acres_est  if field==.  
tab field, missing

sum field, detail
replace field = 1.1 if field==.
tab field, missing


**************Top 95% is 2.5 hectares
gen field_size_ha = field* (1/2.47105)
tab field_size_ha, missing
keep y4_hhid plotnum plotname field_size



egen any = rowmiss(plotnum)

drop if any
 
 
 
merge 1:1 y4_hhid plotnum using "${tza_GHS_W4_raw_data}\ag_sec_3a.dta"
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\hhids.dta", gen(hhids)

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
ren y4_hhid HHID

ren ag3a_11 soil_quality
tab soil_quality, missing




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


/*

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
tab soil_qty_rev2,missing*/


collapse (mean) soil_qty_rev2 , by (HHID)
la define soil 1 "Good" 2 "fair" 3 "poor"
la value soil soil_qty_rev2
la var soil_qty_rev2 "1=Good 2= Average 3=Bad "

save "${tza_GHS_W4_created_data}\soil_quality_2014.dta", replace







*******************************
*Plot Slope
*******************************
use "${tza_GHS_W4_raw_data}\ag_sec_2a.dta",clear
*append using "${tza_GHS_W4_raw_data}\ag_sec_2b.dta", gen (short)

gen area_acres_est = ag2a_04
*replace area_acres_est = ag2b_15 if area_acres_est==.
gen area_acres_meas = ag2a_09
*replace area_acres_meas = ag2b_20 if area_acres_meas==.







gen field = area_acres_meas

tab field, missing
tab area_acres_est,missing
replace field = area_acres_est  if field==.  
tab field, missing

sum field, detail
replace field = 1.1 if field==.
tab field, missing


**************Top 95% is 2.5 hectares
gen field_size_ha = field* (1/2.47105)
tab field_size_ha, missing
keep y4_hhid plotnum plotname field_size



egen any = rowmiss(plotnum)

drop if any
 
 
 
merge 1:1 y4_hhid plotnum using "${tza_GHS_W4_raw_data}\ag_sec_3a.dta"
merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\hhids.dta", gen(hhids)

merge m:1 y4_hhid using "${tza_GHS_W4_created_data}\ag_rainy_14.dta", gen(filter)

keep if ag_rainy_14==1
ren y4_hhid HHID

ren ag3a_17 slope
tab slope, missing




egen max_fieldsize = max(field_size), by (HHID)
replace max_fieldsize= . if max_fieldsize!= max_fieldsize
order field_size slope HHID max_fieldsize
sort HHID
keep if field_size== max_fieldsize
sort HHID plotnum field_size

duplicates report HHID

duplicates tag HHID, generate(dup)
tab dup
list field_size slope dup


list HHID plotnum  field_size slope dup if dup>0

egen slope_min = min(slope) 
gen plot_slope = slope

replace plot_slope = slope_min if dup>0

list HHID plotnum  field_size slope slope_min plot_slope  dup if dup>0
tab plot_slope, missing




collapse (mean) plot_slope , by (HHID)

la var plot_slope "1=flat bottom 2= flat top 3=slightly sloped 4=very steep"

save "${tza_GHS_W4_created_data}\geodata_2014.dta", replace






















************************* Merging Agricultural Datasets ********************

use "${tza_GHS_W4_created_data}\commercial_fert_2014.dta", replace


*******All observations Merged*****

merge 1:1 HHID using "${tza_GHS_W4_created_data}\subsidized_fert_2014.dta", gen (subsidized)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\savings_2014.dta", gen (savings)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\credit_access_2014.dta", gen (credit)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\Extension_access_2014.dta", gen (extension)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\demographics_2014.dta", gen (demographics)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\labor_age_2014.dta", gen (labor)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\safety_net_2014.dta", gen (safety)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\food_prices_2014.dta", gen (foodprices)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\net_buyer_seller_2014.dta", gen (net)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\soil_quality_2014.dta", gen (soil)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\geodata_2014.dta", gen (geodata)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\hhasset_value_2014.dta", gen (hhasset)
sort HHID
merge 1:1 HHID using "${tza_GHS_W4_created_data}\land_holding_2014.dta", nogen

gen year = 2014
sort HHID
save "${tza_GHS_W4_created_data}\tanzania_wave4_completedata_2014.dta", replace



tabstat total_qty subsidy_qty dist_cens tpricefert_cens_mrk num_mem hh_headage_mrk worker maize_price_mr rice_price_mr hhasset_value_w field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)

misstable summarize subsidy_dummy femhead formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2
proportion subsidy_dummy femhead formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2



