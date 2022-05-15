set matsize 11000
xtset OBJECTID year


*************************************************
*** Normalization
*************************************************
*** By land area
gen lonset_km2=ln(1+onset_all/(AREA/10000))
gen ashonset_km2=asinh(onset_all/(AREA/10000))
*** By population
gen popden=popden1600 if year<=1600
replace popden=popden1600+(year-1600)*((popden1776-popden1600)/(1776-1600)) if year>1600 & year<=1776
replace popden=popden1776+(year-1776)*((popden1820-popden1776)/(1820-1776)) if year>1776 & year<=1820
replace popden=popden1820+(year-1820)*((popden1851-popden1820)/(1851-1820)) if year>1820 & year<=1851
replace popden=popden1851+(year-1851)*((popden1880-popden1851)/(1880-1851)) if year>1851 & year<=1880
replace popden=popden1880+(year-1880)*((popden1910-popden1880)/(1910-1880)) if year>1880 & year<=1910
replace popden=popden1910 if year>1910

gen pop=popden*AREA/1000000
gen pop1600=popden1600*AREA/1000000
gen pop1820=popden1820*AREA/1000000

gen lonset_pop=ln(1+onset_all/pop)
gen lonset_pop1600=ln(1+onset_all/pop1600)
gen lonset_pop1820=ln(1+onset_all/pop1820)
gen ashonset_pop=asinh(onset_all/pop)
gen ashonset_pop1600=asinh(onset_all/pop1600)
gen ashonset_pop1820=asinh(onset_all/pop1820)
*** Imputed county level population
gen cntypop=cntypop1600 if year<=1600
replace cntypop=cntypop1600+(year-1600)*((cntypop1776-cntypop1600)/(1776-1600)) if year>1600 & year<=1776
replace cntypop=cntypop1776+(year-1776)*((cntypop1820-cntypop1776)/(1820-1776)) if year>1776 & year<=1820
replace cntypop=cntypop1820+(year-1820)*((cntypop1851-cntypop1820)/(1851-1820)) if year>1820 & year<=1851
replace cntypop=cntypop1851+(year-1851)*((cntypop1880-cntypop1851)/(1880-1851)) if year>1851 & year<=1880
replace cntypop=cntypop1880+(year-1880)*((cntypop1910-cntypop1880)/(1910-1880)) if year>1880 & year<=1910
replace cntypop=cntypop1910 if year>1910
gen ashonset_cntypop=asinh(onset_all/(cntypop/1000000))
gen ashonset_cntypop1600=asinh(onset_all/(cntypop1600/1000000))
gen ashonset_cntypop1820=asinh(onset_all/(cntypop1820/1000000))

gen popdencnty1600=cntypop1600/AREA
gen lpopdencnty1600=ln(popdencnty1600)

**************************************************************************
*** Define the set of controls
**************************************************************************
sort OBJECTID year
by OBJECTID: egen prerebels=total((onset_all/(cntypop/1000000))*(reform==0))
gen ashprerebels=asinh(prerebels)
gen rug_after=ruggedness*reform
gen taiping_after=Taiping*reform
gen huang_after=alonghuang*reform
gen yangtze_after=alongyangtze*reform
egen reconmean=mean(recon)
egen reconsd=sd(recon)
gen disaster=(abs(recon-reconmean)>reconsd)
gen drought=(climate==1)
gen flooding=(climate==5)
gen distyellow_after=distance_huang*reform
gen distcoast_after=distance_coast*100*reform
gen larea_after=ln(AREA)*reform
gen lpop1600_after=ln(cntypop1600)*reform
gen recon_after=recon*reform
gen drought_after=drought*reform
gen flooding_after=flooding*reform
gen disaster_after=disaster*reform
gen maize_after=maize*reform
gen sweetpotato_after=sweetpotato*reform
gen wheat_after=suitable_wheat_good*reform
gen rice_after=suitable_rice_good*reform
gen lwheat_after=ln(si_wheat)*reform
gen lrice_after=ln(si_rice)*reform
gen popdencnty1600_after=popdencnty1600*reform
gen lpopdencnty1600_after=lpopdencnty1600*reform

label variable drought "Drought"
label variable drought_after "Drought $ \times $ Post"
label variable flooding "Flooding"
label variable flooding_after "Flooding $ \times $ Post"
label variable disaster "Temperature Anomaly"
label variable disaster_after "Temperature Anomaly $\times$ Post"
label variable onset_any "Presence"
label variable rug_after "Ruggedness $\times$ Post"
label variable taiping_after "Taiping Region $\times$ Post"
label variable recon "Temperature Deviation"
label variable huang_after "Huang River $\times$ Post"
label variable yangtze_after "Yangtze River $\times$ Post"
label variable distyellow_after "Distance to Yellow River $\times$ Post"
label variable distcoast_after "Distance to the Coast $\times$ Post"
label variable larea_after "ln(land area) $ \times $ Post"
label variable lpop1600_after "ln(initial population in 1600) $ \times $ Post"


*************************************************
*** Add variable labels
*************************************************
label variable interaction1 "Along Canal $ \times $ Post"

*************************************************
*** Globals
*************************************************
macro drop _all
est clear

global Y ashonset_cntypop1600
global X interaction1

gen area_after=AREA*reform

global ctrls larea_after rug_after disaster disaster_after flooding drought flooding_after drought_after lpopdencnty1600_after maize maize_after sweetpotato sweetpotato_after wheat_after rice_after

global stars nostar