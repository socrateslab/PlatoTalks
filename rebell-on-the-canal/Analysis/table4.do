**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** Table4. Canal closure and rebellions: treatment intensities
**************************************************************************
gen ash_den=asinh(canal_den)
gen ash_dist=asinh(ctadmin_canal)
gen ash_den_after=ash_den*reform
gen ash_dist_after=ash_dist*reform
gen canaltown_after=(town1820_r10canal*alongcanal)/town1820*reform
label variable ash_den_after "Canal length (per 100 $ km^2 $) $ \times $ Post"
label variable ash_dist_after "Distance to canal $ \times $ Post"
label variable canaltown "Canal town share"
label variable canaltown_after "Canal town share $ \times $ Post"
global X1 ash_den_after
global X2 canaltown_after
global X3 ash_dist_after

reghdfe $Y $X1, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
estimates store int1
qui tab OBJECTID if e(sample)
scalar groups=r(r)
su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:int1
estadd scalar N_g=groups:int1


reghdfe $Y $X2, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
estimates store int2
qui tab OBJECTID if e(sample)
scalar groups=r(r)
su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:int2
estadd scalar N_g=groups:int2


reghdfe $Y $X3, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
estimates store int3
qui tab OBJECTID if e(sample)
scalar groups=r(r)
su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:int3
estadd scalar N_g=groups:int3

*** Get indicators of FEs
estfe int1 int2 int3

*** Get Conley standard errors
preserve
hdfe $Y $X1, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X1, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: int1
restore
preserve
hdfe $Y $X2, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X2, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: int2
restore
preserve
hdfe $Y $X3, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X3, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: int3
restore

**************************************************************************
*** Set up table elements for Latex
**************************************************************************

*** Title
global caption "Canal closure and rebellions: treatment intensities"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption }  \begin{threeparttable}
	\begin{tabular}{l*{3}{c}} 
	\toprule\toprule 
	& \multicolumn{3}{c}{\textit{Dependent variable:} Rebellions} \\ 
	[.1cm] \cmidrule(lr){2-4}
	;
#delimit cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_length "$ Canal\ Length $ (per 100 $ km^2 $) is the length of the canal portion (in $ km $) contained with the county's boundary, divided by the size of the county (in 100 $ km^2 $). "
global note_townshare "$ Canal\ Town\ Share $ is the share of towns within 10 kilometers away from the canal, measured in 1820. "
global note_dist "$ Distance\ to\ canal $ is the distance from a county's geological center to the canal."
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_sample $note_dep $note_length $note_townshare $note_dist $note_post $note_std $note_conley }\end{tablenotes}"

**************************************************************************
*** Export Table to Latex
************************************************************************
esttab int1 int2 int3 ///
	   using "Results/Tables/table4.tex", booktabs nonotes compress label nomtitles ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) drop(_cons))) ///
							       collabels("",none) ///
                                   stats(depavg N N_g r2_a,fmt(4 %7.0fc 0 4) labels("Mean of the Dependent Variable" "No. of Observations" "No. of Counties" "Adjusted R-squared")) ///
								   indicate("County FE =0.OBJECTID" "Year FE=0.year" "Pre-reform rebellion $\times$ Year FE=0.year#c.ashprerebels" "Province $\times$ Year FE=0.provid#0.year"  "Prefecture Year Trend=0.prefid#c.year") ///
    							   prehead($head ) ///
                                   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{table}) ///
                                   starlevels(* 0.10 ** 0.05 *** 0.01) ///
                                   replace