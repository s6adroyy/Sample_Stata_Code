*******************************************************************************
*******************************************************************************
*********** ROBUSTNESS CHECKS
*********** 
*******************************************************************************
*******************************************************************************

* Outline
*** 1. Event study analysis
*** 2. Robustness cheks

********************************************************************************
* 1. EVENT STUDY ANALYSIS: Leads and lags of the reform effect
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
 restore 
graph close _all

********************************************************************************
* 2. ROBUSTNESS CHECKS
********************************************************************************

* 2.1. Ordered probit regression with the alternative measure of trust (without PCA)
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent migback_classmate i.year_hgsch_entry

oprobit std_trust_ctg treated $xvar i.state, cluster(state)

* 2.2. Heterogeneous effect by time since implementation
********************************************************************************

clear all
use "$my_out_temp\built_var_youth_17_data.dta", clear

gen trt_year =  .
replace trt_year = 2008 if state==1
replace trt_year = 2002 if state==2
replace trt_year = 2003 if state==3
replace trt_year = 2004 if state==4
replace trt_year = 2005 if state==5
replace trt_year = 2006 if state==6
replace trt_year = 2004 if state==8
replace trt_year = 2003 if state==9
replace trt_year = 2001 if state==10
replace trt_year = 2006 if state==11
replace trt_year = 2006 if state==12
replace trt_year = 2002 if state==13
replace trt_year = 1999 if state==15

gen t = year_hgsch_entry-trt_year if trt_year!=. 

gen cohort = .
replace cohort = 2 if t==1
replace cohort = 3 if (t>=2 & t <=12) | inlist(state,14,16)
replace cohort = 1 if cohort == .

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry i.syear

areg std_pca_trust treated i.cohort $xvar, absorb(state) cluster(state)

* 2.3. Heterogeneous effect by preparation time: surprised states where the first
* cohort affected were already in the secondary school (9th grade)
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

gen prep_time = inlist(state,13,15) 
global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry 
	
areg std_pca_trust 1.treated 1.treated#1.prep_time $xvar, absorb(state) cluster(state)

foreach v in std_bigfive_o std_bigfive_c std_bigfive_e std_bigfive_a std_bigfive_n {
areg `v' 1.treated 1.treated#1.prep_time  $xvar, absorb(state) cluster(state)
margins, dydx(treated) at(prep_time=(1)) 
}

* 2.4. Late adopter states: First cohort affected by the G8 graduated from 2012 on
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

keep if inlist(state,1,4,5,6,8,11,12)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

* 2.5. States where comprehensive schools doesn't exist or the rate of enrollment is below 10%
* Comprehensive school is an alternative to academic high school which also provides a similar curriculum either in 12 or 13 years.
***********************************************************************************************

clear all
use "$my_out_temp\built_var_youth_17_data.dta", clear

keep if inlist(state,3,8,9,13,14,15,16)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry i.syear

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

* 2.6. xclude always treated: Saxony and Turingia which continued under the G8 after the reunification
*********************************************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

keep if !inlist(state,14,16)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent migback_classmate i.year_hgsch_entry 

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

* 2.7. Exclude double cohort: last G8 and first G9
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

gen trt_year =  .
replace trt_year = 2008 if state==1
replace trt_year = 2002 if state==2
replace trt_year = 2003 if state==3
replace trt_year = 2004 if state==4
replace trt_year = 2005 if state==5
replace trt_year = 2006 if state==6
replace trt_year = 2004 if state==8
replace trt_year = 2003 if state==9
replace trt_year = 2001 if state==10
replace trt_year = 2006 if state==11
replace trt_year = 2006 if state==12
replace trt_year = 2002 if state==13
replace trt_year = 1999 if state==15

gen t = year_hgsch_entry-trt_year if trt_year!=. 
drop if t>=-1 & t <=0

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry i.syear

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

* 2.8. States with standardized examinations stablished
********************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

keep if inlist(state,8,9,10,13,14,15,16)

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust treated $xvar, absorb(state) cluster(state)

* 2.9. Placebo: Effect of the G8 reform in other secondary school tracks 
* (secondary general school (Hauptschule) and intermediate school (Realschule))
********************************************************************************

clear all
use "$output_data\built_youth_data_placebo.dta", clear

global xvar female height migration_back rural highest_edu_hh father_blue_collar ///
work_mother religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust treated $xvar, absorb(state) cluster(state)
