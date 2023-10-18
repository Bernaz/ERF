* More l
clear all

* working directory
cd "/Users/bernardocantone/Library/CloudStorage/OneDrive-CSIRO/JOBS/DATA"


* read data 
spshape2dta "/Users/can154/Library/CloudStorage/OneDrive-CSIRO/JOBS/DATA/stats.shp"
use stats.dta


spmatrix clear
* Linear regression (prc_y12 perc_ml mean_ag area15 farm_sz)
regress Nproj LcmNprj area15 if year == "2015"
* spatial weighting matrix
spmatrix create contiguity W if year == "2015"
*add another spatial weighting matrix
estat moran, errorlag(W) 


* TABLE 3
eststo clear
spmatrix clear
spmatrix create contiguity W 
eststo: quietly regress Nproj LcmNprj area15
eststo: quietly regress Nproj LcmNprj area15 farm_sz prc_y12 perc_ml mean_ag
eststo: quietly spregress Nproj LcmNprj area15, ml ivarlag(W: LcmNprj) force
eststo: quietly spregress Nproj LcmNprj area15 farm_sz prc_y12 perc_ml mean_ag, ml ivarlag(W: LcmNprj)  force
eststo: quietly spregress Nproj LcmNprj area15 farm_sz prc_y12 perc_ml mean_ag, ml ivarlag(W: LcmNprj) errorlag(W)  force

*pretty tables
esttab ,       ///
      mtitles("OLS" "OLS" "SLX" "SLX" "SDEM")  ///
cells(b(star fmt(3)) se(par fmt(3))) ///
starlevel(* 0.10 ** 0.05 *** 0.010) ///
stats( N  aic) ///
addnote("The table gives parameter estimates including standard error in parentheses ***p < 0.01, **p < 0.05, *p < 0.1") ///
eqlabels(" " " ")


esttab using spatial5.html,       ///
      mtitles("OLS" "OLS" "SLX" "SLX" "SDEM")  ///
cells(b(star fmt(3)) se(par fmt(3))) ///
starlevel(* 0.10 ** 0.05 *** 0.010) ///
stats(N aic) ///
addnote("The table gives parameter estimates including standard error in parentheses ***p < 0.01, **p < 0.05, *p < 0.1") ///
eqlabels(" " " ")


summarize LcmNprj, detail
gen LcmNprjs = LcmNprj / r(sd)

summarize area15, detail
gen area15s = area15 / r(sd)

eststo clear
eststo: quietly regress Nproj LcmNprjs area15s
eststo: quietly regress Nproj LcmNprjs area15s farm_sz prc_y12 perc_ml mean_ag
eststo: quietly spregress Nproj LcmNprjs area15s, gs2sls ivarlag(W: LcmNprj) force
eststo: quietly spregress Nproj LcmNprjs area15s farm_sz prc_y12 mean_ag, gs2sls ivarlag(W: LcmNprj)  force
eststo: quietly spregress Nproj LcmNprjs area15s farm_sz prc_y12 mean_ag, gs2sls ivarlag(W: LcmNprj) errorlag(W) force  



* create a new variable of the spatial lag 	
drop splag1_LcmNprj_b
drop splag1_LcmNprj_s
spgen LcmNprj, lat(_CY) lon(_CX) swm(bin) dist(.) dunit(km)
summarize splag1_LcmNprj_b, detail
gen splag1_LcmNprj_s = splag1_LcmNprj_b / 0.367441


eststo clear
eststo: quietly regress Nproj LcmNprjs area15s
eststo: quietly regress Nproj LcmNprjs area15s farm_sz prc_y12 perc_ml mean_ag
eststo: quietly spregress Nproj LcmNprjs area15s, gs2sls ivarlag(W: splag1_LcmNprj_s) force
eststo: quietly spregress Nproj LcmNprjs area15s farm_sz prc_y12 perc_ml mean_ag, gs2sls ivarlag(W: splag1_LcmNprj_s)  force
eststo: quietly spregress Nproj LcmNprjs area15s farm_sz prc_y12 perc_ml mean_ag, gs2sls ivarlag(W: splag1_LcmNprj_s) errorlag(W) force  





