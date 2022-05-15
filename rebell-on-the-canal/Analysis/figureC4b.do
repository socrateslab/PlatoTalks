**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"
graph set window fontface "Cambria"
set scheme s2color


**************************************************************************
*** FigureC4b. Chronological distribution of droughts and floodings
**************************************************************************
preserve
collapse (sum) flooding drought, by(year)
label variable flooding "Flooding"
label variable drought "Drought"
gen fd=flooding+drought
label variable fd "Drought"
#d ;
twoway 
(bar fd year, barw(0.85) base(0) color("89 89 89"))
(bar flooding year, barw(0.85) base(0) color("190 190 190"))
,
ytitle("") 
xtitle("")
yline(0(50)100, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1650(25)1910, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1826, lwidth(*1.25) lpattern(dash) lcolor("128 0 0"))
ylabel(0(100)400, angle(0) format(%12.0f) labsize(*0.85))	
xlabel(, labsize(*0.85)) 
graphregion(fcolor(gs16) lcolor(gs16)) 
plotregion(lcolor("white") lwidth(*0.9))   
;
#d cr
graph export "Results/Figures/figureC4b.pdf", replace
restore


**************************************************************************
*** Write to Latex
**************************************************************************
file open f using "Results/Figures/figureC4b.tex", write replace
file write f "\begin{figure}[p]\captionsetup{justification=centering,singlelinecheck=false,width=0.8\textwidth}" _n
file write f "\begin{center}" _n
file write f "\caption{Chronological distribution of new world crops adoption} " _n
file write f "\includegraphics[width=.8\textwidth]{Figures/figureC4b.pdf} \\ " _n
file write f "\end{center}" _n
file write f "\footnotesize{\textit{Note.} This figure depicts the spatial and chronological distribution of droughts and floodings documented in history. Panel (a) shows the total number of drought and flooding records in each county throughout the sample period. Panel (b) shows the total number of each event by year. } "
file write f " "
file write f " "
file write f "\end{figure}" _n
file close f