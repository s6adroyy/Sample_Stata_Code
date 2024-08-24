*******************************************************************************
*******************************************************************************
*********** FINAL FIGURES AND TABLES
*********** 
*******************************************************************************
*******************************************************************************

*********************************************************************************************
* Table A2. Descriptive statistics of the main sample
*********************************************************************************************

clear all

use "$output_data\built_youth_data.dta", clear

egen ave_trust = rowmean(trust_people rely_someone trust_strangers)
local all_variables ave_trust female height east rural migration_back highest_edu_hh father_blue_collar work_mother single_parent religion_hh low_perform

estpost ttest `all_variables', by(treated) listwise
esttab ., cells("mu_1(fmt(2) label(Control)) mu_2(fmt(2) label(Treated)) t(fmt(2))") nonumber  label

esttab . using "$tables/descriptive_stats.tex", replace ///
cells("mu_1(fmt(2) label(Control)) mu_2(fmt(2) label(Treated)) t(fmt(2) label(t-stat))") ///
label nonumber refcat(trust_ctg "Dependent variable" female "Independent variables", nolabel) nonotes

********************************************************************************
* Figure A2. Leads and lags of the reform effects
********************************************************************************

clear all
use "$output_data\built_youth_data_event_study.dta", clear

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust _m3 _m2 _m1 init _p1 _p2 _p3 _p4 $xvar, absorb(state) cluster(state)
 forvalues i=1/3 {
  local b_m`i'=_b[_m`i']
  local se_m`i'=_se[_m`i']
 }
 forvalues i=1/4 {
  local b_p`i'=_b[_p`i']
  local se_p`i'=_se[_p`i']
 }
local b_init = _b[init]
local se_init = _se[init]

preserve
clear
set obs 9
gen t=_n-5
gen b=.
gen se=.
forvalues i=1/4 {
  if `i'<=3 {
	replace b=`b_m`i'' if t==-`i'
	replace se=`se_m`i'' if t==-`i'
  }
  replace b=`b_p`i'' if t==`i'
  replace se=`se_p`i'' if t==`i'
  } 
  replace b = `b_init' if t==0
  replace se = `se_init' if t==0
  replace b=0 if t==-4
  gen b_upper=b+1.96*se
  gen b_lower=b-1.96*se
  twoway (rcap b_upper b_lower t, lstyle(ci)) ///
         (scatter b t, xline(0, lcolor(black) lpattern(shortdash)) mcolor(maroon) connect(l) lcolor(maroon) lwidth(medthick) legend(off) graphregion(color(white)) xtitle("Years from G8 reform") xscale(titlegap(*6)) xlabel(-4(1)4)  yline(0, lcolor(gs5)) ylabel(-3(1)3) yscale(range(-3 3)) ysize(3) xsize(6) scale(1.35)) 
  graph export "$figures\event_study_pca_trust.png", replace
 restore 

************************************************
* Table 2. Basic regression
************************************************

clear all

use "$output_data\built_youth_data.dta", clear

global xvar_no_control female height
global xvar_with_control female height rural migration_back highest_edu_hh /// 
father_blue_collar work_mother
global xvar_extended_control female height rural migration_back highest_edu_hh   ///
father_blue_collar work_mother single_parent religion_hh low_perform

areg std_pca_trust treated $xvar_no_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/main_results_youth_v1.tex", replace ctitle(" ") dec(3) keep(treated $xvar_no_control) label nocons 
areg std_pca_trust treated $xvar_with_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/main_results_youth_v1.tex", append ctitle(" ") dec(3) keep(treated $xvar_with_control) label nocons 
areg std_pca_trust treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/main_results_youth_v1.tex", append ctitle(" ") dec(3) keep(treated $xvar_extended_control) label nocons cttop(Trust)
estimates clear

************************************************
* Table 3. Heterogeneous effects of the G8 reform
************************************************

clear all

use "$output_data\built_youth_data.dta", clear

******************** 1. Heterogeneity by gender

global xvar_no_sex height rural migration_back highest_edu_hh ///
father_blue_collar work_mother single_parent religion_hh low_perform i.year_hgsch_entry 

areg std_pca_trust i.female i.treated i.female#i.treated $xvar_no_sex, absorb(state) cluster(state)

outreg2 using "$tables/hetero_results_gender_youth.tex", replace ctitle(" ") dec(3) keep(1.treated 1.female#1.treated) label nocons 
estimates clear

margins, dydx(treated) at(female=(1)) 

******************** 2. Heterogeneity by highest parental education 

global xvar_no_hghst_edu_hh female height rural migration_back   ///
father_blue_collar work_mother single_parent religion_hh low_perform i.year_hgsch_entry 

areg std_pca_trust i.highest_edu_hh i.treated i.highest_edu_hh#i.treated $xvar_no_hghst_edu_hh, absorb(state) cluster(state)

outreg2 using "$tables/hetero_results_high_educ_youth.tex", replace ctitle(" ") dec(3) keep(1.treated 1.highest_edu_hh#1.treated) label nocons 
estimates clear

margins, dydx(treated) at(highest_edu_hh=(1)) 

******************** 3. Heterogeneity by migration background 

global xvar_no_mig female height rural highest_edu_hh   ///
father_blue_collar work_mother single_parent religion_hh low_perform ///
i.year_hgsch_entry

areg std_pca_trust i.migration_back i.treated i.migration_back#i.treated $xvar_no_mig, absorb(state) cluster(state)

outreg2 using "$tables/hetero_results_migback_youth.tex", replace ctitle(" ") dec(3) keep(1.treated 1.migration_back#1.treated) label nocons 
estimates clear

margins, dydx(treated) at(migration_back=(1)) 

******************** 4. Heterogeneity by working-class father 

global xvar_no_blue_collar female height rural migration_back highest_edu_hh   ///
 work_mother single_parent religion_hh low_perform ///
i.year_hgsch_entry

areg std_pca_trust i.father_blue_collar i.treated i.father_blue_collar#i.treated  $xvar_no_blue_collar, absorb(state) cluster(state)

outreg2 using "$tables/hetero_results_blue_collar_youth.tex", replace ctitle(" ") dec(3) keep(1.treated 1.father_blue_collar#1.treated) label nocons 
estimates clear

margins, dydx(treated) at(father_blue_collar=(1)) 


******************** 5. Heterogeneity by low-performing student

global xvar_no_low_perform female height rural migration_back highest_edu_hh   ///
father_blue_collar work_mother single_parent religion_hh ///
i.year_hgsch_entry 

areg std_pca_trust i.low_perform i.treated i.low_perform#i.treated   $xvar_no_low_perform, absorb(state) cluster(state)

outreg2 using "$tables/hetero_results_low_perform_youth.tex", replace ctitle(" ") dec(3) keep(1.treated 1.low_perform#1.treated) label nocons 
estimates clear

margins, dydx(treated) at(low_perform=(1)) 

************************************************
* Table 4. G8 reform effects on other channels
************************************************

clear all
use "$output_data\built_youth_data.dta", clear

global xvar_extended_control female height rural migration_back highest_edu_hh   ///
father_blue_collar work_mother single_parent religion_hh low_perform

areg volunteer_work_month treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/direct_mechanisms_youth.tex", replace ctitle("Volunteering") dec(3) keep(treated) label nocons 
areg sport_active treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/direct_mechanisms_youth.tex", append ctitle("Sport") dec(3) keep(treated) label nocons 
areg perceived_health treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/direct_mechanisms_youth.tex", append ctitle("Health") dec(3) keep(treated) label nocons 
areg life_satisfaction treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/direct_mechanisms_youth.tex", append ctitle("Life") dec(3) keep(treated) label nocons 
areg some_school_group treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/direct_mechanisms_youth.tex", append ctitle("Scholastic involvement") dec(3) keep(treated) label nocons 
estimates clear

****************************************************
* Table A3. G8 reform effects on personality traits
****************************************************

clear all
use "$output_data\built_youth_data.dta", clear

global xvar_extended_control female height rural migration_back highest_edu_hh   ///
father_blue_collar work_mother single_parent religion_hh low_perform 

areg std_bigfive_o treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/b5_mechanisms_youth.tex", replace ctitle("Open.") dec(3) keep(treated) label nocons 
areg std_bigfive_c treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/b5_mechanisms_youth.tex", append ctitle("Consc.") dec(3) keep(treated) label nocons 
areg std_bigfive_e treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/b5_mechanisms_youth.tex", append ctitle("Extr.") dec(3) keep(treated) label nocons 
areg std_bigfive_a treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/b5_mechanisms_youth.tex", append ctitle("Agree.") dec(3) keep(treated) label nocons 
areg std_bigfive_n treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/b5_mechanisms_youth.tex", append ctitle("Neurot.") dec(3) keep(treated) label nocons 
areg std_iloc treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)
outreg2 using "$tables/b5_mechanisms_youth.tex", append ctitle("LoC") dec(3) keep(treated) label nocons 
estimates clear

************************************************
* Table A4. Robustness tests 1 
************************************************

* Heterogeneous effect by preparation time
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

gen prep_time = inlist(state,3,9,13,15)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust i.treated i.treated#i.prep_time i.prep_time $xvar, absorb(state) cluster(state)
*margins, dydx(treated) at(prep_time=(1)) 

outreg2 using "$tables/robcheck_preparation_time_youth.tex", replace ctitle(" ") dec(3) keep(1.treated 1.treated#1.prep_time) label nocons 
estimates clear

* Ordered probit regression
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry i.syear

oprobit std_trust_ctg treated $xvar i.state, cluster(state)

outreg2 using "$tables/robcheck_probit_youth.tex", replace ctitle(" ") dec(3) keep(treated) label nocons 
estimates clear

************************************************
* Table A5. Robustness tests 2
************************************************

* Whithout early adopters states where first affected cohort graduated before 2012
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

keep if inlist(state,1,4,5,6,8,11,12)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

outreg2 using "$tables/robcheck_2_youth.tex", replace ctitle("Whithout early  adopters") dec(3) keep(treated) label nocons 
estimates clear

* Whithout states where comprehensive schools is widely extended
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

keep if inlist(state,3,8,9,13,14,15,16)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

outreg2 using "$tables/robcheck_2_youth.tex", append ctitle("Whitout comprehensive schools") dec(3) keep(treated) label nocons 
estimates clear

* Whitout always treated: states of Saxony and Turingia
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

keep if !inlist(state,14,16)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

outreg2 using "$tables/robcheck_2_youth.tex", append ctitle("Without always treated") dec(3) keep(treated) label nocons 
estimates clear

* State with standardized examinations stablished
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

keep if inlist(state,8,9,10,13,14,15,16)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

outreg2 using "$tables/robcheck_2_youth.tex", append ctitle("With standardized examinations") dec(3) keep(treated) label nocons 
estimates clear

* Placebo: effect of G8 reform in other school tracks
********************************************************************************

clear all
use "$my_out_temp\built_var_youth_17_placebo.dta", clear

global xvar female migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

outreg2 using "$tables/robcheck_2_youth.tex", append ctitle("Treatment in other school tracks") dec(3) keep(treated) label nocons 
estimates clear

graph close _all
