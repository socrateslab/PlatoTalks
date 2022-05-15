**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** Table6. Canal closure and rebellions: placebo treatments
**************************************************************************
gen oldhuang_after=along_oldhuang*reform
gen coast_after=alongcoast*reform
gen courier_after=alongcourier*reform
egen plcb=rowmax(alongyangtze along_oldhuang alongcoast alongcourier)
gen plcb_after=plcb*reform
label variable yangtze_after "Along Yangtze $ \times $ Post"
label variable oldhuang_after "Along Huang $ \times $ Post"
label variable coast_after "Along Coast $ \times $ Post"
label variable courier_after "Along Courier $ \times $ Post"
label variable plcb_after "Along $ \times $ Post"
global Xp1 yangtze_after
global Xp2 oldhuang_after
global Xp3 coast_after
global Xp4 courier_after
global Xp_any plcb_after

*** Main estimates
reghdfe $Y $Xp1, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est1
estadd scalar N_g=groups:est1

reghdfe $Y $Xp2, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est2
estadd scalar N_g=groups:est2

reghdfe $Y $Xp3, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est3
estadd scalar N_g=groups:est3

reghdfe $Y $Xp4, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est4
estadd scalar N_g=groups:est4

reghdfe $Y $Xp_any, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est5
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est5
estadd scalar N_g=groups:est5

*** Get indicators of FEs
estfe est1 est2 est3 est4 est5

*** Get Conley standard errors
preserve
hdfe $Y $Xp1, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp1, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est1 
restore
preserve
hdfe $Y $Xp2, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp2 , lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est2
restore
preserve
hdfe $Y $Xp3, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp3, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est3 
restore
preserve
hdfe $Y $Xp4, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp4, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est4
restore
preserve
hdfe $Y $Xp_any, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $Xp_any, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est5 
restore


**************************************************************************
*** Set up table elements for Latex
**************************************************************************

*** Title
global caption "Canal closure and rebellions: placebo treatments"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption } \begin{adjustbox}{max width=\textwidth} \begin{threeparttable}
	\begin{tabular}{l*{5}{c}}
	\toprule\toprule
	&\multicolumn{5}{c}{Dependent Variable: Rebellions } \\
	[.1cm]\cmidrule(lr){2-6}
    \textit{Placebo treatment:} & (A) & (B) & (C) & (D) & (E) \\ 
    [.1cm]\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}
	;
#delimit cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_along "$ Along $ is an indicator that equals one if the county is adjacent to the specific transportion arterial specified at the top of each column: (A) Yangtze River, (B) Yellow River, (C) Coast, (D) Courier routes, and (E) Any of the four. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_sample $note_dep $note_along $note_post $note_std $note_conley }\end{tablenotes}"

**************************************************************************
*** Export Table to Latex
**************************************************************************
esttab est1 est2 est3 est4 est5 ///
	   using "Results/Tables/table6.tex", booktabs nonotes compress label nomtitles ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) drop(_cons))) ///
							       collabels("",none) ///
                                   rename(yangtze_after plcb_after oldhuang_after plcb_after coast_after plcb_after courier_after plcb_after) ///
                                   stats(depavg N N_g r2_a,fmt(4 %7.0fc 0 4) labels("Mean of the Dependent Variable" "No. of Observations" "No. of Counties" "Adjusted R-squared")) ///
								   indicate("County FE =0.OBJECTID" "Year FE=0.year" "Pre-reform rebellion $\times$ Year FE=0.year#c.ashprerebels" "Province $\times$ Year FE=0.provid#0.year"  "Prefecture Year Trend=0.prefid#c.year") ///
    							   prehead($head ) ///
                                   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{adjustbox}\end{table}) ///
                                   $stars ///
                                   replace