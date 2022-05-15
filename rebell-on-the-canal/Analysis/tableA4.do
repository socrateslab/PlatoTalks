**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** TableA4. Canal closure and rebellions: state capacity channel
**************************************************************************
gen ashdensity=asinh(canal_den)
global canal ashdensity
gen ashattack_cntypop1600=asinh(attack/(cntypop1600/1000000))
gen ashretreat_cntypop1600=asinh(runinto/(cntypop1600/1000000))
gen canal_after=${canal}*reform
label variable canal_after "Canal $ \times $ Post"
gen triplesoldier=${canal}*asinh(soldier/100)*reform
gen soldier_after=asinh(soldier/100)*reform
label variable soldier_after "Soldiers $\times$ Post"
label variable triplesoldier "Soldiers $\times$ Canal $\times$ Post"
gen triplecapital=${canal}*pref_capital*reform
gen capital_after=pref_capital*reform
label variable capital_after "Prefecture Capital $\times$ Post"
label variable triplecapital "Prefecture Capital $\times$ Canal $\times$ Post"

reghdfe $Y canal_after soldier_after triplesoldier, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul1
su onset_all if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:vul1
estadd scalar N_g=groups:vul1

preserve
hdfe $Y canal_after soldier_after triplesoldier, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y canal_after soldier_after triplesoldier, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: vul1
restore

preserve
reghdfe $Y canal_after capital_after triplecapital, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)   
eststo vul2
su onset_all if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:vul2
estadd scalar N_g=groups:vul2
restore

preserve
hdfe $Y canal_after capital_after triplecapital, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC $Y canal_after capital_after triplecapital, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: vul2
restore

reghdfe ashattack_cntypop1600 canal_after, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul3
su attack if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:vul3
estadd scalar N_g=groups:vul3

preserve
hdfe ashattack_cntypop1600 canal_after, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC ashattack_cntypop1600 canal_after, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: vul3
restore

reghdfe ashretreat_cntypop1600 canal_after, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
eststo vul4
su runinto if e(sample)
scalar y2mean=r(mean)
qui tab OBJECTID if e(sample)
scalar groups=r(r)
estadd scalar depavg=y2mean:vul4
estadd scalar N_g=groups:vul4

preserve
hdfe ashretreat_cntypop1600 canal_after, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
ols_spatial_HAC ashretreat_cntypop1600 canal_after, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
matrix V_spat=vecdiag(e(V)) 
matmap V_spat SE_spat, m(sqrt(@)) 
estadd matrix sesp=SE_spat: vul4
restore

*** Get indicators of FEs
estfe vul1 vul2 vul3 vul4


**************************************************************************
*** Set up table elements for Latex
**************************************************************************
*** Title
global caption "Canal closure and rebellions: state capacity channel"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption }  \begin{threeparttable}
	\begin{tabular}{l*{4}{c}} 
	\toprule\toprule 
	&\multicolumn{4}{c}{\textit{Dependent Variable:}} \\ 
	[.1cm] \cmidrule(lr){2-5} 
	&\multicolumn{2}{c}{Rebellions} & Attacking & Retreating  \\ 
	[.1cm] \cmidrule(lr){2-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5}
	;
#delimit cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_rebel "The dependent variable for the first two columns, $ Rebellions $ , is the inverse hyperbolic sine transformation of the number of rebellions normalized by 1600 population. "
global note_attack "The dependent variable for the third column, $ Attacking $ , is the number of documented events in which an existing rebel group attacked the county; we normalized the value by 1600 population and applied the inverse hyperbolic sine transformation to it. "
global note_retreat "The dependent variable for the fourth column, $ Retreating $ , is the number of documented events in which an existing rebel group retreated into the county; we normalized the value by 1600 population and applied the inverse hyperbolic sine transformation to it. "
global note_canal "$ Canal $ is the inverse hyperbolic sine transformation of canal length per 100 $ km^2 $. "
global note_soldier "$ Soldiers $ is the size of military establishment pre-assigned during the 1750s. "
global note_capital "$ Prefecture\ Capital $ is an indicator that equals one if the county served as the administrative center of the prefecture it belonged to. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_sample $note_rebel $note_attack $note_retreat $note_canal $note_soldier $note_capital $note_post $note_std $note_conley }\end{tablenotes}"

**************************************************************************
*** Export Table to Latex
**************************************************************************
esttab vul1 vul2 vul3 vul4 ///
	   using "Results/Tables/tableA4.tex", booktabs nonotes compress label nomtitles ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) drop(_cons))) ///
							       collabels("",none) ///
                                   stats(depavg N N_g r2_a,fmt(4 %7.0fc 0 4) labels("Mean of the Dependent Variable" "No. of Observations" "No. of Counties" "Adjusted R-squared")) ///
								   indicate("County FE =0.OBJECTID" "Year FE=0.year" "Pre-reform rebellion $\times$ Year FE=0.year#c.ashprerebels" "Province $\times$ Year FE=0.provid#0.year") ///
    							   prehead($head ) ///
                                   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{table}) ///
                                   $stars ///
                                   replace