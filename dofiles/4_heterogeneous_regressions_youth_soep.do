*******************************************************************************
*******************************************************************************
*********** HETEROGENEOUS EFFECTS
*********** 
*******************************************************************************
*******************************************************************************

clear all

********************************************************************************
* BASIC REGRESSIONS 
*******************************************************************************

use "$output_data\built_youth_data.dta", clear

******************** 1. Heterogeneity by gender

* Regression with interaction plus extended controls

global xvar_no_sex height migration_back rural highest_edu_hh father_blue_collar work_mother ///
religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust i.female i.treated i.female#i.treated $xvar_no_sex, absorb(state) cluster(state)

margins, dydx(treated) at(female=(1)) 
lincom _b[1.treated] + _b[1.female#1.treated]

******************** 2. Heterogeneity by migration background 

* Regression with interaction plus extended controls

global xvar_no_mig female height rural highest_edu_hh father_blue_collar work_mother ///
religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust i.migration_back i.treated i.migration_back#i.treated $xvar_no_mig, absorb(state) cluster(state)

margins, dydx(treated) at(migration_back=(1)) 

******************** 3. Heterogeneity by highest parental education 

* Regression with interaction plus extended controls

global xvar_no_hghst_edu_hh female height migration_back rural father_blue_collar work_mother ///
religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust i.highest_edu_hh i.treated i.highest_edu_hh#i.treated $xvar_no_hghst_edu_hh, absorb(state) cluster(state)
margins, dydx(treated) at(highest_edu_hh=(1)) 

******************** 4. Heterogeneity by working-class father 

* Regression with interaction plus extended controls			  

global xvar_no_blue_collar female height migration_back rural highest_edu_hh work_mother ///
religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust i.father_blue_collar i.treated i.father_blue_collar#i.treated $xvar_no_blue_collar, absorb(state) cluster(state)
margins, dydx(treated) at(father_blue_collar=(1)) 

******************** 5. Heterogeneity by low-performing student

* Regression with interaction plus extended controls				  

global xvar_no_low_perform female height migration_back rural highest_edu_hh father_blue_collar work_mother ///
religion_hh single_parent i.year_hgsch_entry 

areg std_pca_trust i.low_perform i.treated i.low_perform#i.treated $xvar_no_low_perform, absorb(state) cluster(state)
margins, dydx(treated) at(low_perform=(1)) 

******************** 6. Heterogeneity by having many classmates with migration background

* Regression with interaction plus extended controls				  

global xvar_no_migback_class female migration_back rural highest_edu_hh father_blue_collar work_mother ///
religion_hh low_perform single_parent i.year_hgsch_entry 

areg std_pca_trust i.migback_classmate i.treated i.migback_classmate#i.treated $xvar_no_migback_class, absorb(state) cluster(state)
margins, dydx(treated) at(migback_classmate=(1)) 


