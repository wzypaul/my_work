Appendix (Stata code)
************************************************
*** Advanced Econometrics Assignment Stata Code ***
************************************************

*******************
Part A
*******************

clear all
cd ""

***Step 1: Install relevent packages***
ssc install xttest3
ssc install xtcsd

***Step 2: Prepare data***
use crime

***Step 3: Set county as cross-section variable and year as time variable***
tsset county year

***Step 4: Keep only the variables needed***
keep county year lcrmrte lprbarr lprbconv lprbpris lpolpc lpctmin d8*

***Step 5: Data Cleaning***
summarize
/* We find that there are unreasonable values. */

***Step 5.1: Set the maximum value a variable can get***
scalar Maximum=0
/* Log of a probability can not exceed 0. */

***Step 5.2: Change the extreme values to the maximum value***
replace lprbarr = Maximum if lprbarr >Maximum
replace lprbconv = Maximum if lprbconv >Maximum

***Step 6: Conduct pooled OLS and save the result***
reg lcrmrte lprbarr lprbconv lprbpris lpolpc lpctmin d82 d83 d84 d85 d86 d87, robust
est store lcrmrte POLS

***Step 7: Conduct FD and save the result***
reg D.lcrmrte D.lprbarr D.lprbconv D.lprbpris D.lpolpc D.lpctmin D.d83 D.d84 D.d85 D.d86 D.d87,
robust
est store lcrmrte FD

***Step 8: Conduct FE and save the result***
xtreg lcrmrte lprbarr lprbconv lprbpris lpolpc lpctmin d82 d83 d84 d85 d86 d87, fe
est store lcrmrte FE

***Step 9: Heteroskadasticity test***
xttest3
/* There is heteroskadasticity.*/

***Step 10: Conduct RE and save the result***
xtreg lcrmrte lprbarr lprbconv lprbpris lpolpc lpctmin d82 d83 d84 d85 d86 d87, re
est store lcrmrte RE

***Step 11: Cross-section correlation test***
qui xtreg lcrmrte lprbarr lprbconv lprbpris lpolpc lpctmin d82 d83 d84 d85 d86 d87, re
xtcsd,fre
/* There is cross-section correlation. */

***Step 12: Autocorrelation test (should use ”search xtserial” to install xtserial)***
tab county,gen(county)
xtserial lcrmrte lprbarr lprbconv lprbpris lpolpc lpctmin county2-county90 d82 d83 d84 d85 d86 d87
/* There is autocorrelation. */

***Step 13: Compare the results***
estimates table lcrmrte*, b(%9.3f) star(.01 .05 .10) stats(N r2) drop(d82 d83 D1.d83 d84 D1.d84 d85
D1.d85 d86 D1.d86 d87 D1.d87)

***Step 14: Conduct Hausman test***
hausman lcrmrte FE lcrmrte RE, sigmamore
/* There is significant difference between RE and FE */


*******************
Part B
*******************

clear all
cd ""

***Step 1: Install relevent packages***
ssc install wbopendata
ssc install sxpose

***Step 2: Get and preprocessing data***

***Step 2.1: Get data for the UK***
wbopendata, language(en - English) country(GBR;) topics() indicator()

***Step 2.2: Keep only the data we want***
keep if indicatorname == "GDP (constant 2015 US$)" | indicatorname == "Unemployment, total (% of total labor force) (national estimate)"

***Step 2.3: Drop irrelavent information***
drop countrycode countryname region regionname adminregion adminregionname incomelevel
incomelevelname lendingtype lendingtypename indicatorname indicatorcode

***Step 2.4: Transpose the data***
sxpose, clear force

***Step 2.5: Rename the variables***
rename ( var1 var2)(unempl rte temp GDP)

***Step 2.6: Change the data from string type to float***
destring unempl rte temp GDP, replace

***Step 2.7: Delete rows with null***
drop if unempl rte temp==. | GDP == .

***Step 2.8: Add time variable***
gen year = n+1970

***Step 2.9: Change the unit of unemployment rate from % to unity***
gen unempl rte = unempl rte temp/100

***Step 2.10: Drop original unemployment rate data***
drop unempl rte temp

***Step 2.11: Change GDP to ln form***
gen ln GDP = ln(GDP)

***Step 2.12: Take first difference of ln(GDP) so that we get the GDP growth rate***
gen c ln GDP = ln GDP - ln GDP[ n-1]

***Step 3: Set year as time variable***
tsset year

***Step 4: Perform stationarity test***
dfuller unempl rte
/* unempl rte is not stationary. */
dfuller d.unempl rte
/* d.unempl rte is stationary. */
dfuller c ln GDP
/* c ln GDP is stationary. */

***Step 5: Determine the optimal lag***
varsoc unempl rte c ln GDP, maxlag(3)

***Step 6: Perform Johansen cointegration test***
vecrank unempl rte c ln GDP, lag(2)
/* The result indicates two cointegration relationship. */

***Step 7: VAR model***

***Step 7.1: Run the unrestricted VAR model***
var unempl rte c ln GDP, lags(1/2)

***Step 7.2: Run the Granger Test***
vargranger
/* The two variables affects each other. */

***Step 7.3: Run the autocorrelation test***
varlmar
/* It indicates little autocorrelation. */

***Step 7.4: Run the normality test***
varnorm
/* Errors are normally distributed. */

***Step 7.5: Run the stability test and get the graph***
varstable, graph
/* The model is stable. */

***Step 7.6: Conduct impulse response analysis and plot the graph***
irf create var1, set(var .irf) replace
irf graph oirf, irf(var1)

***Step 7.7: Conduct forecast-error variance decompositions and plot the graph***
irf graph fevd, irf(var1) impulse(unempl rte c ln GDP) response(unempl rte c ln GDP)

***Step 8: SVAR model***

***Step 8.1: Set the restrictive matrix***
matrix A=(1,0\.,1)
matrix B=(.,0\0,.)

***Step 8.2: Conduct SVAR model***
svar unempl rte c ln GDP, aeq(A) beq(B)
svar c ln GDP unempl rte, aeq(A) beq(B)

***Step 9: VECM model***

***Step 9.1: Conduct VECM model***
vec unempl rte c ln GDP, lags(2)

***Step 9.2: Run the autocorrelation test***
veclmar
/* It indicates little autocorrelation. */

***Step 9.3: Run the normality test***
vecnorm
/* Errors are normally distributed. */

***Step 9.4: Run the stability test and get the graph***
vecstable, graph
/* The model is stable. */
