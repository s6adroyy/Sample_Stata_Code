*******************************************************************************
*******************************************************************************
*********** CLEAN DATASET AND BUILD VARIABLES 
*********** 
*******************************************************************************
*******************************************************************************

* Outline
*** 1. Clean dataset and built variables for main analysis (main regressions, heterogeneous effects, etc.)
*** 2. Clean and built variables for event_study analysis
*** 3. Clean and built variables for placebo estimation

**************************************************************************************
* 1. Clean dataset and built variables for main analysis (main regressions, heterogeneous effects, etc.)
**************************************************************************************

* 1.1 Clean dataset
*******************************************************************************

clear all
use "$input_data/merge_original_youth_data.dta", clear

/* Since 2006 SOEP has provided self-ratings of trust for 17 year-old 
adolescents. We will keep the surveys until 2018. From 2019 on we see some states going back to the G9 structure.*/
keep if inrange(syear,2006,2018)

/* We exclude data sampled as part of the newest inmigration samples since recent inmigrants and refugees are sampled in these data.*/
tab psample
//keep if (psample>=1 & psample<=11) | (psample>=20 & psample<=23) 
keep if !inrange(psample,15,19)

/* We keep all adolescents who are 17 years old at the time of the survey*/
gen age =  syear - jl0233
tab age
keep if age == 17

/* We select all adolescents who are in academic track high school (Gymnasium) at the time of the survey or had earned a high school diploma*/
gen gymnasium = .
replace gymnasium = 1 if (jl0125_v3 == 3) | (jl0125_v3 == 6 & jl0127_h == 4)
replace gymnasium = 0 if inlist(jl0125_v3,1,2,4,5) | (jl0125_v3 == 6 & jl0127_h != 4)
tab gymnasium
keep if gymnasium == 1

/* We exclude individuals who repeated one or more grades or did not answer this question */
keep if jl0164==2

* To identify whether a student is affected by the reform, we use the information on the federal state of residence and the year of school entry.
/* We use the federal state of residence at the time of the survey when the individual was 17 y.o.*/
rename bula_h state /*"bula_h: state of residence at the time of the survey"*/
/* There is an alternative way to define the state of residence using the variable "bex4fst: last observed year in school, Fed. State" */
*gen state = .
*replace state = bex4fst if (bex4fst!=-2 & bex4fst!=.)
*replace state = bula_h if state==.

/* We use a variable that indicates the year of high school entry. 
In case of missings, the the year of high-school entry is imputed from the date of birth. */
/* We exclude students for which we don't have enought information regarding their year of high school entry:*/
gen year_hgsch_entry = .
replace year_hgsch_entry = bet3year if (bet3year!=-2 & bet3year!=.) /*"bet3year: transition to sec. school, year"*/
replace year_hgsch_entry = gebjahr + 10 if !inlist(state,11,12,13) & year_hgsch_entry==. /*gebjahr: Year of Birth*/
replace year_hgsch_entry = gebjahr + 12 if inlist(state,11,12,13) & year_hgsch_entry==. 
/*In Berlin, Brandenburg and Mecklenburg-West Pomerania academic, high school only starts from grade 7 on." 
/* There is an alternative and more restrictive way to fill the missings depending on the year and month of birth,
however the birthday cut off for entry to primary school varies by state and to the best of our knowledge it does not seem compulsory */
*replace year_hgsch_entry = gebjahr + 10 if inrange(gebmonat,1,6) & !inlist(state,11,12,13) & year_hgsch_entry==.
*replace year_hgsch_entry = gebjahr + 12 if inrange(gebmonat,1,6) & inlist(state,11,12,13) & year_hgsch_entry==.
*replace year_hgsch_entry = gebjahr + 11 if inrange(gebmonat,7,12) & !inlist(state,11,12,13) & year_hgsch_entry==.
*replace year_hgsch_entry = gebjahr + 13 if inrange(gebmonat,7,12) & inlist(state,11,12,13) & year_hgsch_entry==.*/
tab year_hgsch_entry, missing
/* We exclude students for which we don't have enought information regarding their year of high school entry:*/
keep if year_hgsch_entry != .

tempfile partial_clean_youth_data
save `partial_clean_youth_data', replace

use `partial_clean_youth_data', clear
/* We exclude students from Hesse who entered high school in 2004 or 2005 when schools operated under both schemes (G8 and G9)*/
drop if (state == 6 & (inlist(year_hgsch_entry,2004,2005)))

/*We exclude students from Rhineland-Palatinate where the reform has not been implemented state-wide*/
keep if state != 7 

/* Defining treatment and control groups */
gen treated = .
replace treated = 1 if state==14 | state==16 | /// Saxony and Thuringia
		(state==1 & (year_hgsch_entry >= 2008))  | /// Schleswig-Holstein 
		(state==2 & (year_hgsch_entry >= 2002)) | /// Hamburg
		(state==3 & (year_hgsch_entry >= 2003)) | /// Niedersachsen and Lower Saxony
		(state==4 & (year_hgsch_entry >= 2004)) | /// Bremen
		(state==5 & (year_hgsch_entry >= 2005)) | /// Nordrhein-Westfalen * 
		(state==6 & (year_hgsch_entry >= 2006)) | /// Hesse
		(state==8 & (year_hgsch_entry >= 2004)) | /// Baden-Wuerttemberg
		(state==9 & (year_hgsch_entry >= 2003)) | /// Bayern or Bavaria
		(state==10 & (year_hgsch_entry >= 2001)) | /// Saarland 
		(state==11 & (year_hgsch_entry >= 2006)) | /// Berlin
		(state==12 & (year_hgsch_entry >= 2006)) | /// Brandenburg
		(state==13 & (year_hgsch_entry >= 2002)) | /// Mecklenburg-Vorpommern
		(state==15 & (year_hgsch_entry >= 1999)) // Sachsen-Anhalt or Saxony Anhalt
replace treated = 0 if treated == .

tab treated

/* We exclude any possibility of someone being interviewed twice*/
bysort pid (syear): keep if _n == 1

tempfile clean_youth_data
save `clean_youth_data', replace

* 1.2 Build variables
*******************************************************************************

use `clean_youth_data', clear

/****************************** Dependent variables ****************************/

* Variable trust

rename (jl0361 jl0362 jl0363)(trust_people rely_noone distrust_strangers)
replace trust_people = . if trust_people < 0
replace rely_noone = . if rely_noone < 0
replace distrust_strangers = . if distrust_strangers < 0
/*We reverse the scale for "nagetive" items*/
gen trust_strangers = 8-distrust_strangers if distrust_strangers!=. 
gen rely_someone = 8-rely_noone if rely_noone!=.    

/* We use the principal component analysis to combine the information from the three separate measures of trust into
a scalar measure*/
global trust_var trust_people rely_someone trust_strangers
describe $trust_var
summarize $trust_var
corr $trust_var
// Principal component analysis 
pca $trust_var
pca $trust_var, mineigen(1)
// Scores of the components
predict pca_trust, score
sum pca_trust, detail
// The Kaiser–Meyer–Olkin (KMO) measure of sampling adecuacy: 
// The statistic is a measure of the proportion of variance among variables that might be common variance. 
// The higher the proportion, the higher the KMO-value
estat kmo
egen std_pca_trust = std(pca_trust)

/*Alternatively, we generate the trust measure by adding up scores*/
gen trust_ctg = trust_people + rely_someone + trust_strangers
/*Standarizing trust measure*/ 
egen std_trust_ctg = std(trust_ctg)

/*Additionally, we standardize each of the three separate measures of trust*/
egen std_trust_strangers = std(trust_strangers)
egen std_rely_someone = std(rely_someone)
egen std_trust_people = std(trust_people)

/**************************** Independent variables ***************************/

* Variable state 
tab state, missing

* Variable age
tab age, missing

* Variable sex 
recode sex (1=0) (2=1), gen(female) //male 1 and female 2 
tab female, missing

* Variable rural area
gen rural = (jl0272==4)
replace rural = . if inrange(jl0272,-5,-1) | jl0272==.
tab rural, missing
	  
* Variable East-Germany
gen east = inrange(state,11,16)
tab east, missing

* Variable migration background 
gen migration_back = inlist(migback,2,3) 
tab migration_back, missing

* Variable low-performing student
gen low_perform = (jl0151!=3)
replace low_perform = . if jl0151==-1
tab low_perform, missing

* Variable highest level of education of parents 
recode fsedu (-5/-1 = .) (0/3 = 0) (5/9 = 0) (4=1), gen(father_educ1)
recode msedu (-5/-1 = .) (0/3 = 0) (5/9 = 0) (4=1), gen(mother_educ1)
recode fprofedu (-5/-1 = .) (0/29 = 0) (40/51 = 0) (30/32=1), gen(father_educ2)
recode mprofedu (-5/-1 = .) (0/29 = 0) (40/51 = 0) (30/32=1), gen(mother_educ2)

gen highest_edu_hh = .
replace highest_edu_hh = 1 if father_educ1==1 | mother_educ1==1 | father_educ2==1 | mother_educ2==1
replace highest_edu_hh = 0 if father_educ1==0 & mother_educ1==0 & father_educ2==0 & mother_educ2==0 
tab highest_edu_hh, missing

* Variable religion: Christian parents
recode freli (-5/-1 = .) (1 2 = 1) (3/7 = 0), gen(father_religion)
recode mreli (-5/-1 = .) (1 2 = 1) (3/7 = 0), gen(mother_religion)

gen religion_hh = .
replace religion_hh = 1 if father_religion==1 | mother_religion==1 
replace religion_hh = 0 if father_religion==0 & mother_religion==0 
tab religion_hh, missing

* Variable Working-class father
/* Dummy for father having blue-collar occupation when student is aged 15, 
reference category encompasses all others*/
gen father_blue_collar = inrange(fegp88,8,11)
replace father_blue_collar = . if inlist(fegp88,-2,-1) 
tab father_blue_collar, missing

* Variable working mother
/*Dummy for working mother (both full-time and part-time)
when student is aged 15*/
gen work_mother = !inrange(mprofstat,10,15)
replace work_mother = . if mprofstat==. | inrange(mprofstat,-5,-1)
tab work_mother, missing

* Variable single parent
/*Dummy for not having lived with both parents for the entire
time up to age 15*/
gen single_parent = inrange(living1,0,14) 
replace single_parent = . if living1==. | inrange(living1,-5,-1)
tab single_parent, missing

* Variable migration background of classmates in school
/*Dummy for having classmates with a migration background: 
If you think back to the last grade of school you attended: How many of your 
fellow students or their parents were not from Germany?*/
gen migback_classmate = inrange(jl0176_h,1,5) 
replace migback_classmate = . if jl0176_h==. | inrange(jl0176_h,-5,-1)
tab migback_classmate, missing
	  
* Variable height
rename jl0219 height
recode height (-5/-1 = .)

/********************************** Mechanisms ********************************/

* Perceived health status
gen perceived_health = inrange(jl0218,1,2)
replace perceived_health = . if inrange(jl0218,-8,-1) | jl0218 ==.

* Musically active
gen music_active = (jl0074==1)
replace music_active = . if inrange(jl0074,-8,-1) | jl0074 ==.

* Participate actively in sports 
gen sport_active = (jl0105_h==1)
replace sport_active = . if inrange(jl0105_h,-8,-1) | jl0105_h ==.

* Frequency of participation on recreational activities at least once in a day or in a week
recode jl0058 jl0059_h jl0061 jl0062 jl0063 jl0064 jl0065 jl0066 jl0067 jl0068 jl0069 jl0070 (-8/-1 = .) (1 = 1) (2/5 = 0), pre(new)
recode jl0071 jl0073 (-8/-1 = .) (1/2 = 1) (3/5 = 0), pre(new)
rename (newjl0058 newjl0059_h newjl0061 newjl0062 newjl0063 newjl0064 newjl0065 newjl0066 ///
	    newjl0067 newjl0068 newjl0069 newjl0070 newjl0071 newjl0073) ///
		(watch_tv play_cmptr_games listen_music play_music_sing_day do_sports_day dance_act tech_activities ///
		read do_nothing time_with_gbfriend time_with_bestfriend time_with_gfriends time_youth_centre time_church)
recode jl0062 (-8/-1 = .) (1/2 = 1) (3/5 = 0), gen(play_music_sing_week)
recode jl0063 (-8/-1 = .) (1/2 = 1) (3/5 = 0), gen(do_sports_week)

recode jl0060_v* (-8/-1 = .) (1 = 1) (2/5 = 0), pre(new)
gen online_scl_ntwrk = (newjl0060_v1==1 | newjl0060_v2==1 | newjl0060_v3==1 | newjl0060_v4==1)
replace online_scl_ntwrk = . if (newjl0060_v1==. & newjl0060_v2==. & newjl0060_v3==. & newjl0060_v4==.)

* Political interest
gen political_interest = inlist(jl0388,1,2)
replace political_interest = . if inrange(jl0388,-8,-1) | jl0388==.

* Volunteer work at least one in a week
gen volunteer_work_week = inrange(jl0072,1,2)
replace volunteer_work_week = . if inrange(jl0072,-8,-1) | jl0072==.
* Volunteer work at least one in a month
gen volunteer_work_month = inrange(jl0072,1,3)
replace volunteer_work_month = . if inrange(jl0072,-8,-1) | jl0072==.

* Scholastic involvement: taking part in group activities inside the high school
recode jl0139 jl0140 jl0141 jl0142 jl0143 jl0144 jl0145 jl0146 (-2 = 0) (-1=.) (1 = 1), pre(new)
rename (newjl0139 newjl0140 newjl0141 newjl0142 newjl0143 newjl0144 newjl0145 newjl0146) ///
 (class_rprsttv student_rprsttv school_magazine drama_dance_group choir_orchestra sport_group other_school_group none_school_activity)
gen some_school_group = (none_school_activity==1)
replace some_school_group = . if none_school_activity==.

* Time with friends (daily meeting)
gen time_with_friends = .
replace time_with_friends = 1 if (time_with_gbfriend==1 | time_with_bestfriend==1 | time_with_gfriends==1)
replace time_with_friends = 0 if (time_with_gbfriend==0 & time_with_bestfriend==0 & time_with_gfriends==0)

* Satisfaction with life
recode jl0392 (-5/-1 = .)
egen life_satisfaction = std(jl0392) 

* Satisfaction with school grades
egen grades_satisfaction = std(jl0147)
egen math_satisfaction = std(jl0149)
egen german_satisfaction = std(jl0148)

* Big five (Alonsgide the original dataset we found a dofile calculating the "big five")

* REVERSE THE SCALE FOR "NEGATIVE" ITEMS
g jl0367r=1 if jl0367==7
replace jl0367r=2 if jl0367==6
replace jl0367r=3 if jl0367==5
replace jl0367r=4 if jl0367==4
replace jl0367r=5 if jl0367==3
replace jl0367r=6 if jl0367==2
replace jl0367r=7 if jl0367==1

g jl0371r=1 if jl0371==7
replace jl0371r=2 if jl0371==6
replace jl0371r=3 if jl0371==5
replace jl0371r=4 if jl0371==4
replace jl0371r=5 if jl0371==3
replace jl0371r=6 if jl0371==2
replace jl0371r=7 if jl0371==1

g jl0376r=1 if jl0376==7
replace jl0376r=2 if jl0376==6
replace jl0376r=3 if jl0376==5
replace jl0376r=4 if jl0376==4
replace jl0376r=5 if jl0376==3
replace jl0376r=6 if jl0376==2
replace jl0376r=7 if jl0376==1

g jl0379r=1 if jl0379==7
replace jl0379r=2 if jl0379==6
replace jl0379r=3 if jl0379==5
replace jl0379r=4 if jl0379==4
replace jl0379r=5 if jl0379==3
replace jl0379r=6 if jl0379==2
replace jl0379r=7 if jl0379==1

* GENERATE BIG FIVE MEASURES BY ADDING UP SCORES
g bigfive_c=jl0365+jl0371r+jl0375
g bigfive_e=jl0366 +jl0372+jl0376r
g bigfive_a=jl0367r+jl0370+jl0377
g bigfive_o=jl0368 +jl0373+jl0378+jl0380
g bigfive_n=jl0369+jl0374 +jl0379r

label variable bigfive_c  "Conscientiousness"
label variable bigfive_e  "Extraversion"
label variable bigfive_a  "Agreeableness"
label variable bigfive_o  "Openness to experience"
label variable bigfive_n  "Neuroticism"

* STANDARDIZING BIG FIVE MEASURES
egen std_bigfive_c=std(bigfive_c)
egen std_bigfive_e=std(bigfive_e)
egen std_bigfive_a=std(bigfive_a)
egen std_bigfive_o=std(bigfive_o)
egen std_bigfive_n=std(bigfive_n)

label variable std_bigfive_c  "Std. Conscientiousness"
label variable std_bigfive_e  "Std. Extraversion"
label variable std_bigfive_a  "Std. Agreeableness"
label variable std_bigfive_o  "Std. Openness to experience"
label variable std_bigfive_n  "Std. Neuroticism"

rename (jl0350_v1 jl0351_v2 jl0352_v2 jl0353_v2 jl0354_v2 jl0355_v1 jl0356_v2 jl0357_v2 jl0358_v2 jl0359_v2)(ILOC1 ELOC1 ELOC2 ELOC3 ILOC2 ELOC4 ELOC5 ELOC6 ELOC7 ILOC3)
replace ILOC1= . if ILOC1 < 0
replace ELOC1 = . if ELOC1 < 0
replace ELOC2 = . if ELOC2 < 0
replace ELOC3 = . if ELOC3 < 0
replace ILOC2 = . if ILOC2 < 0
replace ELOC4 = . if ELOC4 < 0
replace ELOC5 = . if ELOC5 < 0
replace ELOC6 = . if ELOC6 < 0
replace ELOC7 = . if ELOC7 < 0 
replace ILOC3 = . if ILOC3 < 0 
gen ILOC4 = 8-ELOC1 if ELOC1!=.
gen ILOC5 = 8-ELOC2 if ELOC2!=.
gen ILOC6 = 8-ELOC3 if ELOC3!=. 
gen ILOC7 = 8-ELOC4 if ELOC4!=.
gen ILOC8 = 8-ELOC5 if ELOC5!=.
gen ILOC9 = 8-ELOC6 if ELOC6!=.
gen ILOC10 = 8-ELOC7 if ELOC7!=.
gen internal_loc = ILOC1+ILOC2+ILOC3+ILOC4+ILOC5+ILOC6+ILOC7+ILOC8+ILOC9+ILOC10
egen std_iloc = std(internal_loc)

label variable internal_loc  "Locus of control"
label variable std_iloc  "Std. Locus of control"

* 1.3. Label variables
*******************************************************************************

label variable treated "G8 reform"
label variable pca_trust "PCA Trust" 
label variable std_pca_trust "Std. PCA trust" 
label variable std_trust_ctg "Std. Trust (categorical var.)" 
label variable std_trust_strangers "Std. trust strangers" 
label variable std_rely_someone "Std. rely on someone" 
label variable std_trust_people "Std. trust people" 
label variable trust_strangers "Trust strangers" 
label variable rely_someone "Rely on someone" 
label variable trust_people "Trust people" 

label variable female "Female" 
label variable age "Age"
label variable east "East" 
label variable height "Height (cm)"
label variable rural "Rural area" 
label variable migration_back "Migration background" 
label variable low_perform "Low-performing student" 
label variable highest_edu_hh "High parental ducation" 
label variable religion_hh "Christian parents" 
label variable father_blue_collar "Working-class father"
label variable work_mother "Working mother"
label variable single_parent "Single parent"
label variable migback_classmate "Classmates with migration background"

label variable some_school_group "Scholastic involvement"
label variable life_satisfaction "Life satisfaction" 
label variable grades_satisfaction "School"
label variable math_satisfaction "Math"
label variable german_satisfaction "Literature"
label variable perceived_health "Perceived health status"
label variable music_active "Musically active"
label variable sport_active "Active in sports"
label variable watch_tv "Watch TV, video daily"
label variable play_cmptr_games "Play computer games daily" 
label variable listen_music "Listen to music daily"
label variable play_music_sing_day "Play music or sing daily"
label variable do_sports_day "Do sports daily"
label variable play_music_sing_week "Play music or sing weekly"
label variable do_sports_week "Do sports weekly"
label variable dance_act "Dance or act daily"
label variable tech_activities "Do tech. activities daily"
label variable read "Read daily"
label variable do_nothing "Do nothing daily"    
label variable time_with_gbfriend "Spend time with boy-girl/friend daily"
label variable time_with_bestfriend "Spend time with best friend daily"
label variable time_with_gfriends "Spend time with group of friends daily"
label variable time_with_friends "Spend time with friends in general every day"
label variable time_youth_centre "Spend time in recreation center once in a week"
label variable time_church "Spend time attending religious events once in a week"
label variable online_scl_ntwrk "Beeing online on social networks daily"
label variable political_interest "Political interest"
label variable volunteer_work_month "Volunteer"
label variable volunteer_work_week "Volunteer"
label variable class_rprsttv "Class representative"
label variable student_rprsttv "Student body president"
label variable school_magazine "Involved with school magazine"
label variable drama_dance_group "Belong to theatre, dance group"
label variable choir_orchestra "Belong to choir, orchestra, music group"
label variable sport_group "Belong to sport group"
label variable other_school_group "Other kind of school group"
label variable none_school_activity "No involvement with school group"
label variable state "State of residence"
label variable year_hgsch_entry "Year of high school entry"

keep cid hid pid syear state year_hgsch_entry treated pca_trust std_pca_trust ///
std_trust_ctg std_trust_strangers std_rely_someone trust_people rely_someone trust_strangers ///
std_trust_people female age east height rural migration_back low_perform highest_edu_hh ///
religion_hh father_blue_collar work_mother single_parent migback_classmate some_school_group ///
life_satisfaction grades_satisfaction math_satisfaction german_satisfaction perceived_health ///
music_active sport_active watch_tv play_cmptr_games listen_music play_music_sing_day ///
play_music_sing_week do_sports_week do_sports_day dance_act tech_activities read do_nothing ///
time_with_gbfriend time_with_bestfriend time_with_gfriends time_with_friends time_youth_centre ///
time_church online_scl_ntwrk political_interest volunteer_work_month volunteer_work_week ///
class_rprsttv student_rprsttv school_magazine drama_dance_group choir_orchestra sport_group ///
other_school_group none_school_activity bex4fst std_bigfive_c std_bigfive_e std_bigfive_a ///
std_bigfive_o std_bigfive_n std_iloc bigfive_c bigfive_e bigfive_a bigfive_o bigfive_n internal_loc

save "$output_data\built_youth_data.dta", replace

*******************************************************************************
* 2. Clean and built variables for event_study analysis
*******************************************************************************

* 2.1 Clean dataset
*******************************************************************************

use `partial_clean_youth_data', clear

/*We need pure control states. That is the case 
of Scheleswig-Holstein and Rhineland Palatine untilapproximately 2013. These states
introduced the G8 reform in 2008, the first cohort graduated around 2015.*/
keep if inrange(syear,2006,2013) 

/*The reform was gradually introduced in Hesse, the first affected cohort graduated from 2012 through 2014.*/
drop if state == 6 

/* We create the leads and lags around the year of the introduction of the reform*/
gen trt_year =  .
replace trt_year = 2002 if state==2
replace trt_year = 2003 if state==3
replace trt_year = 2004 if state==4
replace trt_year = 2005 if state==5
replace trt_year = 2004 if state==8
replace trt_year = 2003 if state==9
replace trt_year = 2001 if state==10
replace trt_year = 2006 if state==11
replace trt_year = 2006 if state==12
replace trt_year = 2002 if state==13
replace trt_year = 1999 if state==15

gen trt_state = .
replace trt_state = 1 if inrange(state,2,5) | inrange(state,8,13) | state==15
replace trt_state = 0 if inlist(state,1,7)

gen t=year_hgsch_entry-trt_year
keep if trt_state==0 | (trt_state==1 & inrange(t,-4,4)) /*keep four years before and after treatment*/
egen mint=min(t), by(state)
egen maxt=max(t), by(state)
drop if trt_state==1 & (mint>-2 | maxt<1) /*require at least two years of data before and after treatment*/

forvalues i=1/4 {
 gen _m`i'=(t==-`i')
 gen _p`i'=(t==`i')
}

gen init = t == 0
drop _m4 /*. Four years before the merger will be the omitted category (reference category) in our event-study analysis*/

/* We exclude any possibility of someone being interviewed twice*/
bysort pid (syear): keep if _n == 1

tempfile clean_youth_data_event_study
save `clean_youth_data_event_study', replace

* 2.2 Build variables
*******************************************************************************

use `clean_youth_data_event_study', clear

/****************************** Dependent variables ****************************/

* Variable trust

rename (jl0361 jl0362 jl0363)(trust_people rely_noone distrust_strangers)
replace trust_people = . if trust_people < 0
replace rely_noone = . if rely_noone < 0
replace distrust_strangers = . if distrust_strangers < 0
/*We reverse the scale for "nagetive" items*/
gen trust_strangers = 8-distrust_strangers if distrust_strangers!=. 
gen rely_someone = 8-rely_noone if rely_noone!=.    

/* We use the principal component analysis to combine the information from the three separate measures of trust into
a scalar measure*/
global trust_var trust_people rely_someone trust_strangers
describe $trust_var
summarize $trust_var
corr $trust_var
// Principal component analysis 
pca $trust_var
pca $trust_var, mineigen(1)
// Scores of the components
predict pca_trust, score
sum pca_trust, detail
// The Kaiser–Meyer–Olkin (KMO) measure of sampling adecuacy: 
// The statistic is a measure of the proportion of variance among variables that might be common variance. 
// The higher the proportion, the higher the KMO-value
estat kmo
egen std_pca_trust = std(pca_trust)

/*Alternatively, we generate the trust measure by adding up scores*/
gen trust_ctg = trust_people + rely_someone + trust_strangers
/*Standarizing trust measure*/ 
egen std_trust_ctg = std(trust_ctg)

/*Additionally, we standardize each of the three separate measures of trust*/
egen std_trust_strangers = std(trust_strangers)
egen std_rely_someone = std(rely_someone)
egen std_trust_people = std(trust_people)

/**************************** Independent variables ***************************/

* Variable state 
tab state, missing

* Variable age
tab age, missing

* Variable sex 
recode sex (1=0) (2=1), gen(female)
tab female, missing

* Variable rural area
gen rural = (jl0272==4)
replace rural = . if inrange(jl0272,-5,-1) | jl0272==.
tab rural, missing
	  
* Variable East-Germany
gen east = inrange(state,11,16)
tab east, missing

* Variable migration background 
gen migration_back = inlist(migback,2,3) 
tab migration_back, missing

* Variable low-performing student
gen low_perform = (jl0151!=3)
replace low_perform = . if jl0151==-1
tab low_perform, missing

* Variable highest level of education of parents 
recode fsedu (-5/-1 = .) (0/3 = 0) (5/9 = 0) (4=1), gen(father_educ1)
recode msedu (-5/-1 = .) (0/3 = 0) (5/9 = 0) (4=1), gen(mother_educ1)
recode fprofedu (-5/-1 = .) (0/29 = 0) (40/51 = 0) (30/32=1), gen(father_educ2)
recode mprofedu (-5/-1 = .) (0/29 = 0) (40/51 = 0) (30/32=1), gen(mother_educ2)

gen highest_edu_hh = .
replace highest_edu_hh = 1 if father_educ1==1 | mother_educ1==1 | father_educ2==1 | mother_educ2==1
replace highest_edu_hh = 0 if father_educ1==0 & mother_educ1==0 & father_educ2==0 & mother_educ2==0 
tab highest_edu_hh, missing

* Variable religion: Christian parents
recode freli (-5/-1 = .) (1 2 = 1) (3/7 = 0), gen(father_religion)
recode mreli (-5/-1 = .) (1 2 = 1) (3/7 = 0), gen(mother_religion)

gen religion_hh = .
replace religion_hh = 1 if father_religion==1 | mother_religion==1 
replace religion_hh = 0 if father_religion==0 & mother_religion==0 
tab religion_hh, missing

* Variable Working-class father
/* Dummy for father having blue-collar occupation when student is aged 15, 
reference category encompasses all others*/
gen father_blue_collar = inrange(fegp88,8,11)
replace father_blue_collar = . if inlist(fegp88,-2,-1) 
tab father_blue_collar, missing

* Variable working mother
/*Dummy for working mother (both full-time and part-time)
when student is aged 15*/
gen work_mother = !inrange(mprofstat,10,15)
replace work_mother = . if mprofstat==. | inrange(mprofstat,-5,-1)
tab work_mother, missing

* Variable single parent
/*Dummy for not having lived with both parents for the entire
time up to age 15*/
gen single_parent = inrange(living1,0,14) 
replace single_parent = . if living1==. | inrange(living1,-5,-1)
tab single_parent, missing

* Variable migration background of classmates in school
/*Dummy for having classmates with a migration background: 
If you think back to the last grade of school you attended: How many of your 
fellow students or their parents were not from Germany?*/
gen migback_classmate = inrange(jl0176_h,1,5) 
replace migback_classmate = . if jl0176_h==. | inrange(jl0176_h,-5,-1)
tab migback_classmate, missing
	  
* Variable height
rename jl0219 height
recode height (-5/-1 = .)

* 2.3. Label variables
*******************************************************************************

label variable _m3 "=1 for 3 years previous the G8 reform"
label variable _m2 "=1 for 2 years previous the G8 reform"
label variable _m1 "=1 for 1 year previous the G8 reform"
label variable init "=1 for the year of the introduction of the g8 reform"
label variable _p1 "=1 if treated 1 year after the G8 reform"
label variable _p2 "=1 if treated 2 years after the G8 reform"
label variable _p3 "=1 if treated 3 years after the G8 reform"
label variable _p4 "=1 if treated 4 years after the G8 reform"     
label variable pca_trust "PCA Trust" 
label variable std_pca_trust "Std. PCA trust" 
label variable std_trust_ctg "Std. Trust (categorical var.)" 
label variable std_trust_strangers "Std. trust people" 
label variable std_rely_someone "Std. rely on someone" 
label variable std_trust_people "Std. trust strangers" 

label variable female "Female" 
label variable age "Age"
label variable east "East" 
label variable height "Height (cm)"
label variable rural "Rural area" 
label variable migration_back "Migration background" 
label variable low_perform "Low-performing student" 
label variable highest_edu_hh "High parental ducation" 
label variable religion_hh "Christian parents" 
label variable father_blue_collar "Working-class father"
label variable work_mother "Working mother"
label variable single_parent "Single parent"
label variable migback_classmate "Classmates with migration background"
label variable state "State of residence"
label variable year_hgsch_entry "Year of high school entry"

keep cid hid pid syear state year_hgsch_entry _m3 _m2 _m1 init _p1 _p2 _p3 _p4 pca_trust std_pca_trust ///
std_trust_ctg std_trust_strangers std_rely_someone std_trust_people female age east ///
height rural migration_back low_perform highest_edu_hh ///
religion_hh father_blue_collar work_mother single_parent migback_classmate  

save "$output_data\built_youth_data_event_study.dta", replace

*******************************************************************************
* 3. Clean and built variables for placebo estimation
*******************************************************************************

* 3.1 Clean dataset
*******************************************************************************

clear all
use "$input_data/merge_original_youth_data.dta", clear

/* Since 2006 SOEP has provided self-ratings of trust for 17 year-old 
adolescents. We will keep the surveys until 2018. From 2019 on we see some states going back to the G9 structure.*/
keep if inrange(syear,2006,2018)

/* We exclude data sampled as part of the newest inmigration samples since recent inmigrants and refugees are sampled in these data.*/
tab psample
//keep if (psample>=1 & psample<=11) | (psample>=20 & psample<=23) 
keep if !inrange(psample,15,19)

/* We keep all adolescents who are 17 years old at the time of the survey*/
gen age =  syear - jl0233
tab age
keep if age == 17

/* We select all adolescents who are in secondary general school (Hauptschule) and intermediate school (Realschule) at the time of the survey*/
gen no_gymnasium = .
replace no_gymnasium = 1 if inlist(jl0125_v3,1,2) | (jl0125_v3 == 6 & inlist(jl0127_h,2,3)) // "jl0125_v3: Do you still attend school?"
replace no_gymnasium = 0 if inlist(jl0125_v3,3,4,5) | (jl0125_v3 == 6 & inlist(jl0127_h,1,4,5)) // "jl0127_h: What was you type of graduation certificate?"
/* An alternative definition would include to those who are currently attending a vocational school but completed their secondary education in non-academic track high schools
gen no_gymnasium = .
replace no_gymnasium = 1 if inlist(jl0125_v3,1,2) | (inlist(jl0125_v3,5,6) & inlist(jl0127_h,2,3)) // "jl0125_v3: Do you still attend school?"
replace no_gymnasium = 0 if inlist(jl0125_v3,3,4) | (inlist(jl0125_v3,5,6) & inlist(jl0127_h,1,4)) // "jl0127_h: What was you type of graduation certificate?" */
tab no_gymnasium
keep if no_gymnasium == 1

/* We exclude individuals who repeated one or more grades or did not answer this question */
keep if jl0164==2

* To identify whether a student is affected by the reform, we use the information on the federal state of residence and the year of school entry.
/* We use the federal state of residence at the time of the survey when the individual was 17 y.o.*/
rename bula_h state /*"bula_h: state of residence at the time of the survey"*/
/* There is an alternative way to define the state of residence using the variable "bex4fst: last observed year in school, Fed. State" */
*gen state = .
*replace state = bex4fst if (bex4fst!=-2 & bex4fst!=.)
*replace state = bula_h if state==.

/* We use a variable that indicates the year of high school entry. 
In case of missings, the the year of high-school entry is imputed from the date of birth. */
/* We exclude students for which we don't have enought information regarding their year of high school entry:*/
gen year_hgsch_entry = .
replace year_hgsch_entry = bet3year if (bet3year!=-2 & bet3year!=.) /*"bet3year: transition to sec. school, year"*/
replace year_hgsch_entry = gebjahr + 10 if !inlist(state,11,12,13) & year_hgsch_entry==. /*gebjahr: Year of Birth*/
replace year_hgsch_entry = gebjahr + 12 if inlist(state,11,12,13) & year_hgsch_entry==. 
/*In Berlin, Brandenburg and Mecklenburg-West Pomerania academic, high school only starts from grade 7 on." 
/* There is an alternative and more restrictive way to fill the missings depending on the year and month of birth,
however the birthday cut off for entry to primary school varies by state and to the best of our knowledge it does not seem compulsory */
*replace year_hgsch_entry = gebjahr + 10 if inrange(gebmonat,1,6) & !inlist(state,11,12,13) & year_hgsch_entry==.
*replace year_hgsch_entry = gebjahr + 12 if inrange(gebmonat,1,6) & inlist(state,11,12,13) & year_hgsch_entry==.
*replace year_hgsch_entry = gebjahr + 11 if inrange(gebmonat,7,12) & !inlist(state,11,12,13) & year_hgsch_entry==.
*replace year_hgsch_entry = gebjahr + 13 if inrange(gebmonat,7,12) & inlist(state,11,12,13) & year_hgsch_entry==.*/
tab year_hgsch_entry, missing
/* We exclude students for which we don't have enought information regarding their year of high school entry:*/
keep if year_hgsch_entry != .

/* We exclude students from Hesse who entered high school in 2004 or 2005 when schools operated under both schemes (G8 and G9)*/
drop if (state == 6 & (inlist(year_hgsch_entry,2004,2005)))

/*We exclude students from Rhineland-Palatinate where the reform has not been implemented state-wide*/
keep if state != 7 

/* Defining treatment and control groups */
gen treated = .
replace treated = 1 if state==14 | state==16 | /// Saxony and Thuringia
		(state==1 & (year_hgsch_entry >= 2008))  | /// Schleswig-Holstein 
		(state==2 & (year_hgsch_entry >= 2002)) | /// Hamburg
		(state==3 & (year_hgsch_entry >= 2003)) | /// Niedersachsen and Lower Saxony
		(state==4 & (year_hgsch_entry >= 2004)) | /// Bremen
		(state==5 & (year_hgsch_entry >= 2005)) | /// Nordrhein-Westfalen * 
		(state==6 & (year_hgsch_entry >= 2006)) | /// Hesse
		(state==8 & (year_hgsch_entry >= 2004)) | /// Baden-Wuerttemberg
		(state==9 & (year_hgsch_entry >= 2003)) | /// Bayern or Bavaria
		(state==10 & (year_hgsch_entry >= 2001)) | /// Saarland 
		(state==11 & (year_hgsch_entry >= 2006)) | /// Berlin
		(state==12 & (year_hgsch_entry >= 2006)) | /// Brandenburg
		(state==13 & (year_hgsch_entry >= 2002)) | /// Mecklenburg-Vorpommern
		(state==15 & (year_hgsch_entry >= 1999)) // Sachsen-Anhalt or Saxony Anhalt
replace treated = 0 if treated == .

tab treated

/* We exclude any possibility of someone being interviewed twice*/
bysort pid (syear): keep if _n == 1

tempfile clean_youth_data_placebo
save `clean_youth_data_placebo', replace

* 3.2 Build variables
*******************************************************************************

use `clean_youth_data_placebo', clear

/****************************** Dependent variables ****************************/

* Variable trust

rename (jl0361 jl0362 jl0363)(trust_people rely_noone distrust_strangers)
replace trust_people = . if trust_people < 0
replace rely_noone = . if rely_noone < 0
replace distrust_strangers = . if distrust_strangers < 0
/*We reverse the scale for "nagetive" items*/
gen trust_strangers = 8-distrust_strangers if distrust_strangers!=. 
gen rely_someone = 8-rely_noone if rely_noone!=.    

/* We use the principal component analysis to combine the information from the three separate measures of trust into
a scalar measure*/
global trust_var trust_people rely_someone trust_strangers
describe $trust_var
summarize $trust_var
corr $trust_var
// Principal component analysis 
pca $trust_var
pca $trust_var, mineigen(1)
// Scores of the components
predict pca_trust, score
sum pca_trust, detail
// The Kaiser–Meyer–Olkin (KMO) measure of sampling adecuacy: 
// The statistic is a measure of the proportion of variance among variables that might be common variance. 
// The higher the proportion, the higher the KMO-value
estat kmo
egen std_pca_trust = std(pca_trust)

/*Alternatively, we generate the trust measure by adding up scores*/
gen trust_ctg = trust_people + rely_someone + trust_strangers
/*Standarizing trust measure*/ 
egen std_trust_ctg = std(trust_ctg)

/*Additionally, we standardize each of the three separate measures of trust*/
egen std_trust_strangers = std(trust_strangers)
egen std_rely_someone = std(rely_someone)
egen std_trust_people = std(trust_people)

/**************************** Independent variables ***************************/

* Variable state 
tab state, missing

* Variable age
tab age, missing

* Variable sex 
recode sex (1=0) (2=1), gen(female)
tab female, missing

* Variable rural area
gen rural = (jl0272==4)
replace rural = . if inrange(jl0272,-5,-1) | jl0272==.
tab rural, missing
	  
* Variable East-Germany
gen east = inrange(state,11,16)
tab east, missing

* Variable migration background 
gen migration_back = inlist(migback,2,3) 
tab migration_back, missing

* Variable low-performing student
gen low_perform = (jl0151!=3)
replace low_perform = . if jl0151==-1
tab low_perform, missing

* Variable highest level of education of parents 
recode fsedu (-5/-1 = .) (0/3 = 0) (5/9 = 0) (4=1), gen(father_educ1)
recode msedu (-5/-1 = .) (0/3 = 0) (5/9 = 0) (4=1), gen(mother_educ1)
recode fprofedu (-5/-1 = .) (0/29 = 0) (40/51 = 0) (30/32=1), gen(father_educ2)
recode mprofedu (-5/-1 = .) (0/29 = 0) (40/51 = 0) (30/32=1), gen(mother_educ2)

gen highest_edu_hh = .
replace highest_edu_hh = 1 if father_educ1==1 | mother_educ1==1 | father_educ2==1 | mother_educ2==1
replace highest_edu_hh = 0 if father_educ1==0 & mother_educ1==0 & father_educ2==0 & mother_educ2==0 
tab highest_edu_hh, missing

* Variable religion: Christian parents
recode freli (-5/-1 = .) (1 2 = 1) (3/7 = 0), gen(father_religion)
recode mreli (-5/-1 = .) (1 2 = 1) (3/7 = 0), gen(mother_religion)

gen religion_hh = .
replace religion_hh = 1 if father_religion==1 | mother_religion==1 
replace religion_hh = 0 if father_religion==0 & mother_religion==0 
tab religion_hh, missing

* Variable Working-class father
/* Dummy for father having blue-collar occupation when student is aged 15, 
reference category encompasses all others*/
gen father_blue_collar = inrange(fegp88,8,11)
replace father_blue_collar = . if inlist(fegp88,-2,-1) 
tab father_blue_collar, missing

* Variable working mother
/*Dummy for working mother (both full-time and part-time)
when student is aged 15*/
gen work_mother = !inrange(mprofstat,10,15)
replace work_mother = . if mprofstat==. | inrange(mprofstat,-5,-1)
tab work_mother, missing

* Variable single parent
/*Dummy for not having lived with both parents for the entire
time up to age 15*/
gen single_parent = inrange(living1,0,14) 
replace single_parent = . if living1==. | inrange(living1,-5,-1)
tab single_parent, missing

* Variable migration background of classmates in school
/*Dummy for having classmates with a migration background: 
If you think back to the last grade of school you attended: How many of your 
fellow students or their parents were not from Germany?*/
gen migback_classmate = inrange(jl0176_h,1,5) 
replace migback_classmate = . if jl0176_h==. | inrange(jl0176_h,-5,-1)
tab migback_classmate, missing
	  
* Variable height
rename jl0219 height
recode height (-5/-1 = .)

* 3.3. Label variables
*******************************************************************************

label variable treated "G8 reform"
label variable pca_trust "PCA Trust" 
label variable std_pca_trust "Std. PCA trust" 
label variable std_trust_ctg "Std. Trust (categorical var.)" 
label variable std_trust_strangers "Std. trust people" 
label variable std_rely_someone "Std. rely on someone" 
label variable std_trust_people "Std. trust strangers" 

label variable female "Female" 
label variable age "Age"
label variable east "East" 
label variable height "Height (cm)"
label variable rural "Rural area" 
label variable migration_back "Migration background" 
label variable low_perform "Low-performing student" 
label variable highest_edu_hh "High parental ducation" 
label variable religion_hh "Christian parents" 
label variable father_blue_collar "Working-class father"
label variable work_mother "Working mother"
label variable single_parent "Single parent"
label variable migback_classmate "Classmates with migration background"
label variable state "State of residence"
label variable year_hgsch_entry "Year of high school entry"

keep cid hid pid syear state year_hgsch_entry treated pca_trust std_pca_trust std_trust_ctg std_trust_strangers std_rely_someone ///
std_trust_people female age east height rural migration_back low_perform highest_edu_hh ///
religion_hh father_blue_collar work_mother single_parent migback_classmate   

save "$output_data\built_youth_data_placebo.dta", replace
