
** Crowding out estimate for each asset quintile
	
	xtile asset_quintiles=durable_goods_value_1000s, nq(5)

	preserve
	craggit com_fer_bin_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019, second(commercial_fert_rainy_kg_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019) cluster(HHID)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidized_fert_kg]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidized_fert_kg]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	
	summarize bsdEy_dxj // Average crowding out estimate for reference. Use SE from bootstrap 

	tabulate asset_quintiles, summarize (bsdEy_dxj) // Crowding out estimate for each quintile
	restore


** Bootstraped SE for each quintiles

*Asset q1
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit com_fer_bin_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019, second(commercial_fert_rainy_kg_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019) cluster(HHID)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidized_fert_kg]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidized_fert_kg]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==1
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q1 = r(ape_xj), reps(250) cluster(HHID) idcluster(newid): APEboot

*Asset q2
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit com_fer_bin_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019, second(commercial_fert_rainy_kg_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019) cluster(HHID)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidized_fert_kg]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidized_fert_kg]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==2
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q2 = r(ape_xj), reps(250) cluster(HHID) idcluster(newid): APEboot

*Asset q3
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit com_fer_bin_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019, second(commercial_fert_rainy_kg_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019) cluster(HHID)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidized_fert_kg]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidized_fert_kg]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==3
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q3 = r(ape_xj), reps(250) cluster(HHID) idcluster(newid): APEboot


*Asset q4
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit com_fer_bin_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019, second(commercial_fert_rainy_kg_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019) cluster(HHID)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidized_fert_kg]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidized_fert_kg]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==4
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q4 = r(ape_xj), reps(250) cluster(HHID) idcluster(newid): APEboot

*Asset q5
capture program drop APEboot
program define APEboot, rclass
	preserve
	craggit com_fer_bin_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019, second(commercial_fert_rainy_kg_w subsidized_fert_kg_w fert_purchase_cost_kg_w_imp avg_maize_price_JanToMar land_owned hhsize tot_adult head_age attend_school fam_death female_head borrowed_on_credit comm_fert_seller_tot dist_admarc annual_prec durable_goods_value_1000s TAvg_subsidized_fert_kg TAvg_fert_purchase_cost_kg_w_imp TAvg_avg_maize_price_JanToMar TAvg_land_owned TAvg_hhsize TAvg_tot_adult TAvg_head_age TAvg_attend_school TAvg_fam_death TAvg_female_head TAvg_borrowed_on_credit TAvg_comm_fert_seller_tot TAvg_dist_admarc TAvg_annual_prec TAvg_durable_goods_value_1000s year_2013 year_2016 year_2019) cluster(HHID)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[subsidized_fert_kg]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[subsidized_fert_kg]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	
	keep if asset_quintiles==5
	
	summarize bsdEy_dxj
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)
	restore
end
bootstrap crowd_out_est_asset_q5 = r(ape_xj), reps(250) cluster(HHID) idcluster(newid): APEboot
