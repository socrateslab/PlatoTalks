**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** TableA6. Canal closure and rebellions: agricultural productivity
**************************************************************************
gen ashdensity=asinh(canal_den)
global canal ashdensity
gen triplerice=${canal}*reform*suitable_rice_good
gen triplewheat=${canal}*reform*suitable_wheat_good
gen canal_after=${canal}*reform
label variable triplerice "Canal $ \times $ Rice suitability $ \times $ Post"
label variable triplewheat "Canal $ \times $ Wheat suitability $ \times $ Post"
label variable rice_after "Rice suitability $ \times $ Post"
label variable wheat_after "Wheat suitability $ \times $ Post"
label variable canal_after "Canal $ \times $ Post"
global X_rice canal_after rice_after triplerice
global X_wheat canal_after wheat_after triplewheat

reghdfe mp canal_after, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri1
su mp if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:agri1
estadd scalar N_g=groups:agri1

preserve
hdfe mp canal_after, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC mp canal_after, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: agri1 
restore

reghdfe $Y $X_rice, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri2
su $Y if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:agri2
estadd scalar N_g=groups:agri2

preserve
hdfe $Y $X_rice, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X_rice, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: agri2 
restore

reghdfe $Y $X_wheat, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo agri3
su $Y if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:agri3
estadd scalar N_g=groups:agri3

preserve
hdfe $Y $X_wheat, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y $X_wheat, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: agri3
restore

*** Get indicators of FEs
estfe agri1 agri2 agri3


**************************************************************************
*** Set up table elements for Latex
**************************************************************************
*** Title
global caption "Canal closure and rebellions: agricultural productivity"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption }  \begin{threeparttable}
	\begin{tabular}{l*{3}{c}}
	\toprule\toprule
	&\multicolumn{3}{c}{\textit{Dependent Variable:}} \\ 
	[.1cm] \cmidrule(lr){2-4} 
	& Grain Price & \multicolumn{2}{c}{Rebellions} \\ 
	[.1cm] \cmidrule(lr){2-2} \cmidrule(lr){3-4}
	;
#delimit cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_gp "The dependent variable for the first column is grain price. "
global note_rebel "The dependent variable for the second and third columns is the inverse hyperbolic sine transformation of the number of rebellions normalize by 1600 population. "
global note_rice "$ Rice\ suitability $ is an indicator that equals one if the county is suitable for wetland rice plantation. "
global note_wheat "$ Wheat\ suitability $ is an indicator that equals one if the county if suitable for wheat plantation. "
global note_canal "$ Canal $ is the inverse hyperbolic sine transformation of canal length per 100 $ km^2 $. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_sample $note_dep $note_canal $note_post $note_std $note_conley }\end{tablenotes}"

**************************************************************************
*** Export Table to Latex
**************************************************************************
esttab agri1 agri2 agri3 ///
	   using "Results/Tables/tableA6.tex", booktabs nonotes compress label nomtitles ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) drop(_cons))) ///
							       collabels("",none) ///
                                   stats(depavg N N_g r2_a,fmt(4 %7.0fc 0 4) labels("Mean of the Dependent Variable" "No. of Observations" "No. of Counties" "Adjusted R-squared")) ///
								   indicate("County FE =0.OBJECTID" "Year FE=0.year" ) ///
    							   prehead($head ) ///
                                   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{table}) ///
                                   $stars ///
                                   replace