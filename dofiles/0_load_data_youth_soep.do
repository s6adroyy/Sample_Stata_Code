*******************************************************************************
*******************************************************************************
*********** LOAD ORIGINAL DATASETS
*********** *******************************************************************************
*******************************************************************************

clear all

global input_data "C:\input_data"
global output_data "C:\original_data"

global original_data "Z:/data_wave37"
use cid hid pid syear sex gebjahr gebmonat migback psample using "$original_data/ppathl.dta", clear // We can get the variables year of born, sex and type of sample in the ppathl dataset
tempfile ppathl
save `ppathl', replace

use cid hid syear bula* wein_v3 using "$original_data/hbrutto.dta", clear // We can get the variable state of residence in the hbrutto dataset
tempfile hbrutto
save `hbrutto', replace

use "$original_data/bioedu.dta", clear // We can get the variable of age when entering high-school in bioedu dataset
tempfile bioedu
save `bioedu', replace

use "$original_data/bioparen.dta", clear // We can get the variable of level of education and employment status of parents in bioparen dataset
tempfile bioparen
save `bioparen', replace

use "$original_data/jugendl.dta", clear  
bysort pid (syear): keep if _n == 1
merge 1:1 cid pid syear using `ppathl', gen(_merge1)
tab _merge1
keep if _merge1 == 1 | _merge1 == 3
merge m:1 cid hid syear using `hbrutto', gen(_merge2) 
tab _merge2
keep if _merge2 == 1 | _merge2 == 3
merge m:1 cid pid using `bioedu', gen(_merge3) 
tab _merge3
keep if _merge3 == 1 | _merge3 == 3
merge m:1 cid pid using `bioparen', gen(_merge4) 
tab _merge4
drop _merge*

gen bulah = bula_h 

drop if syear ==. 
drop if (fsedu == . & msedu == . & fprofedu == . & mprofedu == . & freli == . & mreli == . & fegp88 == . & living1 == .)

keep pid hid syear cid psample jl0125_v3 jl0127_h jl0164 bula_h bet3year gebjahr jl0233 jl0361 jl0362 jl0363 sex jl0272 migback jl0151 fsedu msedu fprofedu mprofedu freli mreli fegp88 ///
mprofstat living1 ///
jl0176_h jl0219 jl0218 jl0074 jl0105_h jl0058 jl0059_h jl0061 jl0062 jl0063 jl0064 jl0065 jl0066 jl0067 jl0068 jl0069 jl0070 jl0071 jl0073 ///
jl0388 jl0072 jl0139 jl0140 jl0141 jl0142 jl0143 jl0144 jl0145 jl0146 jl0392 jl0367 jl0371 jl0376 jl0379 


save "$input_data/merge_original_youth_data.dta", replace 
