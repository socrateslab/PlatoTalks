**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** Table7. Canal closure and rebellions: major distortions
**************************************************************************
*** Panel A: Excluding Affected Counties
gen taipingregion=(Taiping>=2) if Taiping<.
gen triple1 =alongcanal*reform*opiumbattle
gen triple1a=opiumbattle*reform
gen triple2 =alongcanal*reform*taipingregion
gen triple2a=taipingregion*reform
label variable interaction1 "Canal $ \times $ Post"
label variable triple1  "Canal $ \times $ Opium Battlefield $\times$ Post"
label variable triple1a "Opium Battlefield $ \times $ Post"
label variable triple2  "Canal $ \times $ Taiping $\times$ Post"
label variable triple2a "Taiping $ \times $ Post"

preserve
keep if opiumbattle==0
reghdfe $Y $X, absorb(OBJECTID year c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
eststo omtopium1
tab OBJECTID if e(sample)
scalar groups=r(r)
su onset_all if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:omtopium1
estadd scalar N_g=groups:omtopium1
restore

preserve
keep if opiumbattle==0
hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: omtopium1 
restore

preserve
keep if Taiping<2
reghdfe $Y $X, absorb(OBJECTID year c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
eststo omttaiping1
tab OBJECTID if e(sample)
scalar groups=r(r)
su onset_all if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:omttaiping1
estadd scalar N_g=groups:omttaiping1
restore

preserve
keep if Taiping<2 
hdfe $Y $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: omttaiping1 
restore

*** Panel B: Interactions
reghdfe $Y interaction1 triple1a triple1, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
est store opium1
tab OBJECTID if e(sample)
scalar groups=r(r)
su onset_all if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:opium1
estadd scalar N_g=groups:opium1 

reghdfe $Y interaction1 triple2a triple2, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.prefid#c.year i.provid#i.year) cluster(OBJECTID)
est store taiping1
tab OBJECTID if e(sample)
scalar groups=r(r)
su onset_all if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:taiping1
estadd scalar N_g=groups:taiping1

preserve
hdfe $Y interaction1 triple1a triple1, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y interaction1 triple1a triple1, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: opium1 
restore

preserve
hdfe $Y interaction1 triple2a triple2, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y interaction1 triple2a triple2, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: taiping1 
restore


**************************************************************************
*** Set up table elements for Latex
**************************************************************************
*** Get indicators of FEs
estfe omtopium1 omttaiping1 opium1 taiping1

*** Title
global caption "Canal closure and rebellions: major distortions"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption } \begin{adjustbox}{max width=\textwidth}  \begin{threeparttable}
    \begin{tabular}{l*{4}{c}}
	\toprule\toprule 
	&\multicolumn{4}{c}{\textit{Dependent Variable:} Rebellions} \\ 
	&\multicolumn{2}{c}{Panel A} &\multicolumn{2}{c}{Panel B} \\  
	[.1cm] \cmidrule(lr){2-3} \cmidrule(lr){4-5}
	;
#delimit cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_panel "Panel A excludes counties that suffered from battles During the Opium War (column 1) or the Taiping Rebellion (column 2). Panel B examines the heterogeneous effects in those regions."
global note_canal "$ Canal $ is an indicator that equals one if the county is adjacent to the canal. "
global note_opium "$ Opium\ Battlefield $ is an indicator that equals one if the county was one of the battlefields during the First Opium War. "
global note_taiping "$ Taiping $ is an indicator that equals one if the county was one of the battlefields during the Taiping Rebellion. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_panel $note_sample $note_dep $note_canal $note_opium $note_taiping $note_post $note_std $note_conley }\end{tablenotes}"

**************************************************************************
*** Export to Latex
**************************************************************************
esttab omtopium1 omttaiping1 opium1 taiping1 ///
	   using "Results/Tables/table7.tex", booktabs nonotes compress label nomtitles ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) drop(_cons))) ///
							       collabels("",none) ///
                                   stats(depavg N N_g r2_a,fmt(4 %7.0fc 0 4) labels("Mean of the Dependent Variable" "No. of Observations" "No. of Counties" "Adjusted R-squared")) ///
								   indicate("County FE =0.OBJECTID" "Year FE=0.year" "Pre-reform rebellion $\times$ Year FE=0.year#c.ashprerebels" "Province $\times$ Year FE=0.provid#0.year"  "Prefecture Year Trend=0.prefid#c.year") ///
    							   prehead($head ) ///
                                   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{adjustbox}\end{table}) ///
                                   $stars ///
                                   replace