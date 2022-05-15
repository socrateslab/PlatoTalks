**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"
graph set window fontface "Cambria"
set scheme s2color


**************************************************************************
*** Figure2. Canal usage measured by tribute rice Transportation
**************************************************************************
duplicates drop year, force
keep if year>1755 & year<1860

#d ;
twoway 
(lfit lamount year if year<=1825, lpattern(dash) lcolor("0 0 0"))
(lfit lamount year if year>=1826, lpattern(dash) lcolor("0 0 0"))
(scatter lamount year, color("190 190 190") msize(*0.75))
,
ytitle("Shipping volume (log million piculs)", size(*0.9)) 
xtitle("")
yline(0.8(0.1)1.8, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1760(10)1860, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1825.3, lpattern(dash) lcolor("128 0 0"))
ylabel(0.8(0.2)1.8, angle(0) format(%5.1f) labsize(*0.85))
xlabel(, labsize(*0.85)) 
graphregion(fcolor(gs16) lcolor(gs16)) 
plotregion(lcolor("white") lwidth(*0.9))
legend(off)
;
#d cr
graph export "Results/Figures/figure2.pdf", replace


**************************************************************************
*** Write to Latex
**************************************************************************
file open f using "Results/Figures/figure2.tex", write replace
file write f "\begin{figure}[p]\captionsetup{justification=centering,singlelinecheck=false,width=0.8\textwidth}" _n
file write f "\begin{center}" _n
file write f "\caption{Canal usage measured by tribute rice transportation} " _n
file write f "\includegraphics[width=.8\textwidth]{Figures/figure2.pdf} \\ " _n
file write f "\end{center}" _n
file write f "\footnotesize{\textit{Note.} The figure depicts the amount of tribute grains transported via the canal between 1755 and 1860. } "
file write f "The vertical solid line marks the 1826 treatment date. "
file write f "The fitted lines depict the linear trend of grain shipping before and after the treatment date. "
file write f "\end{figure}" _n
file close f