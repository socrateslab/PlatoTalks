**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** TableA5. Canal closure and rebellions: trade access channel
**************************************************************************
gen ashdensity=asinh(canal_den)
gen ashcourierden=asinh(courier_length/(AREA/10000))
global canal ashdensity
global courier ashcourierden
preserve
duplicates drop OBJECTID, force
drop year
rename town1820_r10canal canalside1820
rename town1911_r10canal canalside1911
rename town1820_r10courier courierside1820
rename town1911_r10courier courierside1911
reshape long town canalside courierside, i(OBJECTID) j(year)
gen canal_after=${canal}*(year==1911)
replace town=ln(town)
label variable town "Town Number (ln)"
label variable canal_after "Canal $\times$ Post"

*** Run the regression
reghdfe town canal_after, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo trade1
su town if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:trade1
estadd scalar N_g=groups:trade1

*** Obtain Conley standard error
hdfe town canal_after, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC town canal_after, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: trade1
restore

********************************************************
*** Heterogeneous effects
********************************************************
gen canal_after=${canal}*reform
label variable canal_after "Canal $ \times $ Post"
gen triplecourier=${canal}*reform*${courier}
gen courier_after=reform*${courier}
label variable triplecourier "Canal $ \times $ Courier $ \times $ Post"
label variable courier_after "Courier $ \times $ Post"
gen tripledisaster=${canal}*reform*disaster
gen disaster_canal=${canal}*disaster
label variable tripledisaster "Canal $ \times $ Temperature Anomaly $ \times $ Post"
label variable disaster_canal "Canal $ \times $ Temperature Anomaly"

*** Run the regressions

*** Substitution
reghdfe $Y canal_after courier_after triplecourier, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo trade2
su $Y if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:trade2
estadd scalar N_g=groups:trade2

preserve
hdfe $Y canal_after courier_after triplecourier, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y canal_after courier_after triplecourier, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: trade2
restore

*** Mitigation
reghdfe $Y canal_after disaster disaster_canal disaster_after tripledisaster, absorb(i.OBJECTID i.year) cluster(OBJECTID)
eststo trade3
su $Y if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:trade3
estadd scalar N_g=groups:trade3

preserve
hdfe $Y canal_after disaster disaster_canal disaster_after tripledisaster, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y canal_after disaster disaster_canal disaster_after tripledisaster, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V))
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: trade3 
restore

*** Get indicators of FEs
estfe trade1 trade2 trade3


*************************************************************************
*** Set up table elements for Latex
*************************************************************************
*** Title
global caption "Canal closure and rebellions: trade access channel"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption }  \begin{threeparttable}
	\begin{tabular}{l*{3}{c}} 
	  \toprule\toprule 
	  &\multicolumn{3}{c}{\textit{Dependent Variable:}} \\ 
	  [.1cm] \cmidrule(lr){2-4} 
	  & Town Number & \multicolumn{2}{c}{Number of Rebellions} \\ 
	  [.1cm] \cmidrule(lr){2-2} \cmidrule(lr){3-4}
	;
#delimit cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_sptown "The sample for the first column consists of 560 counties in the six provinces around the canal, for 1820 and 1911. "
global note_town "The dependent variable for the first column, $ Towns $, is the logarithm of the number of towns within the county. "
global note_sprebel "The sample for the next two columns consists of 536 counties in the six provinces around the canal from 1650 to 1911. "
global note_rebel "The dependent variable for the second and the third column, $ Rebellions $ , is the inverse hyperbolic sine transformation of the number of rebellions normalized by 1600 population. "
global note_canal "$ Canal $ is the inverse hyperbolic sine transformation of canal length per 100 $ km^2 $. "
global note_courier "$ Courier $ is the inverse hyperbolic sine transformation of courier route length per 100 $ km^2 $. "
global note_temp "$ Temperature\ Anomaly $ is an indicator that equals one if the temperature deviated from the mean by more than one standard deviation. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_sample $note_sptown $note_town $note_sprebel $note_rebel $note_canal $note_courier $note_temp $note_post $note_std $note_conley }\end{tablenotes}"

************************************************************************
*** Export Table to Latex
************************************************************************
esttab trade1 trade2 trade3 ///
	   using "Results/Tables/tableA5.tex", booktabs nonotes compress label nomtitles ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) drop(_cons))) ///
							       collabels("",none) ///
                                   stats(depavg N N_g r2_a,fmt(4 %7.0fc 0 4) labels("Mean of the Dependent Variable" "No. of Observations" "No. of Counties" "Adjusted R-squared")) ///
								   indicate("County FE =0.OBJECTID" "Year FE=0.year") ///
    							   prehead($head ) ///
                                   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{table}) ///
                                   $stars ///
                                   replace