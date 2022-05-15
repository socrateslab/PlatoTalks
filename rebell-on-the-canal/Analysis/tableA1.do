**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** TableA1. Comparisons between canal and non-canal counties
**************************************************************************
gen larea=ln(AREA)
gen lrug=ln(ruggedness)
gen lpop=ln(popdencnty1600)
gen lwheat=ln(si_wheat)
gen lrice=ln(si_rice)
global balancevars larea ruggedness disaster flooding drought lpop maize sweetpotato suitable_wheat_good suitable_rice_good
collapse (mean) alongcanal $balancevars, by(OBJECTID)
label variable larea "Land area"
label variable ruggedness "Ruggedness Index"
label variable disaster "Temperature Anomaly"
label variable flooding "Frequency of flooding"
label variable drought "Frequency of droughts"
label variable lpop "Population density in 1600"
label variable maize "Maize introduction"
label variable sweetpotato "Sweet potato introduction"
label variable suitable_wheat_good "Suitable for wheat"
label variable suitable_rice_good "Suitable for wetland rice"

**************************************************************************
*** Get statistics
**************************************************************************
recode alongcanal (1=0) (0=1), gen(sugroup)
keep if lpop<.
*** Canal counties:
estpost summarize $balancevars if sugroup==0
eststo des1
*** Non-canal counties:
estpost summarize $balancevars if sugroup==1
eststo des2
*** Difference:
estpost ttest $balancevars, by(sugroup)
eststo des3


**************************************************************************
*** Set up table elements for Latex
**************************************************************************
*** Title
global caption "Comparisons between canal and non-canal counties"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption } \begin{threeparttable}
	\begin{tabular}{l*{3}{c}}
	\toprule\toprule
	& \multicolumn{1}{c}{Canal counties} & \multicolumn{1}{c}{Non-canal counties} & Difference \\
	[.1cm]\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}
	& (1) & (2) & (1)-(2) \\
	;
#delimit cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_std "Standard deviations in parenthesis."
global note_se "Standard errors in brackets."
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_std $note_se }\end{tablenotes}"

**************************************************************************
*** Export Table to Latex
**************************************************************************
esttab des1 des2 des3  ///
	   using "Results/Tables/tableA1.tex", booktabs nonotes compress label nomtitles nonumbers ///
                                   cells("mean(fmt(a2) pattern(1 1 0)) b(fmt(a2) pattern(0 0 1))" "sd(fmt(a2) pattern(1 1 0) par(( ))) se(fmt(a2) pattern(0 0 1) par([ ]))") ///
								   collabels("",none) ///
    							   prehead($head ) ///
                                   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{table}) ///
                                   $stars ///
                                   replace