**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"
graph set window fontface "Cambria"
set scheme s2color


**************************************************************************
*** FigureA1: Number of rebellions onsets overtime
**************************************************************************
collapse (sum) onset_all, by(year)
label variable onset_all "Count of Rebellions"
#d ;
twoway  
(line onset_all year, lwidth(*1.05) lcolor(gray*2.6)) 
(scatter onset_all year, color(gs0) msize(*0.15))
,
ytitle("Count of Rebellions", size(*0.9)) 
xtitle("")
yline(0(10)60, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1650(25)1900, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1826, lpattern(dash) lcolor("128 0 0"))
ylabel(0(20)60, angle(0) format(%12.0f) labsize(*0.85))
xlabel(1650(50)1900, labsize(*0.85)) 
graphregion(fcolor(gs16) lcolor(gs16)) 
plotregion(lcolor("white") lwidth(*0.9))
legend(off) 
;
#d cr
graph export "Results/Figures/figureA1.pdf", replace


**************************************************************************
*** Write to Latex
**************************************************************************
file open f using "Results/Figures/figureA1.tex", write replace
file write f "\begin{figure}[p]\captionsetup{justification=centering,singlelinecheck=false,width=0.8\textwidth}" _n
file write f "\begin{center}" _n
file write f "\caption{Number of rebellion onsets overtime} " _n
file write f "\includegraphics[width=.8\textwidth]{Figures/figureA1.pdf} \\ " _n
file write f "\end{center}" _n
file write f "\footnotesize{\textit{Note.} The figure depicts the yearly number of rebellions recorded in our dataset. The vertical line represents the year in which the closure of the canal started. } "
file write f " "
file write f " "
file write f "\end{figure}" _n
file close f