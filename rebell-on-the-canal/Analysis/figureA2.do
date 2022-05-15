**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"
graph set window fontface "Cambria"
set scheme s2color
set more off


**************************************************************************
***FigureA2. Test statistics of Table 3 varying standard error adjustments
**************************************************************************
**************************************************************************
*** Run regressions and obtain corrected standard errors
*** Results saved to save time
*** Could uncomment if need rerunning
**************************************************************************
local c=1
forvalues c=1/5 {
    if `c'==1 local fes i.OBJECTID i.year
    if `c'==2 local fes i.OBJECTID i.year c.ashprerebels#i.year
    if `c'==3 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year
    if `c'==4 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year
	if `c'==5 local fes i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year i.prefid#c.year
    local ctrl
    if `c'==5 local ctrl $ctrls 
    mat tests`c'=(0,0,.)
    * Conley standard errors with varying distance and lag cutoffs 
    preserve
        hdfe $Y $X `ctrl', clear absorb(`fes') tol(0.001) keepvars(OBJECTID year Y_COORD X_COORD)
        foreach d of numlist 50 100 200 500 1000 2000 {
            foreach t of numlist 20 100 200 262 {            
                disp "Estimating model `c' with distancecutoff `d' and lagcutoff `t' ..."
                ols_spatial_HAC $Y $X `ctrl', lat(Y_COORD) lon(X_COORD) time(year) panel(OBJECTID) distcutoff(`d') lagcutoff(`t')
                ereturn display
                mat ests=r(table)
                scalar d=`d'
                scalar t=`t'
                mat tests`c'=(tests`c'\d,t,ests[3,1])            
            }
        }
    restore
    * Cluster by county
    reghdfe $Y $X `ctrl', absorb(`fes') cluster(OBJECTID)
    ereturn display
    mat ests=r(table)
    scalar d=-1
    scalar t=-1
    mat tests`c'=(tests`c'\d,t,ests[3,1])
    * Cluster by prefecture
    reghdfe $Y $X `ctrl', absorb(`fes') cluster(prefid)
    ereturn display
    mat ests=r(table)
    scalar d=-2
    scalar t=-2
    mat tests`c'=(tests`c'\d,t,ests[3,1])
    * Save statistics
    preserve
        clear
        svmat tests`c', names(stat)
        rename (stat1 stat2 stat3) (dist lag tvalue)
        save "Data/Interim/errors_tests`c'.dta", replace
    restore
}

**************************************************************************
*** Visualize the test statistics across different parameter choices
**************************************************************************
local c=1
forvalues c=1/5 {
    use "Data/Interim/errors_tests`c'.dta", clear
    drop in 1
    recode dist (-1 -2=1 "NA") (50=2 "50") (100=4 "100") (200=6 "200") (500=8 "500") (1000=10 "1000") (2000=12 "2000"),gen(distcat) label(distcat)
    gen mlabel="cluster(county)" if dist==-1
    replace mlabel="cluster(prefecture)" if dist==-2
    #d ;
	twoway 
	(connected tvalue distcat if dist>0 & lag==20, msymbol(Oh) color(black)) 
	(connected tvalue distcat if dist>0 & lag==100, msymbol(T) color(black)) 
	(connected tvalue distcat if dist>0 & lag==200, msymbol(O) color(black)) 
	(connected tvalue distcat if dist>0 & lag==262, msymbol(X) color(black)) 
	(scatter tvalue distcat if inlist(dist,-1,-2),mlabel(mlabel) mlabcolor(black) msize(*0.5) color(black))
	,
	ytitle("Test t-value", size(*0.9)) 
	xtitle("Distance cutoff (km)", size(*0.9) margin(medsmall))
	yline(1.75(0.25)3.25, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
	xline(1(1)12, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
	yline(1.96, lpattern(dash) lcolor("128 0 0"))
	yline(2.58, lpattern(dash) lcolor("128 0 0"))
	text(1.94 0.6 "**" 2.56 0.55 "***", color("128 0 0"))
	ylabel(1.8 " " 2 "2.0" 2.5 "2.5" 3 "3.0", angle(0) format(%5.1f) labsize(*0.85) notick)
	xlabel(1 2(2)12,valuelabel labsize(*0.85)) 
	graphregion(fcolor(gs16) lcolor(gs16)) 
	plotregion(lcolor("white") lwidth(*0.9))
	legend(order(1 "lagcutoff:20 years" 2 "lagcutoff:100 years" 3 "lagcutoff:200 years" 4 "lagcutoff:all (262) years") row(1) size(*0.45))
	title("", size(small) margin(small))
	;
	#d cr
    graph export "Results/Figures/figureA2_col`c'_t.pdf", replace
}


**************************************************************************
*** Write to Latex
**************************************************************************
local v t
file open f using "Results/Figures/figureA2.tex", write replace
file write f "\begin{figure}[p]\captionsetup{justification=centering,singlelinecheck=false,width=0.8\textwidth}" _n
file write f "\begin{center}" _n
file write f "\caption{Test statistics of Table 3 varying standard error adjustments}" _n
file write f "\subfloat[Column (1)]{ " _n
file write f "\includegraphics[width=.49\textwidth]{Figures/figureA2_col1_`v'.pdf}}\hspace{\fill}%" _n
file write f "\subfloat[Column (2)]{ " _n
file write f "\includegraphics[width=.49\textwidth]{Figures/figureA2_col2_`v'.pdf}}\\" _n
file write f "\subfloat[Column (3)]{ " _n
file write f "\includegraphics[width=.49\textwidth]{Figures/figureA2_col3_`v'.pdf}}\hspace{\fill}%" _n
file write f "\subfloat[Column (4)]{" _n
file write f "\includegraphics[width=.49\textwidth]{Figures/figureA2_col4_`v'.pdf}}\\" _n
file write f "\subfloat[Column (5)]{" _n
file write f "\includegraphics[width=.49\textwidth]{Figures/figureA2_col5_`v'.pdf}}\hspace{\fill}%" _n
file write f "\end{center}" _n
file write f "\footnotesize{\textit{Note.} The figure depicts the test t-values calculated using different methods and parameters for standard errors. }" _n
file write f "The five panels correspond to the five columns in baseline Table3. "
file write f "For each panel, the two isolated dots represent t-values calculated using standard errors clustered at the county level (which is reported in Table3) and the prefecture level, respectively. "
file write f "The connected lines represent the t-values calculated using Conley standard errors with different combinations of distance and time cutoffs. "
file write f "Specifically, the x-axis displays different distance cutoffs (50, 100, 200, 500, 1000, 2000km), whereas the markers' shapes identify different time cutoffs (20, 100, 200, and 262 years). "
file write f "The dashed horizontal lines mark the t-values of conventional levels of significance (* 0.10 ** 0.05 *** 0.01). "
file write f "\end{figure}" _n
file close f