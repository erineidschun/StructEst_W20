clear all
set more off
version 14.0

*1000 files called dgp 1 - 1000 so import. () is step size
forvalues i = 1(1)1{ 
import delimited "Desktop/StructEst_W20/Projects/Data/prod_data_USD/wide_df_new.csv", colrange(1:76) clear /*load simulated data for estimation*/
rename ïdgp199 v1

forvalues t = 1(1)17{
local i_k = `t' 
rename v`i_k' k`t' //rename variable v1, v2, v3... to k1, k2, k3

local i_l = 19 + `t' // rename v11 - v20 to l1 - l10
rename v`i_l' l`t'

local i_m = 38 + `t' //rename v21 - v30 to m1 - m10
rename v`i_m' m`t'

local i_y = 57 + `t'
rename v`i_y' y`t'
}

gen id = _n /*generate firm id*/  //create 1 - n firm identifiers. assuming every obs is unique, create an identifier ( 1 - end )
save "Desktop/StructEst_W20/Projects/Data/prod_data_USD/prod_data_US.dta", replace 
/*start estimation*/


local dlwprogram = "Desktop/StructEst_W20/Projects/stata/acf_mata_original.do" // local means create a group of values. gen is creating a variable within a dataset

do `dlwprogram' //run this. like sourcing code in R

use "Desktop/StructEst_W20/Projects/Data/prod_data_USD/prod_data_US.dta", clear 
reshape long k l m y, i(id) j(t) // data is initially wide (wide vs long) wide is m1: values for m1, but we want to make it vertical
xtset id t


*------FIRST STAGE----------------------------------------------------------*
xi: reg y l m k /*robust to higher order polynomial, this is just an interaction thing (xi), so have reg y on interactions of l, m, k*/  

predict phi // generating predicted yhat
predict epsilon, res // generating residual value/error term

label var phi "phi_it 
//labeling. you still call variable by phi though.
label var epsilon "measurement error first stage 
gen phi_lag=L.phi
gen l_lag=L.l
gen k_lag=L.k

*--------------------------------------------------------------------------------------------------*
sort id t
gen const=1
drop if y==. // remove obs if y is missing
drop if l_lag==.
drop if k==.

*----------------------------------------------------------------------------------------------------

*------PLUG IN TRUE VALUES AS STARTING VALUES--------------------------------------------------------
local starting = 7 //recall ex. when alvin set this to 10
gen initialConst = 0

forvalues s = 7(1)`starting'{ // starts at 7 and goes to 7. if above, was 10, then starts at 7 and goes to 10.
// gen initiall = 0.1*(`s'-1) // initial l = 0.1*(7-1) = 0.6
// gen initialk = 0.1*(11-`s') // initial k = 0.4
gen initiall = .5
gen initialk = .5

dlw /*start search*/ //i think this is using the dlw code source above

putexcel A`s' = mat(beta_dlw) using "Desktop/StructEst_W20/Projects/stata/acf_replicate", sheet("dgp1_`i'") modify /*save results to excel*/
//putexcel cellexplist, where cellexplist can be a matrix, here it is mat(beta_dlw)
// take mat(beta_dlw) and write into excel file using column A row s (which is 7)
//do this in the file acf_replicate on sheet dgp1_`i'`"
drop initiall initialk
}

local i = `i' + 1
}

*step 3: IMPORT RESULTS TO STATA DATA FILE
import excel "Desktop/StructEst_W20/Projects/stata/acf_replicate.xlsx",sheet("dgp1_1") clear

// import excel "F:\Research\RR\acf_replicate.xlsx",sheet("dgp1_1") clear
sort C
keep if _n == 1 // keep if current observation number is 1
save "Desktop/StructEst_W20/Projects/stata/result_acf_replicate.dta", replace

local loop = 2

while `loop' < = 1{
//this seems to just be putting all the values from the acf_replicate.xlsx file in cols
import excel "Desktop/StructEst_W20/Projects/stata/acf_replicate.xlsx",sheet("dgp1_`loop'") clear //imports 3 values in columns A, B, C
sort C //is this sorting C column?
keep if _n == 1
save "Desktop/StructEst_W20/Projects/stata/result_temp.dta", replace //isn't this jst replacing the result_temp.dta?

append using "Desktop/StructEst_W20/Projects/stata/result_acf_replicate.dta" //appending?

save "Desktop/StructEst_W20/Projects/stata/result_acf_replicate.dta", replace 

local loop = `loop' + 1
}

// /*OLS PART*/
// use "Desktop/IO_Pset_2/dgp1_simulation.dta", clear 
// reshape long k l m y, i(id) j(t) // data is initially wide (wide vs long) wide is m1: values for m1, but we want to make it vertical
// xtset id t

// xi: reg y l m k /*robust to higher order polynomial, this is just an interaction thing (xi), so have reg y on interactions of l, m, k*/  



















