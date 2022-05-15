**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"
graph set window fontface "Cambria"
set scheme s2color


**************************************************************************
*** FigureA4. Canal closure and rebellions: flexible distance to the canal
**************************************************************************
gen band=ceil(ctadmin_canal/25)*25
replace band=425 if band>=425 & band!=.
tab band, gen(dist)
reghdfe $Y c.reform#(c.dist1-dist16), absorb(i.OBJECTID i.year c.ashprerebels#i.year i.provid#i.year) cluster(OBJECTID)
matrix coef = e(b) 
matrix cov = e(V) 
gen coef = .
gen se = .
forvalues i = 1(1)16 {
 replace coef = coef[1,`i'] if _n==`i'
 replace se = sqrt(cov[`i',`i']) if _n==`i'
}
gen lb=coef-invttail(e(df_r),0.025)*se 
gen ub=coef+invttail(e(df_r),0.025)*se 
keep coef se lb ub
drop if coef == .
gen distance_canal=_n
#d ;
twoway 
(line lb distance_canal, lpattern(dash) lcolor("0 0 0"))
(line ub distance_canal, lpattern(dash) lcolor("0 0 0"))
(scatter coef distance_canal, color(gs0) msize(*0.75))
(line coef distance_canal, lpattern(solid) lcolor("4 4 4"))
,
ytitle("Coefficients", size(*0.9)) 
xtitle("Distance to the canal (km)", size(*0.9) margin(medsmall))
yline(-0.05(0.025)0.15, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1(0.5)16, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
yline(0, lpattern(dash) lcolor("128 0 0"))
ylabel(-0.05(0.05)0.15, angle(0) format(%5.2f) labsize(*0.85))
xlabel(1 "25" 2 "50" 3 "75" 4 "100" 5 "125" 6 "150" 7 "175" 8 "200" 9 "225" 10 "250" 11 "275" 12 "300" 13 "325" 14 "350" 15 "375" 16 "400", labsize(*0.85)) 
graphregion(fcolor(gs16) lcolor(gs16)) 
plotregion(lcolor("white") lwidth(*0.9))
legend(off)
;
#d cr
graph export "Results/Figures/figureA4.pdf", replace


**************************************************************************
*** Write to Latex
**************************************************************************
file open f using "Results/Figures/figureA4.tex", write replace
file write f "\begin{figure}[p]\captionsetup{justification=centering,singlelinecheck=false,width=0.8\textwidth}" _n
file write f "\begin{center}" _n
file write f "\caption{Canal closure and rebellions: flexible distance to the canal}  " _n
file write f "\includegraphics[width=.8\textwidth]{Figures/figureA4.pdf} \\ " _n
file write f "\end{center}" _n
file write f "\footnotesize{\textit{Note.} The figure depicts the changes in rebellions before and after the 1826 reform by a county's distance to the canal. "
file write f "The solid line represents the point estimates, and the dashed lines represent the 95\% confidence intervals based on standard errors clustered at the county level. "
file write f "The dependent variable is the inverse hyperbolic sine of the number of rebellions normalized by 1600 population. "
file write f "The independent variables are the distance from the county's geological center to the canal. "
file write f "The regression considers county fixed effects, year fixed effects, pre-treatment rebelliousness $ \times $ year fixed effects, and province $ \times $ year fixed effects . }"
file write f "\end{figure}" _n
file close f