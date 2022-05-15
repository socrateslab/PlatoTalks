**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** TableA7. Canal closure and the Green Gang
**************************************************************************
collapse (mean) green_senior alongcanal prefid provid, by(OBJECTID)
global canal alongcanal
*** Main estimates
xi:reg green_senior $canal i.prefid, robust
eststo pst1
su green_senior if e(sample)
scalar ymean=r(mean)
estadd scalar depavg=ymean:pst1


*************************************************************************
*** Set up table elements for Latex
*************************************************************************
*** Title
global caption "Canal closure and the Green Gang"

*** Table head
#d ;
global tbhead { 
      \begin{table}[htb]\centering
      \caption{$caption } \begin{threeparttable}
	  \begin{tabular}{l*{1}{c}} 
	  \toprule\toprule 
	  &\multicolumn{1}{c}{\textit{Dependent Variables: }} \\ 
	  [.1cm] \cmidrule(lr){2-2} 
	  & Green Gang senior members \\
	  & (early $20^{th}$ century)  \\ 
	  [.1cm] \cmidrule(lr){2-2} 
;
#d cr
*** Table notes
run "Program/Analysis/generalnotes.do"
global note_sample "The sample consists of 575 counties in the six provinces around the canal. "
global note_dep "The dependent variable is the number of Green Gang senior members in the early 20th century. "
global note_std "Standard errors in parentheses are robust for heteroskedasticity. "
global notes "\begin{tablenotes}\footnotesize{\item \textit{Note.} $note_sample $note_dep $note_along $note_std }\end{tablenotes}" 

************************************************************************
*** Export Table to Latex
************************************************************************
esttab pst1 ///
	   using "Results/Tables/tableA7.tex", booktabs nonotes compress label nomtitles ///
								   prehead($tbhead) ///
                                   cells(b(fmt(4)) se(fmt(4) par(( )))) ///
							       collabels("",none) ///
								   stats(depavg N r2_a,fmt(4 0 4) labels("Mean of the Dependent Variable" "No. of Observations" "Adjusted R-squared")) ///
								   drop(_cons) ///
								   indicate("Prefecture FE =_Iprefid*") ///
								   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{table}) ///
								   replace