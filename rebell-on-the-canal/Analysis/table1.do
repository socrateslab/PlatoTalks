**************************************************************************
*** Set up
**************************************************************************
use "Data/Final/rebellion.dta", clear
run "Program/Analysis/generalsetup.do"


**************************************************************************
*** Table1. Data sources and summary statistics
**************************************************************************
gen town=town1820 if year==1820
replace town=town1911 if year==1911
replace distance_coast=distance_coast*100
gen onset_cntypop1600=onset_all/(cntypop1600/1000000)
gen canaltown=(town1820_r10canal*alongcanal)/town1820

label variable onset_cntypop1600 "Number of rebellions per million population"
label variable onset_all "Number of Rebellions (Onset)"
label variable canal_den "Length of canal per 100 $ km^2 $"
label variable popdencnty1600 "Population density"
label variable distance_huang "Distance from the Yellow River (km)"
label variable distance_coast "Distance from the coast (km)"
label variable AREA "Land size"
label variable soldier "Imperial Soldiers Stationed"
label variable attack "Number of Attacking Cases"
label variable runinto "Number of Retreating Cases"
label variable drought "Drought"
label variable flooding "Flood"
label variable disaster "Temperature Anomaly"
label variable suitable_rice_good "Suitable for wetland rice"
label variable suitable_wheat_good "Suitable for wheat"
label variable town "Number of Towns and Local Markets"
label variable canaltown "Share of towns within 10km of the canal"
label variable mp "Average grain price (silver tael per 10,000 kilocalorie)"

recode alongcanal (1=0) (0=1), gen(sugroup)
local Ylist onset_cntypop1600
local Xlist alongcanal canal_den canaltown distance_canal
local Clist AREA ruggedness disaster flooding drought popdencnty1600 maizeyear swtpotatoyear suitable_rice_good suitable_wheat_good
local Olist soldier pref_capital attack runinto town alongcourier mp green_senior
des `Ylist' `Xlist' `Clist' `Olist'


**************************************************************************
*** Get statistics
**************************************************************************
estpost summarize `Ylist' `Xlist' `Clist' `Olist'
eststo des2

// Sourcelist
preserve
clear
set obs 1
gen onset_cntypop1600=1
gen alongcanal=2
gen canal_den=2
gen canaltown=2
gen distance_canal=2
gen AREA=2
gen ruggedness=5
gen disaster=3
gen drought=4
gen flooding=4
gen popdencnty1600=6
gen maizeyear=4
gen swtpotatoyear=4
gen suitable_wheat_good=8
gen suitable_rice_good=8
gen soldier=7
gen pref_capital=2
gen attack=1
gen runinto=1
gen town=2
gen alongcourier=2
gen mp=4
gen green_senior=9
estpost summarize `Ylist' `Xlist' `Clist' `Olist'
eststo des1
restore


**************************************************************************
*** Set up table elements for latex
**************************************************************************
global caption "Data sources and summary statistics"

*** Table head
#delimit ;
global head
    \begin{table}[htb]\centering
    \caption{$caption } \begin{adjustbox}{max width=\textwidth} \begin{threeparttable}
	\begin{tabular}{l*{4}{c}} 
	\toprule\toprule 
	;
#delimit cr

*** Table notes
run "Program/Analysis/generalnotes.do"
global note_source1 "\item Veritable Records of the Qing Emperors (\textit{Qing Shilu})"
global note_source2 "\item Harvard Yenching Institution and Fudan Center for Historical Geography (2007)"
global note_source3 "\item Mann et al. (2009)"
global note_source4 "\item Chen and Kung (2016)"
global note_source5 "\item Nunn and Puga (2012)"
global note_source6 "\item Liang (1980)"
global note_source7 "\item Luo (1984)"
global note_source8 "\item FAO (2012), GAEZ: http://gaez.fao.org/Main.html\#"
global note_source9 "\item Encyclopedia of the Green Gang (\textit{Qingbang Tongcao Huihai})"
global note_sources $note_source1 $note_source2 $note_source3 $note_source4 $note_source5 $note_source6 $note_source7 $note_source8 $note_source9   
global notes "\begin{tablenotes}\footnotesize{\item \textit{Sources.} \begin{enumerate} $note_sources \end{enumerate} }\end{tablenotes}"

**************************************************************************
*** Export table
**************************************************************************
labvarch `Ylist' `Xlist' `Clist' `Olist', prefix("\ \ \ \ ")
local sequence Outcome `Ylist' Treatments `Xlist' Controls `Clist' Supplements `Olist'
esttab des1 des2 ///
	   using "Results/Tables/table1.tex", booktabs nonotes compress label nomtitles nonumbers noobs ///
								   cells("min(fmt(0) pattern(1 0) label(Source)) count(fmt(%9.0fc) pattern(0 1) label(Obs.)) mean(fmt(%12.4fc) pattern(0 1) label(Mean)) sd(fmt(%12.4fc) pattern(0 1) label(S.D))") ///
								   order(`sequence') ///
								   starlevels(* 0.10 ** 0.05 *** 0.01) ///
								   prehead($head ) ///
								   postfoot(\bottomrule\end{tabular}$notes\end{threeparttable}\end{adjustbox}\end{table} ) ///
								   replace