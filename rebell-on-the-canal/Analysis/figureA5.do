**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"
graph set window fontface "Cambria"
set scheme s2color


**************************************************************************
*** FigureA5. Changes-in-changes estimations
**************************************************************************
gen G0T0=(alongcanal==0 & reform==0)
gen G1T0=(alongcanal==1 & reform==0)
gen G0T1=(alongcanal==0 & reform==1)
gen G1T1=(alongcanal==1 & reform==1)
qui reg $Y G0T0 G1T0 G0T1 G1T1 c.ashprerebels#i.year i.OBJECTID i.year i.provid#i.year i.prefid#c.year, nocons
predict res, residual
mat coef=e(b)
gen Yhat=res+coef[1,1]*G0T0+coef[1,2]*G1T0+coef[1,3]*G0T1+coef[1,4]*G1T1
su Yhat,detail

cic Yhat, group(alongcanal) time(reform) reps(100)
matrix qte=e(qte)
clear
svmat qte, names(qte)
rename (qte1 qte2 qte3 qte4 qte5) (qntl qte std lb ub)
#d ;
twoway 
(line lb qntl, lpattern(dash) lcolor("0 0 0"))
(line ub qntl, lpattern(dash) lcolor("0 0 0"))
(scatter qte qntl, color(gs0) msize(*0.75))
(line qte qntl, lpattern(solid) lcolor("4 4 4"))
,
ytitle("Treatment effects", size(*0.9)) 
xtitle("Quantiles", size(*0.9) margin(medsmall))
yline(0(0.025)0.15, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(0(0.1)1, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
ylabel(0(0.05)0.15, angle(0) format(%5.2f) labsize(*0.85))
xlabel(, format(%5.1f) labsize(*0.85)) 
graphregion(fcolor(gs16) lcolor(gs16)) 
plotregion(lcolor("white") lwidth(*0.9))
legend(off)
;
#d cr
graph export "Results/Figures/figureA5.pdf", replace


**************************************************************************
*** Write to Latex
**************************************************************************
file open f using "Results/Figures/figureA5.tex", write replace
file write f "\begin{figure}[p]\captionsetup{justification=centering,singlelinecheck=false,width=0.8\textwidth}" _n
file write f "\begin{center}" _n
file write f "\caption{Changes-in-changes estimations}" _n
file write f "\includegraphics[width=.9\textwidth]{Figures/figureA5.pdf}\hspace{\fill}%" _n
file write f "\end{center}" _n
file write f "\footnotesize{\textit{Note.} The figure depicts the quantile treatment effects on the distribution estimated using the changes-in-changes method.  }" _n
file write f "The solid line represents the point estimates, whereas the dashed lines represent the bootstrapped 95\% confidence intervals. "
file write f "The estimation partials out county fixed effects, year fixed effects, pre-treatment rebelliousness $ \times $ year fixed effects, province $ \times $ year fixed effects, and prefecture-specific time trends. "
file write f "\end{figure}" _n
file close f