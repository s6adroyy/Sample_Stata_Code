*******************************************************************************
*******************************************************************************
*********** DESCRIPTIVE STATISTICS 
*********** *******************************************************************************
*******************************************************************************

*********************************************************************************************
* Table of descriptive statistics od dependent and independent variables by treatment status
*********************************************************************************************

clear all

use "$output_data\built_youth_data.dta", clear

egen ave_trust = rowmean(trust_people rely_someone trust_strangers)
local all_variables ave_trust female height east rural migration_back highest_edu_hh father_blue_collar work_mother single_parent religion_hh low_perform

estpost ttest `all_variables', by(treated) listwise
esttab ., cells("mu_1(fmt(2) label(Control)) mu_2(fmt(2) label(Treated)) t(fmt(2))") nonumber  label

********************************************************************************
* Graph of descriptive statistics of independent variables by treatment status
********************************************************************************

clear all

use "$output_data\built_youth_data.dta", clear

set scheme s2color

/*we only include individuals who successfully answered the three different measures
of trust and provided valid information on their background and family characteristics.*/
global xvar_extended_control female height rural migration_back highest_edu_hh   ///
father_blue_collar work_mother single_parent religion_hh low_perform
missings tag std_pca_trust treated $xvar_extended_control year_hgsch_entry state, gen(miss)
keep if miss==0

keep female rural migration_back highest_edu_hh father_blue_collar work_mother single_parent religion_hh low_perform treated
tabulate female, gen(female_)
tabulate migration_back, gen(migration_back_)
tabulate highest_edu_hh, gen(highest_edu_hh_)
tabulate father_blue_collar, gen(father_blue_collar_)
tabulate single_parent, gen(single_parent_)
tabulate religion_hh, gen(religion_hh_)
tabulate low_perform, gen(low_perform_)

matrix m1 = J(7,3,.)
matrix list m1 
sum female if treated==1
matrix m1[1, 2] = round(`r(mean)', .01) 	
sum migration_back if treated==0
matrix m1[2, 2] = round(`r(mean)', .01) 	
sum highest_edu_hh if treated==0
matrix m1[3, 2] = round(`r(mean)', .01) 
sum father_blue_collar if treated==0
matrix m1[4, 2] = round(`r(mean)', .01) 
sum single_parent if treated==0
matrix m1[5, 2] = round(`r(mean)', .01) 
sum religion_hh if treated==0
matrix m1[6, 2] = round(`r(mean)', .01) 	
sum low_perform if treated==0
matrix m1[7, 2] = round(`r(mean)', .01)
	
sum female if treated==1
matrix m1[1, 3] = round(`r(mean)', .01) 	
sum migration_back if treated==1
matrix m1[2, 3] = round(`r(mean)', .01) 	
sum highest_edu_hh if treated==1
matrix m1[3, 3] = round(`r(mean)', .01) 
sum father_blue_collar if treated==1
matrix m1[4, 3] = round(`r(mean)', .01) 
sum single_parent if treated==1
matrix m1[5, 3] = round(`r(mean)', .01) 
sum religion_hh if treated==1
matrix m1[6, 3] = round(`r(mean)', .01) 	
sum low_perform if treated==1
matrix m1[7, 3] = round(`r(mean)', .01) 	

clear
svmat m1, names(col) 
tostring c1, replace 

replace c1 = "Female"				if _n == 1
replace c1 = "Migration back."		if _n == 2
replace c1 = "High parental educ." 	if _n == 3
replace c1 = "Working-class father"	if _n == 4
replace c1 = "Single parent"		if _n == 5
replace c1 = "Christian parents" 	if _n == 6
replace c1 = "Low-perform. student" if _n == 7

label variable c2 "Control" 
label variable c3 "Treatment"
matrix list m1 

seqvar axis =  1 2 3 4 5 6 7
labmask axis, values(c1)

graph hbar (mean) c2 c3 , over(axis, lab(labsize(vlarge))) ylabel(0(0.2)1,labsize(vlarge)) ///
bar(1, fcolor(red)) bar(2, fcolor(blue)) legend( label(1 "Control") label(2 "Treatment") size(vlarge) stack) ///
scale(0.5) graphregion(color(white)) blabel(bar, format(%9.2f) size(vlarge) pos(inside) color(black)) intensity(30) 

graph export "$figures\descriptive_stats.png", replace

graph close _all