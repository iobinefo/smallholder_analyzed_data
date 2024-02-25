



use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\complete_files\Tanzania_complete_data.dta", clear


gen commercial_dummy = (total_qty_w>0)






local time_avg "total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w  subsidy_dummy femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** OLS **
reg total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 i.region i.year


** OLS with HH fixed effects
xtreg total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 i.region  i.year, fe i(hhid) cluster(hhid)

** CRE-TOBIT 
tobit total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 i.region  i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post


** Double Hurdle **








capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit commercial_dummy subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020, second(total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020) cluster(hhid)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidy_qty_w]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidy_qty_w]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	summarize bsdEy_dxj
	
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est = r(ape_xj), reps(250) cluster(hhid) idcluster(newid): APEboot















                                   *********************************************** 
								   *Crowding out estimate for each asset quintile
								   ***********************************************
	
	xtile asset_quintiles=real_hhvalue, nq(5)

	preserve
	craggit commercial_dummy subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020, second(total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020) cluster(hhid)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidy_qty_w]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidy_qty_w]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	
	summarize bsdEy_dxj // Average crowding out estimate for reference. Use SE from bootstrap 

	tabulate asset_quintiles, summarize (bsdEy_dxj) // Crowding out estimate for each quintile
	restore


** Bootstraped SE for each quintiles

*Asset q1
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit commercial_dummy subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020, second(total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020) cluster(hhid)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidy_qty_w]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidy_qty_w]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==1
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q1 = r(ape_xj), reps(250) cluster(hhid) idcluster(newid): APEboot

*Asset q2
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit commercial_dummy subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020, second(total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020) cluster(hhid)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidy_qty_w]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidy_qty_w]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==2
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q2 = r(ape_xj), reps(250) cluster(hhid) idcluster(newid): APEboot

*Asset q3
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit commercial_dummy subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020, second(total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020) cluster(hhid)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidy_qty_w]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidy_qty_w]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==3
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q3 = r(ape_xj), reps(250) cluster(hhid) idcluster(newid): APEboot


*Asset q4
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit commercial_dummy subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020, second(total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020) cluster(hhid)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidy_qty_w]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidy_qty_w]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==4
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q4 = r(ape_xj), reps(250) cluster(hhid) idcluster(newid): APEboot

*Asset q5
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit commercial_dummy subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020, second(total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020) cluster(hhid)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidy_qty_w]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidy_qty_w]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==5
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q5 = r(ape_xj), reps(250) cluster(hhid) idcluster(newid): APEboot

