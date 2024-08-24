*******************************************************************************
*******************************************************************************
*********** MAIN REGRESSIONS 
*********** 
*******************************************************************************
*******************************************************************************

********************************************************************************
* BASIC REGRESSIONS 
*******************************************************************************

clear all

use "$output_data\built_youth_data.dta", clear

* Basic regression without controls
areg std_pca_trust treated i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated i.year_hgsch_entry, absorb(state) cluster(state)

* Basic regression + female
areg std_pca_trust treated female i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated female i.year_hgsch_entry, absorb(state) cluster(state)

* Basic regression + female + migration background
areg std_pca_trust treated female migration_back i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated female migration_back i.year_hgsch_entry, absorb(state) cluster(state)

* Basic regression + female + migration background + rural
areg std_pca_trust treated female migration_back rural i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated female migration_back rural i.year_hgsch_entry, absorb(state) cluster(state)

* Basic regression + female + migration background + rural + highest parental educ.
areg std_pca_trust treated female migration_back rural highest_edu_hh i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated female migration_back rural highest_edu_hh i.year_hgsch_entry, absorb(state) cluster(state)

* Basic regression + female + migration background + rural + highest parental educ. + father_blue_collar + work_mother 
areg std_pca_trust treated female migration_back rural highest_edu_hh father_blue_collar work_mother  ///
i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated female migration_back rural highest_edu_hh father_blue_collar work_mother ///
i.year_hgsch_entry, absorb(state) cluster(state)

* Basic regression + female + migration background + rural + highest parental educ. + father_blue_collar + work_mother + religion + low performance + single_parent
areg std_pca_trust treated female migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent ///
i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated female migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent ///
i.year_hgsch_entry, absorb(state) cluster(state)

* Basic regression + female + height + migration background + rural + highest parental educ. + father_blue_collar + work_mother + religion + low performance + single_parent
areg std_pca_trust treated female height migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent ///
i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated female height migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent ///
i.year_hgsch_entry, absorb(state) cluster(state)

/* Basic regression + female + height + migration background + rural + highest parental educ. + father_blue_collar + work_mother + religion + low performance + single_parent 
 + migration background of classmates */
areg std_pca_trust treated female height migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent migback_classmate ///
i.year_hgsch_entry, absorb(state) cluster(state)
areg std_trust_ctg treated female height migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent migback_classmate ///
i.year_hgsch_entry, absorb(state) cluster(state)

/* Basic regression + female + height + migration background + rural + highest parental educ. + father_blue_collar + work_mother + religion + low performance + single_parent 
 + bigfive variables*/
areg std_pca_trust treated female height migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent ///
std_bigfive_o std_bigfive_c std_bigfive_e std_bigfive_a std_bigfive_n i.year_hgsch_entry, absorb(state) cluster(state)

/* Basic regression + female + height + migration background + rural + highest parental educ. + father_blue_collar + work_mother + religion + low performance + single_parent 
 + migration background of classmates + bigfive variables*/
areg std_pca_trust treated female height migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent migback_classmate ///
std_bigfive_o std_bigfive_c std_bigfive_e std_bigfive_a std_bigfive_n i.year_hgsch_entry, absorb(state) cluster(state)

********************************************************************************
* BASIC REGRESSIONS ON EACH COMPONENT OF TRUST
********************************************************************************

* General trust
areg std_trust_people treated female height migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent ///
i.year_hgsch_entry, absorb(state) cluster(state)

* Trust  on at least someone
areg std_rely_someone treated female height migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent ///
i.year_hgsch_entry, absorb(state) cluster(state)

* Trust  on strangers
areg std_trust_strangers treated female height  migration_back rural highest_edu_hh father_blue_collar work_mother religion_hh low_perform single_parent ///
i.year_hgsch_entry, absorb(state) cluster(state)
