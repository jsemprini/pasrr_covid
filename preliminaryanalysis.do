
clear all 

use "C:\Users\jsemprini\Documents\federalism\2.0analysis\1.prelim-pasrr.dta" 

xtset fips day

gen testpasrr=waiver1*sus_pasrr
gen testanymedicaid=anymedicaid*waiver1
gen testanyfh=anyfh*waiver1 
gen testanyprov=anyprov*waiver1

****model 1***
xtreg deaths_pc testpasrr cases_pc popstate pctpopover65, vce(cluster fips) fe
xtreg deaths_pc waiver1##sus_pasrr cases_pc popstate pctpopover65, vce(cluster fips)

***model 2***


xtreg deaths_pc testpasrr c.testpasrr#c.(testanymedicaid testanyfh testanyprov) cases_pc popstate pctpopover65, vce(cluster fips) fe

test c.testpasrr#c.testanymedicaid + testpasrr = 0

gen testpassr_anymed=testpasrr*testanymedicaid
gen testpasrr_anyfh=testpasrr*testanyfh
gen testpasrr_anyprov=testpasrr*testanyprov
gen onlypasrr=0
replace onlypasrr=1 if testpasrr==1 & anyfh==0 & anymed==0

xtreg deaths_pc onlypasrr testpasrr_anyfh testpassr_anymed cases_pc popstate pctpopover65 nhbeds_p65, vce(cluster fips)

***model 3***
replace defsp_nf=0 if state=="TX"
gen nhbeds_2p65=nhbeds_p65/100000
gen defsp_res=anydefs/avgres_day
gen defsp_2res=defsp_res*100000
gen avgscreen=pasrr_total/avgres_day
gen fp_beds=ncertbeds*propr_fp
gen inhosp_beds=prop_inhosp*ncertbeds
gen res_bed=avgres_day/ncertbeds
gen over65=popstate*(pctpopover65/100)
replace over65=over65/100000
gen n_fp=(ninhosp/prop_inhosp)*propr_fp

replace npasrrdefs=0 if state=="TX"

gen ndefs_pbed=npasrrdefs/ncertbeds
replace ndefs_pbed=ndefs_pbed*100

xtreg deaths_pc c.testpasrr#c.(res_bed nhbeds_2p65 fp_beds inhosp_beds avgscreen ndefs_pbed) cases_pc popstate pctpopover65, vce(cluster fips) fe



****PLACEBO****
gen placebo=0
replace placebo=1 if sus_pasrr==1 
xtreg deaths_pc placebo , vce(cluster fips) 

xtreg deaths_pc c.placebo#c.(res_bed nhbeds_2p65 fp_beds inhosp_beds avgscreen ndefs_pbed) cases_pc popstate pctpopover65, vce(cluster fips) 

