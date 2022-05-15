**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** TableA2. Abandonment of the Grand Canal and rebellions: alternative sampling methods
**************************************************************************
* Columns: within pref, within 100km, 150km, 200km, full
local col1 prefalong==1
local col2 distance_canal<=100
local col3 distance_canal<=150
local col4 distance_canal<=200
local col5 distance_canal<=.
* Rows: 50-, 100-, 150-, 200-, full year window
local row1 year>1800 & year<=1850
local row2 year>1775 & year<=1875
local row3 year>1750 & year<=1900
local row4 year>1711 & year<=1911
local row5 year<=.

*** County level:
forvalues r=1/5 {
	forvalues c=1/5 {
		di " `col`c'' & `row`r''"
		reghdfe $Y $X if `col`c'' & `row`r'', absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) cluster(OBJECTID)
		est store r`r'c`c'

		*** Conley standard errors
		preserve
		hdfe $Y $X  if `col`c'' & `row`r'', clear absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year) tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
		ols_spatial_HAC $Y $X, lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(500) lagcutoff(262) disp star
		matrix V_spat=vecdiag(e(V)) 
		matmap V_spat SE_spat,m(sqrt(@)) 
		estadd matrix sesp=SE_spat: r`r'c`c' 
		restore 
	}
}

*** Prefecture level:
global Yp ashonset_pop1600
forvalues r=1/5 {
	sort prefid year
	collapse (sum) onset_all AREA (first) provid reform (max) alongcanal interaction1 area_pref popden* cntypop* (mean) Y_COORD X_COORD, by(prefid year)
	gen pop1600=popden1600*AREA/1000000
	gen pop1820=popden1820*AREA/1000000
	gen pop=popden*AREA/1000000
	su AREA area_pref
	gen ashonset_pop1600=asinh(onset_all/pop1600)
	gen ashonset_pop1820=asinh(onset_all/pop1820)
	gen ashonset_pop=asinh(onset_all/pop)
	by prefid: egen prerebels=total((onset_all/(pop1600))*(reform==0))
	gen ashprerebels=asinh(prerebels)
	di "`col6' & `row`r''"
	reghdfe $Yp $X if `row`r'', absorb(i.prefid i.year c.ashprerebels#i.year i.provid##i.year) cluster(prefid)
	est store r`r'c6

	*** Conley standard errors
	preserve
	hdfe $Yp $X  if `row`r'', clear absorb(i.prefid i.year c.ashprerebels#i.year i.provid##i.year) tol(0.001) keepvars(prefid year Y_COORD X_COORD)
	ols_spatial_HAC $Yp $X, lat(Y_COORD) lon(X_COORD) time(year) panel(prefid) distcutoff(500) lagcutoff(262) disp star
	matrix V_spat=vecdiag(e(V)) 
	matmap V_spat SE_spat, m(sqrt(@)) 
	estadd matrix sesp=SE_spat: r`r'c6 
	restore 
}

label variable interaction "Along Canal $ \times $ Post"

estfe r*c*


*************************************************************************
*** Set up table elements for Latex
*************************************************************************

*** Title
global caption "Abandonment of the Grand Canal and rebellions: alternative sampling methods"

*** Table head
#delimit ;
global prehead1
	\begin{table}[!htbp] \centering \footnotesize \setlength{\tabcolsep}{2pt}
    \caption{$caption }
	\begin{threeparttable}
	\begin{tabular}{l*{6}{c}}
    \toprule\toprule
    & \multicolumn{6}{c}{\textit{Dependent Variable: Rebellions}} \\
    [.1cm] \cmidrule(lr){2-7}
    & \multicolumn{5}{c}{County Sample within:} & Prefecture \\
    [.1cm] \cmidrule(lr){2-6}
    & Prefecture & $100km$ & $150km$ & $200km$ & All & Sample \\
    [.1cm] \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6} \cmidrule(lr){7-7}
    & (1) & (2) & (3) & (4) & (5) & (6) \\
	;
#delimit cr	
global posthead1 \midrule & \multicolumn{6}{c}{\textbf{Panel A: 50-year window (1800 -- 1850)}} \\ 
global prefoot1 " "
global postfoot1 \midrule
global prehead2 " " 
global posthead2 & \multicolumn{6}{c}{\textbf{Panel B: 100-year window (1775 -- 1875)}} \\ 
global prefoot2 " "
global postfoot2 \midrule 
global prehead3 " "
global posthead3 & \multicolumn{6}{c}{\textbf{Panel C: 150-year window (1750 -- 1900)}} \\ 
global prefoot3 " "
global postfoot3 \midrule 
global prehead4 " "
global posthead4 & \multicolumn{6}{c}{\textbf{Panel D: 200-year window (1711 -- 1911)}} \\ 
global prefoot4 " "
global postfoot4 \midrule 
global prehead5 " "
global posthead5 & \multicolumn{6}{c}{\textbf{Panel E: all years (1650 -- 1911)}} \\ 
global prefoot5 " "

global mode1 replace
global mode2 append
global mode3 append
global mode4 append
global mode5 append    							   							   
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_overall "The table presents estimates of the effect of the canal's closure using alternative sampling methods. "
global note_panels "Each panel presents estimates using a different selection of time window. "
global note_columns "Each panel presents estimates using a different selection of comparison groups. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_sample $note_dep $note_panels $note_columns $note_along $note_post $note_std $note_conley }\end{tablenotes}"


#delimit ;
global postfoot5 
	   \midrule
	   County FE & Yes & Yes & Yes & Yes & Yes &  \\
       Prefecture FE & & & & & & Yes \\
       Year FE & Yes & Yes & Yes & Yes & Yes & Yes \\
	   Pre-reform rebellion $ \times $ Year FE & Yes & Yes & Yes & Yes & Yes & Yes \\
       Province $\times$ Year FE & Yes & Yes & Yes & Yes & Yes & Yes \\
	   \bottomrule\end{tabular}$notes\end{threeparttable}\end{table} 
	   ;
#delimit cr	
************************************************************************
*** Export Table to Latex
************************************************************************
forvalues r=1/5 {
	esttab  r`r'c1 r`r'c2 r`r'c3 r`r'c4 r`r'c5 r`r'c6 ///
	   using "Results/Tables/tableA2.tex", booktabs nonotes compress label nomtitles nocon nodepvars nonumbers ///
                                   cells(b(fmt(4)) se(fmt(4) par(( ))) sesp(fmt(4) par([ ]) )) ///
							       collabels("",none) ///
								   keep(interaction1) ///
                                   stat(N,fmt(0) labels("Observations")) ///
								   prehead(${prehead`r'}) ///
								   posthead(${posthead`r'}) ///
								   prefoot(${prefoot`r'}) ///
                                   postfoot(${postfoot`r'}) ///
                                   $stars ///
                                   ${mode`r'}
}