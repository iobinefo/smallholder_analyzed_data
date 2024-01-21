










clear



global Nigeria_GHS_W3_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2015_GHSP-W3_v02_M_Stata"
global Nigeria_GHS_W3_created_data  "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\nga_wave2015"



************************
*Geodata Variables
************************

use "${Nigeria_GHS_W3_raw_data}\NGA_PlotGeovariables_Y3.dta", clear


ren srtmslp_nga plot_slope
ren srtm_nga  plot_elevation
ren twi_nga   plot_wetness

tab1 plot_slope plot_elevation plot_wetness, missing

egen med_slope_ea = median( plot_slope),by (ea)
egen med_slope_lga = median( plot_slope),by (lga)
egen med_slope_state = median( plot_slope),by (state)
egen med_slope_zone = median( plot_slope),by (zone)
egen med_elevation_ea = median( plot_elevation), by (ea)
egen med_elevation_lga = median( plot_elevation), by (lga)
egen med_elevation_state = median( plot_elevation), by (state)
egen med_elevation_zone = median( plot_elevation), by (zone)
egen med_wetness_ea = median( plot_wetness), by (ea)
egen med_wetness_lga = median( plot_wetness), by (lga)
egen med_wetness_state = median( plot_wetness), by (state)
egen med_wetness_zone = median( plot_wetness), by (zone)

replace plot_slope= med_slope_ea if plot_slope==.
replace plot_slope= med_slope_lga if plot_slope==.
replace plot_slope= med_slope_state if plot_slope==.
replace plot_slope= med_slope_zone if plot_slope==.
replace plot_elevation= med_elevation_ea if plot_elevation==.
replace plot_elevation= med_elevation_lga if plot_elevation==.
replace plot_elevation= med_elevation_state if plot_elevation==.
replace plot_elevation= med_elevation_zone if plot_elevation==.
replace plot_wetness= med_wetness_ea if plot_wetness==.
replace plot_wetness= med_wetness_lga if plot_wetness==.
replace plot_wetness= med_wetness_state if plot_wetness==.
replace plot_wetness= med_wetness_zone if plot_wetness==.

tab1 plot_slope plot_elevation plot_wetness, missing

collapse (sum) plot_slope plot_elevation plot_wetness, by (hhid)
sort hhid
la var plot_slope "slope of plot"
la var plot_elevation "Elevation of plot"
la var plot_wetness "Potential wetness index of plot"
save "${Nigeria_GHS_W3_created_data}\geodata_2015.dta", replace
















****************************
*Subsidized Fertilizer
****************************

use "${Nigeria_GHS_W3_raw_data}\secta11d_harvestw3.dta",clear 


*s11dq14 1st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq26 2st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq40     		source of org purchased fertilizer (1=govt, 2=private)
*s11dq16a s11dq28a  qty of inorg purchased fertilizer
*s11dq16b s11dq28b  units for inorg purchased fertilizer
*s11dq19  s11dq29	value of inorg purchased fertilizer

*************Checking to confirm its the subsidized price *******************


encode s11dq14, gen(institute)
label list institute

encode s11dq26, gen(institute2)
label list institute2

*encode s11dq40, gen(institute3)
*label list institute3

label list s11dq16b
******conversion from gram to kilogram
replace s11dq16a = 0.001*s11dq16a if s11dq16b==2
tab s11dq16a
replace s11dq28a = 0.001*s11dq28a if s11dq28b==2
tab s11dq28a
*replace s11dq37a = 0.001*s11dq37a if s11dq37b==2
*tab s11dq37a



gen pricefert = s11dq19/ s11dq16a


gen subsidy_check = pricefert if institute ==1

sum subsidy_check,detail


gen private_check = pricefert if institute ==2
sum private_check,detail

*************Getting Subsidized quantity and Dummy Variable *******************

gen subsidy_qty1 = s11dq16a if institute ==1
tab subsidy_qty1
gen subsidy_qty2 = s11dq28a if institute2 ==1
tab subsidy_qty2
*gen subsidy_qty3 = s11dq37a if institute3==1
*tab subsidy_qty3

egen subsidy_qty = rowtotal(subsidy_qty1 subsidy_qty2)
tab subsidy_qty,missing
sum subsidy_qty,detail


gen subsidy_dummy = 0
replace subsidy_dummy = 1 if institute==1
tab subsidy_dummy, missing
replace subsidy_dummy = 1 if institute2==1
tab subsidy_dummy, missing
*replace subsidy_dummy = 1 if institute3==1
*tab subsidy_dummy, missing

collapse (sum)subsidy_qty (max) subsidy_dummy, by (hhid)
label var subsidy_qty "Quantity of Fertilizer Purchased in kg"
label var subsidy_dummy "=1 if acquired any subsidied fertilizer"
save "${Nigeria_GHS_W3_created_data}\subsidized_fert_2015.dta", replace





*****************************************
*E-Wallet Subsidized Fertilizer
*****************************************
use "${Nigeria_GHS_W3_raw_data}\secta11d_harvestw3.dta",clear 

*s11dq5a    1= received e-wallet subsidy
*s11dq5c1	qty of e-wallet subsidized fertilizer used on plot
*s11dq5c2   units of e-wallet subsiidy (all in kg)
*s11dq5d    total payment for e-wallet subsidy fertilizer

ren s11dq5a esubsidy_dummy 
tab esubsidy_dummy,missing
tab esubsidy_dummy, nolabel
replace esubsidy_dummy =0 if esubsidy_dummy==2 | esubsidy_dummy==.
tab esubsidy_dummy,missing
tab esubsidy_dummy, nolabel


ren s11dq5c1 esubsidy_qty 
tab esubsidy_qty, missing
replace esubsidy_qty =0 if esubsidy_qty==.








collapse (sum)esubsidy_qty (max) esubsidy_dummy, by (hhid)

label var esubsidy_qty "Quantity of E-wallet Fertilizer Purchased in kg"
label var esubsidy_dummy "=1 if acquired the E-wallet subsidied fertilizer"
save "${Nigeria_GHS_W3_created_data}\E-wallet_subsidized_fert_2015.dta", replace








*********************************************** 
*Purchased Fertilizer
***********************************************

use "${Nigeria_GHS_W3_raw_data}\secta11d_harvestw3.dta",clear 


*s11dq14 1st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq26 2st 		source of inorg purchased fertilizer (1=govt, 2=private)
*s11dq40     		source of org purchased fertilizer (1=govt, 2=private)
*s11dq16a s11dq28a  qty of inorg purchased fertilizer
*s11dq16b s11dq28b  units for inorg purchased fertilizer
*s11dq19  s11dq29	value of inorg purchased fertilizer

encode s11dq14, gen(institute)
label list institute
encode s11dq26, gen(institute2)
label list institute2

encode s11dq40, gen(institute3)
label list institute3


*****Coversion of fertilizer's gram into kilogram using 0.001
replace s11dq16a = 0.001*s11dq16a if s11dq16b==2
tab s11dq16a

replace s11dq28a = 0.001*s11dq28a if s11dq28b==2
tab s11dq28a


*replace s11dq37a = 0.001*s11dq37a if s11dq37b==2
*tab s11dq37a



***fertilzer total quantity, total value & total price****

gen private_fert1_qty = s11dq16a if institute ==2
tab private_fert1_qty, missing
gen private_fert2_qty = s11dq28a if institute2 ==2
tab private_fert2_qty,missing
*gen private_fert3_qty = s11dq37a if institute3 ==2
*tab private_fert3_qty,missing

gen private_fert1_val = s11dq19 if institute ==2
tab private_fert1_val,missing
gen private_fert2_val = s11dq29 if institute2 ==2
tab private_fert2_val,missing
*gen private_fert3_val = s11dq39 if institute3 ==2
*tab private_fert3_val,missing

egen total_qty  = rowtotal(private_fert1_qty private_fert2_qty)
tab  total_qty, missing

egen total_valuefert  = rowtotal(private_fert1_val private_fert2_val)
tab total_valuefert,missing

gen tpricefert  = total_valuefert /total_qty 
tab tpricefert , missing

gen tpricefert_cens = tpricefert  
replace tpricefert_cens = 1000 if tpricefert_cens > 1000 & tpricefert_cens < .
replace tpricefert_cens = 22 if tpricefert_cens < 22
tab tpricefert_cens, missing





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

tab tpricefert_cens_mrk,missing


replace tpricefert_cens_mrk = medianfert_pr_lga if tpricefert_cens_mrk ==. & num_fert_pr_lga >= 7

tab tpricefert_cens_mrk,missing



replace tpricefert_cens_mrk = medianfert_pr_state if tpricefert_cens_mrk ==. & num_fert_pr_state >= 7

tab tpricefert_cens_mrk,missing


replace tpricefert_cens_mrk = medianfert_pr_zone if tpricefert_cens_mrk ==. & num_fert_pr_zone >= 7

tab tpricefert_cens_mrk,missing


***************
*organic fertilizer
***************
gen org_fert = 1 if  s11dq36==1
tab org_fert, missing
replace org_fert = 0 if org_fert==.
tab org_fert, missing



collapse (sum) total_qty  total_valuefert  (max) org_fert tpricefert_cens_mrk, by(hhid)
la var org_fert "1= if used organic fertilzer"
label var total_qty "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var tpricefert_cens_mrk "price of commercial fertilizer purchased in naira"
sort hhid
save "${Nigeria_GHS_W3_created_data}\purchased_fert_2015.dta", replace




************************************************
*Savings 
************************************************



use "${Nigeria_GHS_W3_raw_data}\sect4a_plantingw3.dta",clear 

*s4aq1 1= have a bank account
*s4aq9b s4aq9d s4aq9f types of fin institute used to save money


*s4aq10 1= used informal saving group



ren s4aq1 formal_bank 
tab formal_bank, missing
replace formal_bank =0 if formal_bank ==2 | formal_bank ==.
tab formal_bank, nolabel
tab formal_bank,missing

 gen formal_save  = 1 if s4aq9b !=. | s4aq9d !=.
 tab formal_save, missing
 replace formal_save = 0 if formal_save ==.
 tab formal_save, missing

 ren s4aq10 informal_save 
 tab informal_save, missing
 replace informal_save =0 if informal_save ==2 | informal_save ==.
 tab informal_save, missing

 collapse (max) formal_bank  formal_save  informal_save, by (hhid)
 la var formal_bank "=1 if respondent have an account in bank"
 la var formal_save  "=1 if used formal saving group"
 la var informal_save "=1 if used informal saving group"
save "${Nigeria_GHS_W3_created_data}\savings_2015.dta", replace



*******************************************************
*Credit access 
*******************************************************

use "${Nigeria_GHS_W3_raw_data}\sect4c2_plantingw3.dta",clear 

*s4cq2b types of money lenders (<=4 for formal lenders)
*s4cq5  1= already received loan


 
label list s4cq2b
 gen formal_credit  =1 if s4cq2b <=4 & s4cq5==1
 tab formal_credit,missing
 replace formal_credit =0 if formal_credit ==.
 tab formal_credit,missing
 
 gen informal_credit  =1 if s4cq2b >=5 & s4cq5==1

 tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
 tab informal_credit,missing


 collapse (max) formal_credit  informal_credit, by (hhid)
 la var formal_credit  "=1 if borrowed from formal credit group"
 la var informal_credit  "=1 if borrowed from informal credit group"
save "${Nigeria_GHS_W3_created_data}\credit_access_2015.dta", replace





******************************* 
*Extension Visit 
*******************************


use "${Nigeria_GHS_W3_raw_data}\sect11l1_plantingw3.dta",clear 

merge 1:1 hhid topic_cd using "${Nigeria_GHS_W3_raw_data}\secta5a_harvestw3.dta"

replace s11l1q1=1 if s11l1q1==. & sa5aq1==1
ren s11l1q1 ext_acess 

tab ext_acess, missing
tab ext_acess, nolabel

replace ext_acess = 0 if ext_acess==2 | ext_acess==.
tab ext_acess, missing
collapse (max) ext_acess, by (hhid)
la var ext_acess "=1 if received advise from extension services"
save "${Nigeria_GHS_W3_created_data}\extension_access_2015.dta", replace




*****************************
*Community 
****************************

use "${Nigeria_GHS_W3_raw_data}\sectc2_harvestw3.dta", clear
*is_cd  219 for market infrastructure
*c2q3  distance to infrastructure in km

gen mrk_dist = c2q3 if is_cd==222
tab mrk_dist if is_cd==222, missing
egen median_lga = median(mrk_dist), by (zone state lga)
egen median_state = median(mrk_dist), by (zone state)
egen median_zone = median(mrk_dist), by (zone)


replace mrk_dist =0 if is_cd==222 & mrk_dist==. & c2q1==1
tab mrk_dist if is_cd==222, missing

replace mrk_dist = median_lga if mrk_dist==. & is_cd==222
replace mrk_dist = median_state if mrk_dist==. & is_cd==222
replace mrk_dist = median_zone if mrk_dist==. & is_cd==222
tab mrk_dist if is_cd==222, missing

replace mrk_dist= 50 if mrk_dist>=50 & mrk_dist<. & is_cd==222
tab mrk_dist if is_cd==222, missing

sort zone state ea
collapse (max) median_lga median_state median_zone mrk_dist, by (zone state lga sector ea)
replace mrk_dist = median_lga if mrk_dist ==.
tab mrk_dist, missing
replace mrk_dist = median_state if mrk_dist ==.
tab mrk_dist, missing
replace mrk_dist = median_zone if mrk_dist ==.
tab mrk_dist, missing
la var mrk_dist "=distance to the market"

save "${Nigeria_GHS_W3_created_data}\market_distance.dta", replace 




*********************************
*Demographics 
*********************************



use "${Nigeria_GHS_W3_raw_data}\sect1_plantingw3.dta",clear 


merge 1:1 hhid indiv using "${Nigeria_GHS_W3_raw_data}\sect2_harvestw3.dta", gen(household)

merge m:1 zone state lga sector ea using "${Nigeria_GHS_W3_created_data}\market_distance.dta", keepusing (median_lga median_state median_zone mrk_dist)

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
*s1q3   relationship to household head
*s1q6   age in years


sort hhid indiv 
 
gen num_mem = 1



******** female head****

gen femhead  = 0
replace femhead = 1 if s1q2== 2 & s1q3==1
tab femhead,missing

********Age of HHead***********
ren s1q6 hh_age
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
*s2aq6   1= attended school
*s2aq9	 highest education level
*s1q3    relationship to household head


ren  s2aq6 attend_sch 
tab attend_sch
replace attend_sch = 0 if attend_sch ==2
tab attend_sch, nolabel
*tab s1q4 if s2q7==.

replace s2aq9= 0 if attend_sch==0
tab s2aq9
tab s1q3 if _merge==1

tab s2aq9 if s1q3==1
replace s2aq9 = 16 if s2aq9==. &  s1q3==1

*** Education Dummy Variable*****

 label list s2aq9

gen pry_edu  = 1 if s2aq9 >= 1 & s2aq9 < 16 & s1q3==1
gen finish_pry  = 1 if s2aq9 >= 16 & s2aq9 < 26 & s1q3==1
gen finish_sec  = 1 if s2aq9 >= 26 & s2aq9 < 43 & s1q3==1

replace pry_edu =0 if pry_edu ==. & s1q3==1
replace finish_pry  =0 if finish_pry==. & s1q3==1
replace finish_sec =0 if finish_sec ==. & s1q3==1
tab pry_edu if s1q3==1 , missing
tab finish_pry if s1q3==1 , missing 
tab finish_sec if s1q3==1 , missing

collapse (sum) num_mem (max) mrk_dist hh_headage femhead attend_sch pry_edu finish_pry finish_sec , by (hhid)
la var num_mem "household size"
la var mrk_dist "distance to the nearest market in km"
la var femhead  "=1 if head is female"
la var hh_headage "age of household head in years"
la var attend_sch "=1 if respondent attended school"
la var pry_edu "=1 if household head attended pry school"
la var finish_pry "=1 if household head finished pry school"
la var finish_sec  "=1 if household head finished sec school"
save "${Nigeria_GHS_W3_created_data}\demographics_2015.dta", replace

********************************* 
*Labor Age 
*********************************
use "${Nigeria_GHS_W3_raw_data}\sect1_plantingw3.dta",clear 

*s1q6 age in years

ren s1q6 hh_age

gen worker  = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort hhid
collapse (sum) worker, by (hhid)
la var worker "number of members age 15 and older and less than 65"
sort hhid

save "${Nigeria_GHS_W3_created_data}\laborage_2015.dta", replace


********************************
*Safety Net
********************************

use "${Nigeria_GHS_W3_raw_data}\sect14_harvestw3.dta",clear 

*s14q1  1=received assistance 

ren s14q1 safety_net 
replace safety_net =0 if safety_net ==2 | safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (hhid)
tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${Nigeria_GHS_W3_created_data}\safety_net_2015.dta", replace



**************************************
*Food Prices
**************************************
use "${Nigeria_GHS_W3_raw_data}\sect7b_plantingw3.dta", clear

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
replace conversion = food_size*0.30 if s7bq3b==30 |	s7bq3b==31
replace conversion = food_size*1.5 if s7bq3b==20 |	s7bq3b==21
replace conversion = food_size*0.75 if s7bq3b==40 |	s7bq3b==41	|	s7bq3b==42 |	s7bq3b==43
replace conversion = food_size*0.35 if s7bq3b==80 |	s7bq3b==81	|	s7bq3b==82 			
tab conversion, missing



gen food_price_maize = s7bq3a* conversion if item_cd==16

gen maize_price  = s7bq4/food_price_maize if item_cd==16

*br  s7bq3b conversion s7bq3a s7bq4  food_price_maize maize_price item_cd if item_cd<=27

sum maize_price,detail
tab maize_price

replace maize_price = 600 if maize_price >600 & maize_price<.
replace maize_price = 50 if maize_price< 50
tab maize_price,missing



egen median_pr_ea = median(maize_price), by (ea)
egen median_pr_lga = median(maize_price), by (lga)
egen median_pr_sector = median(maize_price), by (sector)
egen median_pr_state = median(maize_price), by (state)
egen median_pr_zone = median(maize_price), by (zone)

egen num_pr_ea = count(maize_price), by (ea)
egen num_pr_lga = count(maize_price), by (lga)
egen num_pr_sector = count(maize_price), by (sector)
egen num_pr_state = count(maize_price), by (state)
egen num_pr_zone = count(maize_price), by (zone)

tab num_pr_ea
tab num_pr_lga
tab num_pr_state
tab num_pr_zone


gen maize_price_mr= maize_price

replace maize_price_mr = median_pr_ea if maize_price_mr==. & num_pr_ea>=8
tab maize_price_mr,missing

replace maize_price_mr = median_pr_lga if maize_price_mr==. & num_pr_lga>=8
tab maize_price_mr,missing

replace maize_price_mr = median_pr_state if maize_price_mr==. & num_pr_state>=8
tab maize_price_mr,missing

replace maize_price_mr = median_pr_zone if maize_price_mr==. & num_pr_zone>=8
tab maize_price_mr,missing
replace maize_price_mr = median_pr_sector if maize_price_mr==. & num_pr_sector>=8
tab maize_price_mr,missing



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

gen rice_price  = s7bq4/food_price_rice if item_cd==13 

*br  s7bq3b conversion s7bq3a food_price_rice s7bq4 rice_price item_cd if item_cd<=17

sum rice_price,detail
tab rice_price

replace rice_price = 1000 if rice_price >1000 & rice_price<.
replace rice_price = 30 if rice_price< 30
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



**************
*Net Buyers and Sellers
***************
*s7bq5a from purchases
*s7bq6a from own production

tab s7bq5a
tab s7bq6a

replace s7bq5a = 0 if s7bq5a<=0 |s7bq5a==.
tab s7bq5a,missing
replace s7bq6a = 0 if s7bq6a<=0 |s7bq6a==.
tab s7bq6a,missing

gen net_seller = 1 if s7bq6a > s7bq5a
tab net_seller,missing
replace net_seller=0 if net_seller==.
tab net_seller,missing

gen net_buyer = 1 if s7bq6a < s7bq5a
tab net_buyer,missing
replace net_buyer=0 if net_buyer==.
tab net_buyer,missing





collapse  (max) net_seller net_buyer maize_price_mr  rice_price_mr, by(hhid)
la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"
label var maize_price_mr "commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
sort hhid
save "${Nigeria_GHS_W3_created_data}\food_prices_2015.dta", replace






*****************************
*Household Assests
****************************


use "${Nigeria_GHS_W3_raw_data}\sect5_plantingw3.dta",clear 

*s5q1 qty of items
*s5q4 scrap value of item 

sort hhid item_cd

gen hhasset_value  = s5q4*s5q1
tab hhasset_value,missing
sum hhasset_value,detail
replace hhasset_value = 1000000 if hhasset_value > 1000000 & hhasset_value <.
replace hhasset_value = 200 if hhasset_value <200


************generating the mean vakue**************

egen mean_val_ea = mean(hhasset_value), by (ea)

egen mean_val_lga = mean(hhasset_value), by (lga)

egen num_val_pr_ea = count(hhasset_value), by (ea)

egen num_val_pr_lga = count(hhasset_value), by (lga)

egen mean_val_state = mean(hhasset_value), by (state)
egen num_val_pr_state = count(hhasset_value), by (state)

egen mean_val_zone = mean(hhasset_value), by (zone)
egen num_val_pr_zone = count(hhasset_value), by (zone)


tab mean_val_ea
tab mean_val_lga
tab mean_val_state
tab mean_val_zone



tab num_val_pr_ea
tab num_val_pr_lga
tab num_val_pr_state
tab num_val_pr_zone



replace hhasset_value = mean_val_ea if hhasset_value ==. & num_val_pr_ea >= 411

tab hhasset_value,missing


replace hhasset_value = mean_val_lga if hhasset_value ==. & num_val_pr_lga >= 411

tab hhasset_value,missing



replace hhasset_value = mean_val_state if hhasset_value ==. & num_val_pr_state >= 411

tab hhasset_value,missing


replace hhasset_value = mean_val_zone if hhasset_value ==. & num_val_pr_zone >= 411

tab hhasset_value,missing

sum hhasset_value, detail



collapse (sum) hhasset_value, by (hhid)

la var hhasset_value "total value of household asset"
save "${Nigeria_GHS_W3_created_data}\household_asset_2015.dta", replace





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
save "${Nigeria_GHS_W3_created_data}\land_cf.dta", replace

 
 
 
 
 
 
 *************** Plot Size **********************

use "${Nigeria_GHS_W3_raw_data}\sect11a1_plantingw3",clear 
*merging in planting section to get cultivated status
merge 1:1 hhid plotid using  "${Nigeria_GHS_W3_raw_data}\sect11b1_plantingw3"
*merging in harvest section to get areas for new plots
merge 1:1 hhid plotid using "${Nigeria_GHS_W3_raw_data}\secta1_harvestw3.dta", gen(plot_merge)

 
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
merge m:1 zone area_unit using "${Nigeria_GHS_W3_created_data}\land_cf.dta", nogen keep(1 3) 


 
 *farmer reported field size for post-planting
gen field_size= area_size*conversion
*replacing farmer reported with GPS if available
replace field_size = area_meas_sqm*0.0001 if area_meas_sqm!=.               				
gen gps_meas = (area_meas_sqm!=. | area_meas_sqm2!=.)
la var gps_meas "Plot was measured with GPS, 1=Yes"
*farmer reported field size for post-harvest added fields
drop area_unit conversion
ren area_unit2 area_unit

 
 
 ***************Measurement in hectares for the additional plots from post-harvest************
******Merging data with the conversion factor
merge m:1 zone area_unit using "${Nigeria_GHS_W3_created_data}\land_cf.dta", nogen keep(1 3) 


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
save "${Nigeria_GHS_W3_created_data}\land_holding_2015.dta", replace

 





*******************************
*Soil Quality
*******************************

use "${Nigeria_GHS_W3_raw_data}\sect11a1_plantingw3",clear 
*merging in planting section to get cultivated status
merge 1:1 hhid plotid using  "${Nigeria_GHS_W3_raw_data}\sect11b1_plantingw3"
*merging in harvest section to get areas for new plots
merge 1:1 hhid plotid using "${Nigeria_GHS_W3_raw_data}\secta1_harvestw3.dta", gen(plot_merge)

 
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
merge m:1 zone area_unit using "${Nigeria_GHS_W3_created_data}\land_cf.dta", nogen keep(1 3) 


 
 *farmer reported field size for post-planting
gen field_size= area_size*conversion
*replacing farmer reported with GPS if available
replace field_size = area_meas_sqm*0.0001 if area_meas_sqm!=.               				
gen gps_meas = (area_meas_sqm!=. | area_meas_sqm2!=.)
la var gps_meas "Plot was measured with GPS, 1=Yes"
*farmer reported field size for post-harvest added fields
drop area_unit conversion
ren area_unit2 area_unit

 
 
 ***************Measurement in hectares for the additional plots from post-harvest************
******Merging data with the conversion factor
merge m:1 zone area_unit using "${Nigeria_GHS_W3_created_data}\land_cf.dta", nogen keep(1 3) 


replace field_size= area_size2*conversion if field_size==.
*replacing farmer reported with GPS if available
replace field_size = area_meas_sqm2*0.0001 if area_meas_sqm2!=.               
la var field_size "Area of plot (ha)"
sum field_size, detail
keep zone state lga sector ea hhid plotid field_size

merge 1:1 hhid plotid using "${Nigeria_GHS_W3_raw_data}\sect11b1_plantingw3.dta"




ren s11b1q45 soil_quality
tab soil_quality, missing
order field_size soil_quality hhid 
sort hhid


*how to get them my max fieldsize


/*
egen max_fieldsize = max(field_size), by (hhid)
replace max_fieldsize= . if max_fieldsize!= max_fieldsize
order field_size soil_quality hhid max_fieldsize
sort hhid
br 

egen med_soil = median(soil_quality)


egen med_soil_ea = median(soil_quality), by (ea)
egen med_soil_lga = median(soil_quality), by (lga)
egen med_soil_state = median(soil_quality), by (state)
egen med_soil_zone = median(soil_quality), by (zone)

replace soil_quality= med_soil_ea if soil_quality==.
tab soil_quality, missing
replace soil_quality= med_soil_lga if soil_quality==.
tab soil_quality, missing
replace soil_quality= med_soil_state if soil_quality==.
tab soil_quality, missing
replace soil_quality= med_soil_zone if soil_quality==.
tab soil_quality, missing

replace soil_quality= med_soil if soil_quality==.
tab soil_quality, missing

replace soil_quality= 2 if soil_quality==1.5
tab soil_quality, missing
collapse (max) soil_quality, by (hhid)
la var soil_quality "1=Good 2= fair 3=Bad "
save "${Nigeria_GHS_W3_created_data}\soil_quality_2015.dta", replace






*/





















************************* Merging Agricultural Datasets ********************

use "${Nigeria_GHS_W3_created_data}\purchased_fert_2015.dta", replace


*******All observations Merged*****


merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\subsidized_fert_2015.dta", gen (subsidized)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\E-wallet_subsidized_fert_2015.dta",gen (ewallet)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\savings_2015.dta", gen (savings)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\credit_access_2015.dta", gen (credit)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\extension_access_2015.dta", gen (extension)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\demographics_2015.dta", gen (demographics)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\laborage_2015.dta", gen (labor)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\safety_net_2015.dta", gen (safety)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\food_prices_2015.dta", gen (foodprices)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\geodata_2015.dta", gen (geodata)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\soil_quality_2015.dta", gen (soil)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\household_asset_2015.dta", gen (asset)
sort hhid
merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}\land_holding_2015.dta"
gen year = 2015
sort hhid
save "${Nigeria_GHS_W3_created_data}\Nigeria_wave3_completedata_2015.dta", replace

