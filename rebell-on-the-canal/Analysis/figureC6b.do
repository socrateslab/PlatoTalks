**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"
graph set window fontface "Cambria"
set scheme s2color


**************************************************************************
*** FigureC6b. Chronological distribution of new world crops adoption
**************************************************************************
preserve
sort year
collapse (count) maizeyear swtpotatoyear (sum) maize sweetpotato, by(year) 
gen maizeshare=maize/maizeyear
gen spshare=sweetpotato/swtpotatoyear
label variable maize "Maize"
label variable sweetpotato "Sweet Potato"
#d ;
twoway 
(line maize year, lpattern(solid)  msize(*0.75) color("4 4 4"))
(line sweetpotato year, lpattern(dash) msize(*0.75) color("119 119 119"))
,
ytitle("Number of counties adopted", size(*0.9)) 
xtitle("")
yline(0(100)600, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1650(25)1910, lstyle(grid) lwidth(thin) lcolor("235 235 235"))
xline(1826, lpattern(dash) lcolor("128 0 0"))
ylabel(0(200)600, angle(0) format(%5.0f) labsize(*0.85))
xlabel(, labsize(*0.85)) 
graphregion(fcolor(gs16) lcolor(gs16)) 
plotregion(lcolor("white") lwidth(*0.9))
legend(label(1 "Maize") label(2 "Sweet Potato")) 
;
#d cr
graph export "Results/Figures/figureC6b.pdf", replace
restore


**************************************************************************
*** Write to Latex
**************************************************************************
file open f using "Results/Figures/figureC6b.tex", write replace
file write f "\begin{figure}[p]\captionsetup{justification=centering,singlelinecheck=false,width=0.8\textwidth}" _n
file write f "\begin{center}" _n
file write f "\caption{Chronological distribution of new world crops adoption} " _n
file write f "\includegraphics[width=.8\textwidth]{Figures/figureC6b.pdf} \\ " _n
file write f "\end{center}" _n
file write f "\footnotesize{\textit{Note.} This figure depicts the spatial and chronological distribution of the introduction of new world crops(maize and sweet potato). Panel (a) shows the year in which each crop was first introduced. Panel (b) shows the cumulative number of counties that had adopted each crop every year. } "
file write f " "
file write f " "
file write f "\end{figure}" _n
file close f