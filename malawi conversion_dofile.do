use "C:\Users\obine\Downloads\IHSconversion.dta" ,clear

gen maize_con = conversion  if crop_code==1
br if maize_con!=.


gen rice_con = conversion  if crop_code==17
*br if rice_con!=.

br if crop_code==17
