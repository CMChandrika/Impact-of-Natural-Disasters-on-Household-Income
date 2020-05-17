                                                                    
*************Explain whether family income has any relationship with climate change and natural disaster********
*****Use HIES 2010 Data*********
clear all
set more off

cd "D:\625\HES2010"

use "rt001.dta", clear

gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold region district
sort psu_hhold
save rt001_reg, replace


*******Household income Generation **********
******Wage & salary******section 4 Economic Activities********
use "rt003.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s04a_q02 s04a_q03 s04b_q_2 s04b_q_3 s04b_q08 s04b_q09
replace s04b_q08=0 if s04b_q08==.
gen ywage=s04a_q02*s04a_q03*s04b_q_2
replace s04b_q09=0 if s04b_q09==.
replace s04b_q_3=0 if s04b_q_3==.
gen ywage_kind=s04a_q02*s04a_q03*s04b_q_3
gen ysalary=12*s04b_q08
gen wage_salary=ywage+ywage_kind+ysalary+s04b_q09
collapse (sum)wage_salary, by(psu_hhold)
save wage_salary, replace

******NON-Agriculture Entreprise*****section 5 Non-Agricilture Enterprise******
use "rt004.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s05a_q06 s05a_q07 s05b_q20 s05b_q21 s05b_q22
gen revenue=s05b_q20*(s05a_q07/100)
keep psu_hhold revenue
sort psu_hhold
collapse (sum)revenue, by(psu_hhold)
save enterprise_revenue, replace

****************************************
******* farm crop sale *****************Section 7 Agriculture******

use "rt006.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s07b_q_1 s07b_q05 s07b_q06 s07b_q07
gen crop_sale=s07b_q_1*(s07b_q05+s07b_q06+s07b_q07)
collapse (sum)crop_sale, by(psu_hhold)
sort psu_hhold
save farm_crop_sale, replace

****** farm livestock_sale ******
use "rt007.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s07c_q_3 s07c_q_4
drop if s07c_q_4==.
collapse (sum)s07c_q_3 (sum)s07c_q_4, by(psu_hhold)
egen livestock_sale=rowtotal(s07c_q_3 s07c_q_4) //considering tk mentioned means sale only not die
sort psu_hhold
save farm_livestock_sale, replace

******* farm animal_product_sale ******
use "rt008.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s07c_q_1
collapse (sum)s07c_q_1, by(psu_hhold)
sort psu_hhold
ren s07c_q_1 animal_rpoduct_sale
save farm_animal_product_sale, replace

******* farm fish_sale ******
use "rt009.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s07c_q_1
collapse (sum)s07c_q_1, by(psu_hhold)
ren s07c_q_1 fish_sale
sort psu_hhold
save farm_fish_sale, replace

******* farm_forestry_sale ******
use "rt010.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s07c_q15 s07c_q16
collapse (sum)s07c_q15 (sum)s07c_q16, by(psu_hhold)
egen farm_forestry_sale=rowtotal(s07c_q15 s07c_q16)
sort psu_hhold
save farm_forestry_sale, replace

******* farm_input_expense ******
use "rt011.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s07d_q_1
collapse (sum)s07d_q_1, by(psu_hhold)
ren s07d_q_1 farm_input_expense
sort psu_hhold
save farm_input_expense, replace

******* farm agri asset rent ******
use "rt012.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep psu_hhold s07e_q04
collapse (sum)s07e_q04, by(psu_hhold)
ren s07e_q04 farm_asset_rent
sort psu_hhold
save farm_asset_rent, replace

******* farm net income ****************
use farm_crop_sale, clear

merge 1:1 psu_hhold using farm_livestock_sale, nogenerate
merge 1:1 psu_hhold using farm_animal_product_sale, nogenerate
merge 1:1 psu_hhold using farm_fish_sale, nogenerate
merge 1:1 psu_hhold using farm_forestry_sale, nogenerate
merge 1:1 psu_hhold using farm_input_expense, nogenerate
merge 1:1 psu_hhold using farm_asset_rent, nogenerate

replace farm_input_exp=farm_input_exp*(-1)

egen farm_net_income=rowtotal(crop_sale livestock_sale animal_rpoduct_sale fish_sale farm_forestry_sale farm_input_expense farm_asset_rent)
keep psu_hhold farm_net_income
save farm_net_income, replace
use farm_net_income, clear

*********************************************
************* other income ****************
use "rt001.dta", clear
gen psu_hhold=psu+hhold
 
keep psu_hhold s08b_q01 s08b_q02 s08b_q03 s08b_q_1 s08b_q_2 s08b_q04 s08b_q05 s08b_q06 s08b_q07 s08b_q08 s08b_q09 s08b_q11 s08b_q12 s08b_q13
egen other_income=rowtotal(s08b_q01 s08b_q02 s08b_q03 s08b_q_1 s08b_q_2 s08b_q04 s08b_q05 s08b_q06 s08b_q07 s08b_q08 s08b_q09 s08b_q11 s08b_q12 s08b_q13)
collapse (sum)other_income, by(psu_hhold)
sort psu_hhold
save other_income, replace

*********************************************
************* hh_net_income  ****************
use rt001_region, clear
merge 1:1 psu_hhold using wage_salary, nogenerate
merge 1:1 psu_hhold using enterprise_revenue, nogenerate
merge 1:1 psu_hhold using farm_net_income, nogenerate
merge 1:1 psu_hhold using other_income, nogenerate

egen hh_net_income=rowtotal(wage_salary revenue farm_net_income other_income)
label var hh_net_income "net household income"

save hh_net_income, replace

*********HH net income generation is done here**********
**************Independent Variable Generation***********************
use "rt002.dta", clear
gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"

keep s01a_q02 s01a_q04 s02a_q05 s01a_q05 s01a_q06 psu_hhold s01a_q03

rename s01a_q02 sex // generation of sex variable
replace sex = 0 if sex == 2
gen head_sex = sex if s01a_q03 == 1
label variable sex "gender of household head"
drop if head_sex == .

rename s01a_q04 age // generation of age variable
gen head_age = age if s01a_q03 ==1
gen age_sq = (head_age)^2
label variable head_age "age of household head"

rename s02a_q05 educ // generation of education variableZ
drop if educ >= 20
gen head_edu = educ if s01a_q03 ==1
label variable head_edu "education of household head"
*label define head_edu 0"illiterate" 1"primary" 2"primary" 3"primary" 4"primary" 5"primary" ///
 *6"high school" 7"high school" 8"high school" 9"high school" 10"SSc" 11"HSC" 12"Graduate" 13"post graduate" ///
 *14"Medical" 15"Engineering" 16"Vocational" 17"technical" 18"Nursing" 19"other"
 
 recode head_edu (0=0 "illiterate") (1/4=1 "primary") (5=2 "PSC") (6/7 = 3 "Junior high") ///
  (8/9=4 "JSC") (10=5 "SSC") (12/15=7 "University") (11=6 "HSC")  ///
  (16/18= 8 "Vocational") (19=9 "others"), g(educc)
 
*drop if head_edu == .
 label value head_edu head_edu
rename s01a_q05 religion // generation of religion variable
gen H_religion = religion if s01a_q03 ==1
label variable religion "religion of the hh"
*drop if H_religion == .

rename s01a_q06 ms // generation of marital status variable
gen head_ms = ms if s01a_q03 ==1
label variable head_ms "marital status of the HH head"
label define head_ms 1"Currently married" 2"never married" 3"Widowed" 4"divorced" 5"seperated"
 label value head_ms head_ms
*drop if H_religion == .

sort psu_hhold

save demographic, replace


*Generation of HH size***
use "rt002.dta",clear 
g psu_hhold = psu+hhold
sort psu_hhold
contract psu_hhold
rename _freq hhsize
label variable hhsize "Size of the household"
save hhsize, replace


******generation of rural dummy*******
use "rt001.dta", clear
g psu_hhold =psu+hhold
sort psu_hhold
keep psu_hhold spc
g area=0
replace area = 1 if spc== "Rural"
label var area "location"
save area, replace

use "rt001.dta", clear
g psu_hhold =psu+hhold
sort psu_hhold

gen intnt = 0
replace intnt =1 if s06a_q13 == 1
label var intnt " access to internet"


rename s07a_q06 opt_land // generation of operating land in the hh (in decimal)
label var opt_land "land owership in the hh"

rename s06a_q08 san // generation of access to sanitation 
gen sant = 0
replace sant = 1 if san <= 3 
label var sant "sanitation in the hh"

gen water = 0
replace water =1 if s06a_q13 == 1
label var water " safe drinking water in the hh"


rename  s06a_q14 ele // generation of acess to electricity 
gen elec = 0
replace elec = 1 if ele == 1
label var elec " electricity in the hh"

gen migrnt = 0 
replace migrnt = 1 if s08c_q01 == 1  // generation of migration variable
label var migrnt "migration in the hh"


collapse intnt migrnt sant water elec (sum)opt_land ,by (psu_hhold)
sort psu_hhold
  save rt001new,replace
 


*******Natural Disaster************section 6B*******
use "rt005.dta",clear

gen psu_hhold=psu+hhold
label var psu_hhold "household idcode"
keep s06b_q03 s06b_q04 s06b_q02 s06b_q03 psu_hhold shock_co
gen dstr=.
replace dstr=1 if s06b_q02 == 1 & shock_co == 101 

replace dstr=2 if s06b_q02 == 1 & shock_co == 102
replace dstr=3 if s06b_q02 == 1 & shock_co == 103
replace dstr=4 if s06b_q02 == 1 & shock_co == 117
replace dstr=0 if s06b_q02 == 2 
 
 rename dstr disaster
label variable disaster "Natural disaster"
 gen d=0 
replace d=1 if disaster == 1
replace d=1 if disaster == 2
replace d=1 if disaster == 3
replace d=1 if disaster == 4

gen dght = 0  
replace dght = 1 if shock_co == 101 & s06b_q02 == 1 // drought

gen flood = 0 
replace flood = 1 if shock_co == 102 & s06b_q02 == 1 // flood

gen lan_sl = 0
replace lan_sl= 1 if shock_co == 103 & s06b_q02 == 1 // landslide

gen erth = 0 
replace erth = 1 if shock_co == 117 & s06b_q02 == 1 // earthquake

rename s06b_q04 t_d // generation of duration of the disaster variable
label var t_d "duration of disaster"
rename s06b_q03 s_m
recode s_m (1 2 11 12 = 1 "winter") (3 4 5 = 2 "summer") (6 7 = 3 "rainy") (8 9 10= 4 "fall") , g(s_m1)
label var s_m s_m1

collapse (max)d disaster dght flood lan_sl erth s_m1, by(psu_hhold) 
sort psu_hhold
save disaster, replace

use "rt002.dta", clear
g psu_hhold =psu+hhold
rename s02a_q05 educ // generation of education variableZ
drop if educ >= 20
sort psu_hhold
rename educ high_edu
**collapse (max)high_edu, by(psu_hhold)
 recode high_edu (0=0 "illiterate") (1/4=1 "primary") (5=2 "PSC") (6/7 = 3 "Junior high") ///
  (8/9=4 "JSC") (10=5 "SSC") (12 =9 "University") (14/15 = 9 "University") (13 = 10 "post") (11=6 "HSC")  ///
  (16/18= 7 "Vocational") (19=8 "others"), g (hgst_edu)
  label value hgst_edu hgst_edu
  drop if hgst_edu == 10
  collapse (max)hgst_edu, by(psu_hhold)
save hgst_edu,replace



use "hh_net_income",clear
merge 1:1 psu_hhold using disaster,nogenerate
save income_disaster,replace

use "demographic",clear
merge 1:1 psu_hhold using rt001_reg,nogenerate
merge 1:1 psu_hhold using rt001_region,nogenerate
merge 1:1 psu_hhold using hhsize,nogenerate
merge 1:1 psu_hhold using rt001new,nogenerate
merge 1:1 psu_hhold using income_disaster,nogenerate
merge 1:1 psu_hhold using area,nogenerate
merge 1:1 psu_hhold using hgst_edu,nogenerate
**merge 1:1 psu_hhold using avg_age,nogenerate
save reg_var,replace

use "reg_var",clear

*****generate log variable*******
g ln_hh_net_income = ln(hh_net_income)
drop if ln_hh_net_income == .
drop if hh_net_income <= 0

g crop_income = ln(farm_net_income)
**g ent_income = ln(enterprise_revenue)
g oth_income = ln(other_income)
g noncrop_income = ln(wage_salary)
 save reg_var,replace



***********Bckground**********
centile hh_net_income , c(15 25 50 75 85)

use "rt001.dta",clear
g psu_hhold =psu+hhold
sort psu_hhold
ren s06a_q02 room
label var room "no of rooms"

ren s06a_q05 wall
label define wall 1"brick/cement" 2"C.I Sheet/ wood" ///
3"Mud brick" 4"Hemp/hay/bamboo" 5 "other"
label value wall wall
ren s06a_q06 roof
label define roof 1"brick/cement" 2"C.I Sheet/ wood" ///
3"Tile/wood" 4"Hemp/hay/bamboo" 5 "other"
label value roof roof
ren s06a_q07 space
 
ren s07a_q01 cul_land
ren s07a_q02 hom_land
collapse room wall roof space (sum) cul_land hom_land , by (psu_hhold)
sort psu_hhold 
save room,replace

use reg_var,clear
merge 1:1 psu_hhold using room,nogenerate
label define wall 1"brick/cement" 2"C.I Sheet/ wood" ///
3"Mud brick" 4"Hemp/hay/bamboo" 5 "other"
label value wall wall

label define roof 1"brick/cement" 2"C.I Sheet/ wood" ///
3"Tile/wood" 4"Hemp/hay/bamboo" 5 "other"
label value roof roof
histogram hgst_edu, frequency scheme(sj)


 **************Estimation model******************
psmatch2 d area hhsize hgst_edu, out( ln_hh_net_income ) logit 
tab d if _weight < .
sum  ln_hh_net_income i.area head_age age_sq  i.head_sex i.educc i.H_religion migrnt i.head_ms opt_land i.sant d i.elec i.intnt 


*********************************Regression******************************
  reg ln_hh_net_income i.area head_age  hhsize i.head_sex i.educc i.H_religion migrnt i.head_ms opt_land i.sant i.disaster
  vif 
 reg ln_hh_net_income i.area head_age hhsize i.hgst_edu i.head_sex i.H_religion migrnt i.head_ms opt_land i.sant i.disaster[fweight=_weight]
 
 
 *************heteroskwdusticity Test********************
 estat hettest
 predict e, resid
 gen e2 = e^2
reg e2 ln_hh_net_income i.area head_age age_sq hhsize i.head_sex i.hgst_edu i.H_religion migrnt i.head_ms opt_land i.sant i.disaster[fweight=_weight]
predict yhat, xb
gen yhat2 = yhat^2
reg e2 yhat yhat2

  *************Robust*********************
 reg ln_hh_net_income i.area head_age hhsize i.head_sex i.hgst_edu i.H_religion migrnt i.head_ms opt_land i.sant i.disaster, vce(robust)
 estimate store equation1
 
 reg ln_hh_net_income i.area head_age hhsize i.head_sex i.hgst_edu i.H_religion migrnt i.head_ms opt_land i.sant i.disaster[fweight=_weight], vce(robust)
 estimate store equation2
outreg2 [equation1 equation2 ] using results,word replace


********Quantile*************   
qreg ln_hh_net_income i.disaster if _weight<. , q(0.15) vce(robust,)
 estimate store equation3
qreg ln_hh_net_income i.disaster if _weight<., q(0.31) vce(robust,)
 estimate store equation4
qreg ln_hh_net_income i.disaster if _weight<. , q(0.50) vce(robust,)
 estimate store equation5
qreg ln_hh_net_income i.disaster if _weight<. , q(0.70) vce(robust,)
estimate store equation6
qreg ln_hh_net_income i.disaster if _weight<. , q(0.80) vce(robust,)
estimate store equation7
qreg ln_hh_net_income i.disaster if _weight<. , q(0.95) vce(robust,)
estimate store equation8
outreg2 [equation3 equation4 equation5 equation6 equation7 equation8] using results,word replace


qreg _ln_hh_net_income d if _weight<. , q(0.15) vce(robust,)
 estimate store d1
qreg _ln_hh_net_income d if _weight<. , q(0.25) vce(robust,)
 estimate store d2
qreg _ln_hh_net_income d if _weight<. , q(0.50) vce(robust,)
 estimate store d3
qreg _ln_hh_net_income d if _weight<. , q(0.75) vce(robust,)
estimate store d4
qreg _ln_hh_net_income d if _weight<. , q(0.85) vce(robust,)
estimate store d5
qreg _ln_hh_net_income d if _weight<. , q(0.99) vce(robust,)
estimate store d6
outreg2 [d1 d2 d3 d4 d5 d6] using results,word replace




centile hh_net_income, centile( 20 25 50  75 80 )

tab wall disaster if hh_net_income <= 44220, column
tab wall disaster  if hh_net_income >= 171176, column


tab roof disaster if hh_net_income <= 44220, column
tab roof disaster if hh_net_income >= 171176, column

tab room disaster if hh_net_income <= 44220, column
tab room disaster if hh_net_income >= 171176, column 

egen writecat = cut(space), at(0 100 200 300 400 450 500 600 700 800 900 1000 2000 4000 20000)
tab writecat disaster if hh_net_income <= 44220, column
tab writecat disaster if hh_net_income >= 171176, column


egen writecat1 = cut(opt_land), at(0 100 200 300 400 500 600 700 800 900 1000 2000 3000)

tab writecat1 disaster if hh_net_income <= 44220, column
tab writecat1 disaster if hh_net_income >= 171176, column

egen writecat2 = cut(hom_land), at(0 5 10  20 30 40 50 100 200 400 500)
tab writecat2 disaster if hh_net_income <= 44220, column
tab writecat2 disaster if hh_net_income >= 171176, column


********End*******************

