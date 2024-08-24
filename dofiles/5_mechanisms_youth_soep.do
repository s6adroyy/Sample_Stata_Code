*******************************************************************************
*******************************************************************************
*********** MECHANISMS: G8 REFORM EFFECTS ON POTENTIAL CHANNELS 
*********** 
*******************************************************************************
*******************************************************************************

********************************************************************************
* REGRESSIONS PLUS EXTENDED CONTROLS
*******************************************************************************

clear all
use "$output_data\built_youth_data.dta", clear

global xvar female migration_back rural highest_edu_hh father_blue_collar ///
work_mother low_perform single_parent i.year_hgsch_entry 

**************************** Health status
areg perceived_health treated $xvar, absorb(state) cluster(state)

**************************** Music active (yes, no)
areg music_active treated $xvar, absorb(state) cluster(state)

**************************** Play music or sing (daily)
areg play_music_sing_day treated $xvar, absorb(state) cluster(state)

**************************** Play music or sing (weakly)
areg play_music_sing_week treated $xvar, absorb(state) cluster(state)

**************************** Sport active (yes, no)
areg sport_active treated $xvar, absorb(state) cluster(state)

**************************** Do sport (daily)
areg do_sports_day treated $xvar, absorb(state) cluster(state)

**************************** Do sport (weakly)
areg do_sports_week treated $xvar, absorb(state) cluster(state)

**************************** Do volunteer work (weakly)
areg volunteer_work_week treated $xvar, absorb(state) cluster(state)

**************************** Do volunteer work (monthly)
areg volunteer_work_month treated $xvar, absorb(state) cluster(state)

**************************** Do nothing in a day
areg do_nothing treated $xvar, absorb(state) cluster(state)

**************************** Have time with friends (daily)
areg time_with_friends treated $xvar, absorb(state) cluster(state)

**************************** Reading (daily)
areg read treated $xvar, absorb(state) cluster(state)

********************************************************************************
* SCHOLASTIC INVOLVEMENT: taking part in group activities inside the high school
*******************************************************************************

**************************** Ever being a class representative
areg class_rprsttv treated $xvar, absorb(state) cluster(state)

**************************** Ever being involved With School Newspaper
areg school_magazine treated $xvar, absorb(state) cluster(state)

**************************** Ever belong to teatre, dance group
areg drama_dance_group treated $xvar, absorb(state) cluster(state)

**************************** Ever belong to choir, orchestra, music group
areg choir_orchestra treated $xvar, absorb(state) cluster(state)

**************************** Ever belong to volunteer sport group
areg sport_group treated $xvar, absorb(state) cluster(state)

**************************** Ever belong to some group
areg some_school_group treated $xvar_extended_control i.year_hgsch_entry, absorb(state) cluster(state)

********************************************************************************
* BIG FIVE AND LOCUS OF CONTROL
*******************************************************************************

**************************** Openness to experience
areg std_bigfive_o treated $xvar, absorb(state) cluster(state)

**************************** Conscientiousness
areg std_bigfive_c treated $xvar, absorb(state) cluster(state)

**************************** Extraversion
areg std_bigfive_e treated $xvar, absorb(state) cluster(state)

**************************** Agreeableness
areg std_bigfive_a treated $xvar, absorb(state) cluster(state)

**************************** Neuroticism
areg std_bigfive_n treated $xvar, absorb(state) cluster(state)

**************************** Locus of control
areg std_iloc treated $xvar, absorb(state) cluster(state)












