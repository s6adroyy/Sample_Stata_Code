********************************************************************************
*********** MASTER DOFILE 
**********
********************************************************************************

* Outline
*** 0. 	Load datasets
*** 1. Clean general dataset
*** 2. Data analysis: regressions
*** 3. Final outputs

clear all
set more off
set maxvar 7000, permanently
version 16.0

* Setting directories
* Change these directories to your local directories
global main_path "F:/MASTER_BONN/THIRD SEMESTER/RM-Applied Micro/Replication_files_RM_paper_adrija_lucia_oliver"
global original_data "A:/data_wave37"

global do_files "${main_path}/dofiles"
global input_data "${main_path}/dataset/input"
global output_data "${main_path}/dataset/output"
global tables "${main_path}/tables"
global figures "${main_path}/figures"

* Setting up execution 

global load_data   	      0
global cleaning    	      1
global descriptive_stats  1
global main_reg			  1
global heterogenous_reg	  1
global mechanisms_reg	  1
global robustness_checks  1
global final_outputs 	  1

********************************************************************************
*** 0. 	Load datasets
********************************************************************************

	if (${load_data} == 1) {
		do "${do_files}/0_load_data_youth_soep.do"
	} 

********************************************************************************
*** 1. 	Clean dataset
********************************************************************************

	if (${cleaning} == 1) {
		do "${do_files}/1_clean_youth_soep.do"
	} 

********************************************************************************
*** 2.  Data analysis: regressions
********************************************************************************

***	Descriptive statistics
	if (${descriptive_stats} == 1) {
		do "${do_files}/2_descriptive_stats_youth_soep.do"
	} 

***	Main regressions
	if (${main_reg} == 1) {
		do "${do_files}/3_main_regressions_youth_soep.do"
	} 

***	Heterogeneous regressions
	if (${heterogenous_reg} == 1) {
		do "${do_files}/4_heterogeneous_regressions_youth_soep.do"
	} 

***	Regressions for mechanisms
	if (${mechanisms_reg} == 1) {
		do "${do_files}/5_mechanisms_youth_soep.do"
	}

***	Robustness check
	if (${robustness_checks} == 1) {
		do "${do_files}/6_robustness_check_youth_soep.do"
	}

********************************************************************************
*** 3. 	Final outputs
********************************************************************************

***	Final tables and figures
	if (${final_outputs} == 1) {
		do "${do_files}/7_final_tables_figure_soep.do"
	}
