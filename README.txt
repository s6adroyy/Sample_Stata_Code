Hello,

This repo contains a sample of my coding style in Stata. This code has been used for a project in Applied Microeconomics using difference in difference for a German Education policy. Data used from SOEP.

Our research work is fully reproducible. 

- Our data comes from SOEP v.37. Access to the SOEP dataset is restricted. 
- In case you do not have access to the SOEP dataset you can 
skip the execution of the dofile named "0_load_data_youth_soep"
(In fact, the master dofile already skips the execution of this dofile)
- To run all our codes, run the master dofile. You will need to change the first 
two directories specified there to your local directories. 
- To reproduce the tables and figures we include in our research paper, the most 
relevant dofiles are:
1_clean_youth_soep.do
7_final_tables_figure_soep.do


