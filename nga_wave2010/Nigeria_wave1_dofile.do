

clear

global Nigeria_GHS_W1_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2010_GHSP-W1_v03_M_STATA (1)" 
global Nigeria_GHS_W1_created_data  "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\nga_wave2010"




************************
*Geodata Variables
************************
use "${Nigeria_GHS_W1_raw_data}\Geodata\NGA_PlotGeovariables_Y1.dta", clear


ren srtmslp_nga plot_slope
ren srtm_nga  plot_elevation
ren twi_nga   plot_wetness

tab1 plot_slope plot_elevation plot_wetness, missing

egen med_slope = median( plot_slope)
egen med_elevation = median( plot_elevation)
egen med_wetness = median( plot_wetness)

replace plot_slope= med_slope if plot_slope==.
replace plot_elevation= med_elevation if plot_elevation==.
replace plot_wetness= med_wetness if plot_wetness==.

collapse (sum) plot_slope plot_elevation plot_wetness, by (hhid)
sort hhid
la var plot_slope "slope of plot"
la var plot_elevation "Elevation of plot"
la var plot_wetness "Potential wetness index of plot"
save "${Nigeria_GHS_W1_created_data}\geodata.dta", replace


****************************
*Subsidized Fertilizer
****************************
use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Agriculture\sect11d_plantingw1.dta",clear 
*graph bar (count), over(s11dq13)

*s11dq13 1st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq24 2st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq40     		source of org purchased fertilizer (1=govt, 2=private)
*s11dq15 s11dq26  qty of inorg purchased fertilizer
*s11dq19  s11dq29	value of inorg purchased fertilizer




encode s11dq13, gen(institute)
label list institute


encode s11dq24, gen(institute2)
label list institute2

*************Checking to confirm its the subsidized price *******************

gen pricefert = s11dq18/ s11dq15


gen subsidy_check = pricefert if institute ==4

sum subsidy,detail


gen private_check = pricefert if institute ==6
sum private,detail



*************Getting Subsidized quantity and Dummy Variable *******************
gen subsidy_qty1 = s11dq15 if institute ==4
tab subsidy_qty1
gen subsidy_qty2 = s11dq26 if institute2 ==4
tab subsidy_qty2


egen subsidy_qty = rowtotal(subsidy_qty1 subsidy_qty2)  //or should we replace with the second qty (s11dq26), where the first qty is missing (s11dq15==.)
tab subsidy_qty,missing
sum subsidy_qty,detail


gen subsidy_dummy = 0
replace subsidy_dummy = 1 if institute==4
tab subsidy_dummy, missing
replace subsidy_dummy = 1 if institute2==4
tab subsidy_dummy, missing




collapse (sum)subsidy_qty (max) subsidy_dummy, by (hhid)
label var subsidy_qty "Quantity of Fertilizer Purchased in kg"
label var subsidy_dummy "=1 if acquired any subsidied fertilizer"
save "${Nigeria_GHS_W1_created_data}\subsidized_fert.dta", replace




******************************* 
*Purchased Fertilizer
*******************************

use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Agriculture\sect11d_plantingw1.dta",clear 

*graph bar (count), over(s11dq13)

*s11dq13 1st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq24 2st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq40     		source of org purchased fertilizer (1=govt, 2=private)
*s11dq15 s11dq26  qty of inorg purchased fertilizer
*s11dq19  s11dq29	value of inorg purchased fertilizer





encode s11dq13, gen(institute)
label list institute


encode s11dq24, gen(institute2)
label list institute2


***fertilzer total quantity, total value & total price***

gen private_fert1_qty = s11dq15 if institute ==6
tab private_fert1_qty
gen private_fert2_qty = s11dq26 if institute2 ==6
tab private_fert2_qty

gen private_fert1_val = s11dq18 if institute ==6

egen val2_cens = median (s11dq31)
tab val2_cens
replace s11dq31= val2_cens if s11dq31==.
tab s11dq31
gen private_fert2_val = s11dq31 if institute2 ==6
tab private_fert2_val



egen total_qty = rowtotal(private_fert1_qty private_fert2_qty)
tab  total_qty, missing

egen total_valuefert = rowtotal(private_fert1_val private_fert2_val)
tab total_valuefert,missing

gen tpricefert = total_valuefert/total_qty
tab tpricefert


gen tpricefert_cens = tpricefert 
replace tpricefert_cens = 500 if tpricefert_cens > 500 & tpricefert_cens < .
replace tpricefert_cens = 20 if tpricefert_cens < 20
tab tpricefert_cens, missing
*graph box total_valuefert if total_valuefert!=0
*hist total_valuefert, normal width(5)




egen medianfert_pr_ea = median(tpricefert_cens), by (ea)

egen medianfert_pr_lga = median(tpricefert_cens), by (lga)

egen num_fert_pr_ea = count(tpricefert_cens), by (ea)

egen num_fert_pr_lga = count(tpricefert_cens), by (lga)

egen medianfert_pr_state = median(tpricefert_cens), by (state)
egen num_fert_pr_state = count(tpricefert_cens), by (state)

egen medianfert_pr_zone = median(tpricefert_cens), by (zone)
egen num_fert_pr_zone = count(tpricefert_cens), by (zone)



tab medianfert_pr_ea
tab medianfert_pr_lga
tab medianfert_pr_state
tab medianfert_pr_zone



tab num_fert_pr_ea
tab num_fert_pr_lga
tab num_fert_pr_state
tab num_fert_pr_zone

gen tpricefert_cens_mrk = tpricefert_cens

replace tpricefert_cens_mrk = medianfert_pr_ea if tpricefert_cens_mrk ==. & num_fert_pr_ea >= 7

tab tpricefert_cens_mrk


replace tpricefert_cens_mrk = medianfert_pr_lga if tpricefert_cens_mrk ==. & num_fert_pr_lga >= 7

tab tpricefert_cens_mrk



replace tpricefert_cens_mrk = medianfert_pr_state if tpricefert_cens_mrk ==. & num_fert_pr_state >= 7

tab tpricefert_cens_mrk


replace tpricefert_cens_mrk = medianfert_pr_zone if tpricefert_cens_mrk ==. & num_fert_pr_zone >= 7

tab tpricefert_cens_mrk

***************
*organic fertilizer
***************
gen org_fert = 1 if  s11dq3==3 | s11dq7==3 | s11dq14==3 |  s11dq25==3
tab org_fert, missing
replace org_fert = 0 if org_fert==.
tab org_fert, missing



collapse (sum) total_qty total_valuefert (max) org_fert tpricefert_cens_mrk, by(hhid)
la var org_fert "1 = if used organic fertilizer"
label var total_qty "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk "price of commercial fertilizer purchased in naira"
sort hhid
save "${Nigeria_GHS_W1_created_data}\purchasefert.dta", replace



***************************
*Savings 
*************************

use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Household\sect4_plantingw1.dta",clear 


*s4q1  1= formal bank account
*s4q5b  s4q5d   s4q5f  types of formal fin institute used to save 
*s4q6   1= used informal saving group

ren s4q1 formal_bank
tab formal_bank, missing
replace formal_bank =0 if formal_bank ==2 | formal_bank ==.
tab formal_bank, nolabel
tab formal_bank,missing

 gen formal_save = 1 if s4q5b !=. | s4q5d !=.| s4q5f !=.
 tab formal_save, missing
 replace formal_save = 0 if formal_save ==.
 tab formal_save, missing

 ren s4q6 informal_save
 tab informal_save, missing
 replace informal_save =0 if informal_save ==2 | informal_save ==.
 tab informal_save, missing

 collapse (max) formal_bank formal_save informal_save, by (hhid)
 la var formal_bank "=1 if respondent have an account in bank"
 la var formal_save "=1 if used formal saving group"
 la var informal_save "=1 if used informal saving group"
save "${Nigeria_GHS_W1_created_data}\savings.dta", replace



***************************
*Credit access 
***************************

use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Household\sect4_plantingw1.dta",clear 

*s4q8b  s4q8d   s4q8f   types of formal fin institute used to borrow 
*s4q9      1= used inoformal group to borrow money


 gen formal_credit =1 if s4q8b !=. | s4q8d !=. | s4q8f !=.
 tab formal_credit,missing
 replace formal_credit =0 if formal_credit ==.
 tab formal_credit,missing
 
 ren  s4q9 informal_credit
 tab informal_credit, missing
 replace informal_credit =0 if informal_credit ==2 | informal_credit ==.
 tab informal_credit,missing


 collapse (max) formal_credit informal_credit, by (hhid)
 la var formal_credit "=1 if borrowed from formal credit group"
 la var informal_credit "=1 if borrowed from informal credit group"
save "${Nigeria_GHS_W1_created_data}\credit_access.dta", replace


*****************************
*Community 
****************************

use "${Nigeria_GHS_W1_raw_data}\Post Harvest Wave 1\Community\sectc2_harvestw1.dta", clear
*is_cd  219 for market infrastructure
*sc2q3  distance to infrastructure in km

gen mrk_dist = sc2q3 if is_cd==219
tab mrk_dist,missing
egen median_lga = median(mrk_dist), by (zone state lga)
egen median_state = median(mrk_dist), by (zone state)
egen median_zone = median(mrk_dist), by (zone)


replace mrk_dist =0 if is_cd==219 & mrk_dist==. & sc2q1==1
tab mrk_dist if is_cd==219, missing

replace mrk_dist = median_lga if mrk_dist==. & is_cd==219
replace mrk_dist = median_state if mrk_dist==. & is_cd==219
replace mrk_dist = median_zone if mrk_dist==. & is_cd==219
tab mrk_dist if is_cd==219, missing

replace mrk_dist= 45 if mrk_dist>=45 & mrk_dist<. & is_cd==219
tab mrk_dist if is_cd==219, missing

sort zone state ea
collapse (max) median_lga median_state median_zone mrk_dist, by (zone state lga sector ea)
replace mrk_dist = median_lga if mrk_dist ==.
tab mrk_dist, missing
replace mrk_dist = median_lga if mrk_dist ==.
tab mrk_dist, missing
la var mrk_dist "=distance to the market"

save "${Nigeria_GHS_W1_created_data}\market_distance.dta", replace 




***************************** 
*Extension Visit 
*******************************
use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Agriculture\sect11l1_plantingw1.dta", clear



ren s11lq1 ext_acess
collapse (max) ext_acess, by (hhid)
la var ext_acess "=1 if received advise from extension services"
save "${Nigeria_GHS_W1_created_data}\extension_visit.dta", replace 


******************************** 
*Demographics 
*********************************
use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Household\sect1_plantingw1.dta", clear

merge 1:1 hhid indiv using "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Household\sect2_plantingw1.dta", gen(household)

merge m:1 zone state lga sector ea using "${Nigeria_GHS_W1_created_data}\market_distance.dta", keepusing (median_lga median_state median_zone mrk_dist)


**************
*market distance
*************
replace mrk_dist = median_lga if mrk_dist==.
tab mrk_dist, missing

replace mrk_dist = median_state if mrk_dist==.
tab mrk_dist, missing

replace mrk_dist = median_zone if mrk_dist==.
tab mrk_dist, missing




*s1q2   sex
*s1q3   relationship to hhead
*s1q4   age in years


sort hhid indiv 
 
gen num_mem = 1


******** female head****

gen femhead = 0
replace femhead = 1 if s1q2== 2 & s1q3==1

********Age of HHead***********
ren s1q4 hh_age
gen hh_headage = hh_age if s1q3==1

tab hh_headage

replace hh_headage = 100 if hh_headage > 100 & hh_headage < .
tab hh_headage
tab hh_headage, missing

************generating the median age**************

egen medianhh_pr_ea = median(hh_headage), by (ea)

egen medianhh_pr_lga = median(hh_headage), by (lga)

egen num_hh_pr_ea = count(hh_headage), by (ea)

egen num_hh_pr_lga = count(hh_headage), by (lga)

egen medianhh_pr_state = median(hh_headage), by (state)
egen num_hh_pr_state = count(hh_headage), by (state)

egen medianhh_pr_zone = median(hh_headage), by (zone)
egen num_hh_pr_zone = count(hh_headage), by (zone)


tab medianhh_pr_ea
tab medianhh_pr_lga
tab medianhh_pr_state
tab medianhh_pr_zone



tab num_hh_pr_ea
tab num_hh_pr_lga
tab num_hh_pr_state
tab num_hh_pr_zone



replace hh_headage = medianhh_pr_ea if hh_headage ==. & num_hh_pr_ea >= 30

tab hh_headage,missing


replace hh_headage = medianhh_pr_lga if hh_headage ==. & num_hh_pr_lga >= 30

tab hh_headage,missing



replace hh_headage = medianhh_pr_state if hh_headage ==. & num_hh_pr_state >= 30

tab hh_headage,missing


replace hh_headage = medianhh_pr_zone if hh_headage ==. & num_hh_pr_zone >= 30

tab hh_headage,missing

sum hh_headage, detail



********************Education****************************************************


*s2q4  1= attended school
*s2q7  highest education level
*s1q3 relationship to hhead

ren s2q4 attend_sch
tab attend_sch
replace attend_sch = 0 if attend_sch ==2
tab attend_sch, nolabel
*tab s1q4 if s2q7==.

replace s2q7= 0 if attend_sch==0
tab s2q7
tab s1q3 if _merge==1

tab s2q7 if s1q3==1
replace s2q7 = 16 if s2q7==. &  s1q3==1

*** Education Dummy Variable*****

 label list s2q7

gen pry_edu = 1 if s2q7 >= 1 & s2q7 < 16 & s1q3==1
gen finish_pry = 1 if s2q7 >= 16 & s2q7 < 26 & s1q3==1
gen finish_sec = 1 if s2q7 >= 26 & s2q7 < 43 & s1q3==1

replace pry_edu =0 if pry_edu==. & s1q3==1
replace finish_pry =0 if finish_pry==. & s1q3==1
replace finish_sec =0 if finish_sec==. & s1q3==1
tab pry_edu if s1q3==1 , missing
tab finish_pry if s1q3==1 , missing 
tab finish_sec if s1q3==1 , missing

collapse (sum) num_mem (max) mrk_dist hh_headage femhead attend_sch pry_edu finish_pry finish_sec, by (hhid)
la var num_mem "household size"
la var mrk_dist "distance to the nearest market in km"
la var femhead "=1 if head is female"
la var hh_headage "age of household head in years"
la var attend_sch "=1 if respondent attended school"
la var pry_edu "=1 if household head attended pry school"
la var finish_pry "=1 if household head finished pry school"
la var finish_sec "=1 if household head finished sec school"
save "${Nigeria_GHS_W1_created_data}\demographics.dta", replace




********************************* 
*Labor Age 
*********************************
use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Household\sect1_plantingw1.dta", clear
ren s1q4 hh_age

gen worker = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker
sort hhid
collapse (sum) worker, by (hhid)
la var worker "number of members age 15 and older and less than 65"
sort hhid

save "${Nigeria_GHS_W1_created_data}\labor_age.dta", replace



********************************
*Safety Net
*****************************
use "${Nigeria_GHS_W1_raw_data}\Post Harvest Wave 1\Household\sect14_harvestw1.dta", clear

gen safety_net = 0
replace safety_net =1 if s14q1 ==1
tab safety_net
collapse (max) safety_net, by (hhid)
tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${Nigeria_GHS_W1_created_data}\safety_net.dta", replace


**************************************
*Food Prices
**************************************


use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Community\sectc2_plantingw1.dta", clear

*s7bq3a   qty purchased by household (7days)
*sc2q3c     units purchased by household (7days)
*s7bq4    cost of purchase by household (7days)




*********Getting the price for maize only**************
//   Unit           Conversion Factor for maize







gen conversion =1
tab conversion, missing
gen food_size=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion = food_size*0.087 if sc2q3c== 1
replace conversion = food_size*0.175 if  sc2q3c== 2		
replace conversion = food_size*0.23 if  sc2q3c== 3
replace conversion = food_size*0.35 if  sc2q3c== 4	
replace conversion = food_size*0.70 if  sc2q3c== 5
replace conversion = food_size*1.50 if  sc2q3c== 6
replace conversion = food_size*3.00 if  sc2q3c== 7
replace conversion = food_size*20.0 if  sc2q3c== 11	
replace conversion = food_size*50.0 if  sc2q3c== 12
replace conversion = food_size*100 if   sc2q3c== 13	
replace conversion = food_size*120 if   sc2q3c== 14
replace conversion = food_size*30.0 if  sc2q3c== 22		
replace conversion = food_size*10.0 if  sc2q3c== 31
replace conversion = food_size*25 if   sc2q3c== 32	
replace conversion = food_size*40 if   sc2q3c== 33
replace conversion = food_size*3.0 if  sc2q3c== 51					
tab conversion, missing	



gen food_price_maize = sc2q3b* conversion if item_cd==12

gen maize_price = sc2q3a/food_price_maize if item_cd==12  

*br  sc2q3b conversion sc2q3c sc2q3a  food_price_maize maize_price item_cd if item_cd<=17

tab maize_price,missing
sum maize_price,detail
tab maize_price

replace maize_price = 170 if maize_price >170 & maize_price<.  //bottom 5%
replace maize_price = 10 if maize_price< 10        ////top 5%



egen median_pr_ea = median(maize_price), by (ea)
egen median_pr_lga = median(maize_price), by (lga)
egen median_pr_state = median(maize_price), by (state)
egen median_pr_zone = median(maize_price), by (zone)

egen num_pr_ea = count(maize_price), by (ea)
egen num_pr_lga = count(maize_price), by (lga)
egen num_pr_state = count(maize_price), by (state)
egen num_pr_zone = count(maize_price), by (zone)

tab num_pr_ea
tab num_pr_lga
tab num_pr_state
tab num_pr_zone


gen maize_price_mr = maize_price

replace maize_price_mr = median_pr_ea if maize_price_mr==. & num_pr_ea>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_lga if maize_price_mr==. & num_pr_lga>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_state if maize_price_mr==. & num_pr_state>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_zone if maize_price_mr==. & num_pr_zone>=2
tab maize_price_mr,missing



*********Getting the price for rice only**************
//   Unit           Conversion Factor for maize






gen food_price_rice = sc2q3b* conversion if item_cd==14

gen rice_price = sc2q3a/food_price_rice if item_cd==14

*br  sc2q3b conversion sc2q3c sc2q3a  food_price_rice rice_price item_cd if item_cd==14

sum rice_price,detail
tab rice_price

replace rice_price = 300 if rice_price >300 & rice_price<.   //bottom 3%
replace rice_price = 25 if rice_price< 25   //top 3%
tab rice_price,missing



egen median_rice_ea = median(rice_price), by (ea)
egen median_rice_lga = median(rice_price), by (lga)
egen median_rice_state = median(rice_price), by (state)
egen median_rice_zone = median(rice_price), by (zone)

egen num_rice_ea = count(rice_price), by (ea)
egen num_rice_lga = count(rice_price), by (lga)
egen num_rice_state = count(rice_price), by (state)
egen num_rice_zone = count(rice_price), by (zone)

tab num_rice_ea
tab num_rice_lga
tab num_rice_state
tab num_rice_zone


gen rice_price_mr = rice_price

replace rice_price_mr = median_rice_ea if rice_price_mr==. & num_rice_ea>=7
tab rice_price_mr,missing

replace rice_price_mr = median_rice_lga if rice_price_mr==. & num_rice_lga>=7
tab rice_price_mr,missing

replace rice_price_mr = median_rice_state if rice_price_mr==. & num_rice_state>=7
tab rice_price_mr,missing

replace rice_price_mr = median_rice_zone if rice_price_mr==. & num_rice_zone>=7
tab rice_price_mr,missing


sort zone state ea
collapse (max) maize_price_mr rice_price_mr  median_pr_lga median_pr_state median_pr_zone median_pr_ea , by (zone state lga sector ea)


save "${Nigeria_GHS_W1_created_data}\food_prices.dta", replace



**************
*Net Buyers and Sellers
***************
use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Household\sect7b_plantingw1.dta", clear
merge m:1 zone state lga sector ea using "${Nigeria_GHS_W1_created_data}\food_prices.dta", keepusing (median_pr_ea median_pr_lga median_pr_state median_pr_zone maize_price_mr rice_price_mr)

**************
*maize price
*************

replace maize_price_mr = median_pr_ea if maize_price_mr==.
tab maize_price_mr, missing

replace maize_price_mr = median_pr_lga if maize_price_mr==.
tab maize_price_mr, missing

replace maize_price_mr = median_pr_state if maize_price_mr==.
tab maize_price_mr, missing

replace maize_price_mr = median_pr_zone if maize_price_mr==.
tab maize_price_mr, missing







*s7bq3a from purchases
*s7bq5a from own production

tab s7bq5a
tab s7bq3a

replace s7bq5a = 0 if s7bq5a<=0 |s7bq5a==.
tab s7bq5a,missing
replace s7bq3a = 0 if s7bq3a<=0 |s7bq3a==.
tab s7bq3a,missing

gen net_seller = 1 if s7bq5a > s7bq3a
tab net_seller,missing
replace net_seller=0 if net_seller==.
tab net_seller,missing

gen net_buyer = 1 if s7bq5a < s7bq3a
tab net_buyer,missing
replace net_buyer=0 if net_buyer==.
tab net_buyer,missing


collapse  (max) maize_price_mr rice_price_mr net_seller net_buyer, by(hhid)
label var maize_price_mr "commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"
sort hhid
save "${Nigeria_GHS_W1_created_data}\net_buyer_seller.dta", replace


*****************************
*Household Assests
****************************


use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Household\sect5_plantingw1.dta", clear

sort hhid item_cd

collapse (sum) s5q1, by (hhid item_cd)
tab item_cd
save "${Nigeria_GHS_W1_created_data}\assest_qty.dta", replace

use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Household\sect5b_plantingw1.dta", clear

collapse (mean) s5q4, by (hhid item_cd)
tab item_cd
save "${Nigeria_GHS_W1_created_data}\assest_cost.dta", replace

*******************Merging assest***********************
sort hhid item_cd
merge 1:1 hhid item_cd using "${Nigeria_GHS_W1_created_data}\assest_qty.dta"

drop _merge
gen hhasset_value = s5q4*s5q1
collapse (sum) hhasset_value, by (hhid)
la var hhasset_value "total value of household asset"
save "${Nigeria_GHS_W1_created_data}\assest_value.dta", replace





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
save "${Nigeria_GHS_W1_created_data}\land_cf.dta", replace

 
 
 
 
 
 
 *************** Plot Size **********************

use "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Agriculture\sect11a1_plantingw1.dta", clear
*merging in planting section to get cultivated status
merge 1:1 hhid plotid using  "${Nigeria_GHS_W1_raw_data}\Post Planting Wave 1\Agriculture\sect11b_plantingw1.dta"
*merging in harvest section to get areas for new plots
merge 1:1 hhid plotid using "${Nigeria_GHS_W1_raw_data}\Post Harvest Wave 1\Agriculture\secta1_harvestw1.dta", gen(plot_merge)

 
ren s11aq4a area_size
ren s11aq4b area_unit
ren sa1q9a area_size2
ren sa1q9b area_unit2
ren s11aq4d area_meas_sqm
ren sa1q9d area_meas_sqm2

*If land was cultivated by household, then cultivate is equal to 1
gen cultivate = s11bq16 ==1 
tab cultivate
*assuming new plots are cultivated
replace cultivate = 1 if sa1q3==1
tab cultivate


******Merging data with the conversion factor
merge m:1 zone area_unit using "${Nigeria_GHS_W1_created_data}\land_cf.dta", nogen keep(1 3) 


 
 *farmer reported field size for post-planting
gen field_size= area_size*conversion
 sum field_size, detail
*replacing farmer reported with GPS if
replace field_size = area_meas_sqm*0.0001 if area_meas_sqm!=.  
 sum field_size, detail 
 
 gen gps_meas = (area_meas_sqm!=. | area_meas_sqm2!=.)
la var gps_meas "Plot was measured with GPS, 1=Yes"
tab gps_meas
 
 
 
 ***************Measurement in hectares for the additional plots from post-harvest************
 *farmer reported field size for post-harvest added fields
drop area_unit conversion
ren area_unit2 area_unit
******Merging data with the conversion factor
merge m:1 zone area_unit using "${Nigeria_GHS_W1_created_data}\land_cf.dta", nogen keep(1 3) 

replace field_size= area_size2*conversion if field_size==.
*replacing farmer reported with GPS if available
replace field_size = area_meas_sqm2*0.0001 if area_meas_sqm2!=.               
la var field_size "Area of plot (ha)"
ren plotid plot_id
sum field_size, detail
*Total land holding including cultivated and rented out
collapse (sum) field_size, by (hhid)
sort hhid
ren field_size land_holding
label var land_holding "land holding in hectares"
save "${Nigeria_GHS_W1_created_data}\land_holdings.dta", replace

 

* FARM SIZE/LAND SIZE *
********************************************************************************
//some plot areas are missing in NG wave 1, replacing with area planted if plot size is missing
*Starting with area planted
*use "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\NGA_2010_GHSP-W1_v03_M_STATA (1)\Post Planting Wave 1\Agriculture\sect11f_plantingw1.dta", clear

*ren plotid plot_id
*Merging in gender of plot manager
*merge m:1 plot_id hhid using "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\land_holdings.dta", nogen keep(1 3)

*gen ha_planted = s11fq1a*conversion
*collapse (sum) ha_planted, by (hhid) 
*save "C:\Users\obine\OneDrive\Documents\Smallholder lsms STATA\analyzed_data\planted_areas.dta", replace








************************* Merging Agricultural Datasets ********************

use "${Nigeria_GHS_W1_created_data}\purchasefert.dta", replace


*******All observations Merged*****


merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\subsidized_fert.dta", gen (subsidized)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\savings.dta", gen (savings)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\credit_access.dta", gen (credit)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\extension_visit.dta", gen (extension)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\demographics.dta", gen (demographics)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\labor_age.dta", gen (labor)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\safety_net.dta", gen (safety)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\assest_value.dta", gen (asset)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\net_buyer_seller.dta", gen (foodprices)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\geodata.dta", gen (geodata)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W1_created_data}\land_holdings.dta"
gen year = 2010
sort hhid
save "${Nigeria_GHS_W1_created_data}\Nigeria_wave1_complete_data.dta", replace

