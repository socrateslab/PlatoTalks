**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** TableA3. Canal closure and rebellions: alternative transformations of outcome values
**************************************************************************
gen onset_cntypop1600=onset_all/(cntypop1600/1000000)
gen ashonset_num=asinh(onset_all)
global Ys ashonset_cntypop1820 ashonset_cntypop ashonset_km2 ashonset_num onset_cntypop1600

foreach Y of varlist $Ys {
    *** Main estimates
    reghdfe `Y' $X, absorb(i.OBJECTID i.year) cluster(OBJECTID)
    eststo `Y'_1
    qui tab OBJECTID if e(sample)
    scalar groups=r(r)
    qui su $Y if e(sample)
    scalar ymean=r(mean)
    estadd scalar depavg=ymean:`Y'_1
    estadd scalar N_g=groups:`Y'_1

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year) cluster(OBJECTID)
    eststo `Y'_2
    qui tab OBJECTID if e(sample)
    scalar groups=r(r)
    qui su $Y if e(sample)
    scalar ymean=r(mean)
    estadd scalar depavg=ymean:`Y'_2
    estadd scalar N_g=groups:`Y'_2

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
    eststo `Y'_3
    qui tab OBJECTID if e(sample)
    scalar groups=r(r)
    qui su $Y if e(sample)
    scalar ymean=r(mean)
    estadd scalar depavg=ymean:`Y'_3
    estadd scalar N_g=groups:`Y'_3

    reghdfe `Y' $X, absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
    eststo `Y'_4
    qui tab OBJECTID if e(sample)
    scalar groups=r(r)
    qui su $Y if e(sample)
    scalar ymean=r(mean)
    estadd scalar depavg=ymean:`Y'_4
    estadd scalar N_g=groups:`Y'_4

    *** Get indicators of FEs
    estfe `Y'_1 `Y'_2 `Y'_3 `Y'_4

    *** Get conley standard errors
    preserve
    hdfe `Y' $X, clear absorb(i.OBJECTID i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat=vecdiag(e(V))
    matmap V_spat SE_spat, m(sqrt(@)) 
    estadd matrix sesp=SE_spat: `Y'_1 
    restore
    preserve
    hdfe `Y' $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat=vecdiag(e(V))  
    matmap V_spat SE_spat, m(sqrt(@)) 
    estadd matrix sesp=SE_spat: `Y'_2
    restore
    preserve
    hdfe `Y' $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat=vecdiag(e(V)) 
    matmap V_spat SE_spat, m(sqrt(@)) 
    estadd matrix sesp=SE_spat: `Y'_3
    restore
    preserve
    hdfe `Y' $X, clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
    ols_spatial_HAC `Y' $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
    matrix V_spat=vecdiag(e(V)) 
    matmap V_spat SE_spat, m(sqrt(@)) 
    estadd matrix sesp=SE_spat: `Y'_4
    restore
}


*************************************************************************
*** Set up table elements for Latex
*************************************************************************

*** Title
global caption "Canal closure and rebellions: alternative transformations of outcome values"

*** Table head
#delimit ;
global prehead1
	\begin{table}[!htbp] \centering \footnotesize \setlength{\tabcolsep}{2pt}
    \caption{$caption }
	\begin{threeparttable}
	\begin{tabular}{l*{4}{c}}
    \toprule\toprule
    & \multicolumn{4}{c}{\textit{Dependent Variable: Rebellions}} \\
    [.1cm] \cmidrule(lr){2-5}
    & (1) & (2) & (3) & (4) \\
	;
#delimit cr	
global posthead1 \midrule & \multicolumn{4}{c}{\textbf{A: by 1820 population}} \\ 
global prefoot1 " "
global postfoot1 \midrule
global prehead2 " " 
global posthead2 & \multicolumn{4}{c}{\textbf{B: by yearly population}} \\ 
global prefoot2 " "
global postfoot2 \midrule 
global prehead3 " "
global posthead3 & \multicolumn{4}{c}{\textbf{C: by land area}} \\ 
global prefoot3 " "
global postfoot3 \midrule 
global prehead4 " "
global posthead4 & \multicolumn{4}{c}{\textbf{D: without normalization}} \\ 
global prefoot4 " "
global postfoot4 \midrule 
global prehead5 " "
global posthead5 & \multicolumn{4}{c}{\textbf{E: without arcsinh transformation}} \\ 
global prefoot5 "\midrule"

global stat5 stat(N N_g,fmt(0 0) labels("Observations" "Counties"))
global ind5 indicate("County FE =0.OBJECTID" "Year FE=0.year" "Pre-reform rebellion $\times$ Year FE=0.year#c.ashprerebels" "Province $\times$ Year FE=0.provid#0.year"  "Prefecture Year Trend=0.prefid#c.year")     							   

global mode1 replace
global mode2 append
global mode3 append
global mode4 append
global mode5 append    							   							   
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_overall "The table presents estimates of the effect of the canal's closure using alternative approaches to constructing the outcome variable. "
global note_dep "The depend variable is the number of rebellions with each of the following transformations. "
global note_panels "The outcome variable in Panel A is normalized by county population imputed for 1820. The one in Panel B is normalized by county population imputed for each year (by assuming linear changes in years without data). The one in Panel C is normalized by the size of the county. The one in Panel D is the count of rebellions without normalization. We apply the inverse hyperbolic sine transformation (arcsinh) to all outcome variables in Panel A--D. The outcome variable in Panel E is normalized by 1600 population as in the baseline, but without the arcsinh transformation. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_overall $note_sample $note_dep $note_panels $note_along $note_post $note_std $note_conley }\end{tablenotes}"


#delimit ;
global postfoot5 
	   \bottomrule\end{tabular}$notes\end{threeparttable}\end{table} 
	   ;
#delimit cr	
************************************************************************
*** Export Table to Latex
************************************************************************
local r=0
foreach Y of varlist $Ys {
	local r=`r'+1
    esttab  `Y'_1 `Y'_2 `Y'_3 `Y'_4 ///
	   using "Results/Tables/tableA3.tex", booktabs nonotes compress label nomtitles nocon nodepvars nonumbers noobs ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) )) ///
							       collabels("",none) ///
								   keep(interaction1) ///
                                   ${stat`r'} ${ind`r'} ///
								   prehead(${prehead`r'}) ///
								   posthead(${posthead`r'}) ///
								   prefoot(${prefoot`r'}) ///
                                   postfoot(${postfoot`r'}) ///
                                   $stars ///
                                   ${mode`r'}
}