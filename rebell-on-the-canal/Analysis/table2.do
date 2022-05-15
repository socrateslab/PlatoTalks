**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** Table2. Canal closure and rebellions: pre-treatment trends
**************************************************************************
keep if year>=1776 & year<=1825
gen pretrend=alongcanal*year
label variable pretrend "$ Along Canal \times Year $ "
global X pretrend

tab OBJECTID
scalar groups=r(r)
su $Y
scalar ymean=r(mean)

*** Main estimates
reghdfe $Y $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo est1
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est1
estadd scalar N_g=groups:est1

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
eststo est2
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est2
estadd scalar N_g=groups:est2

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo est3
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est3
estadd scalar N_g=groups:est3

reghdfe $Y $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
eststo est4
qui tab OBJECTID if e(sample)
scalar groups=r(r)
qui su $Y if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:est4
estadd scalar N_g=groups:est4

*** Get indicators of FEs
estfe est1 est2 est3 est4

*** Get Conley standard errors
preserve
hdfe $Y $X, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est1 
restore
preserve
hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est2
restore
preserve
hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est3
restore
preserve
hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(50) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: est4
restore


**************************************************************************
*** Set up table elements for Latex
**************************************************************************
*** Title
global caption "Canal closure and rebellions: pre-treatment trends"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption }  \begin{threeparttable}
	\begin{tabular}{l*{4}{c}}
	\toprule\toprule
	&\multicolumn{4}{c}{Dependent Variable: Rebellions } \\
	[.1cm]\cmidrule(lr){2-5}
	;
#delimit cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_sample "The sample consists of 536 counties in the six provinces around the canal from 1776 to 1825."
global note_year "$Year$ is the numerical year number. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.}$note_sample $note_dep $note_along $note_post $note_std $note_conley }\end{tablenotes}"

**************************************************************************
*** Export Table to Latex
**************************************************************************
esttab est1 est2 est3 est4 ///
	   using "Results/Tables/table2.tex", booktabs nonotes compress label nomtitles ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) drop(_cons))) ///
							       collabels("",none) ///
                                   stats(depavg N N_g r2_a,fmt(4 %7.0fc 0 4) labels("Mean of the Dependent Variable" "No. of Observations" "No. of Counties" "Adjusted R-squared")) ///
								   indicate("County FE =0.OBJECTID" "Year FE=0.year" "Pre-reform rebellion $\times$ Year FE=0.year#c.ashprerebels" "Province $\times$ Year FE=0.provid#0.year"  "Prefecture Year Trend=0.prefid#c.year") ///
    							   prehead($head ) ///
                                   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{table}) ///
                                   starlevels(* 0.10 ** 0.05 *** 0.01) ///
                                   replace