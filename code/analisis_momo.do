* ===========================================================================
* Exceso de mortalidad - Lima
* ===========================================================================
* https://www.euromomo.eu/how-it-works/methods/
* https://www.economist.com/graphic-detail/2020/04/16/tracking-covid-19-excess-deaths-across-countries

	include common.doh


	use "$data_path/fallecimientos_total.dta", clear
	rename death_date date
	keep if (departamento == "Callao") | (departamento == "Lima" & provincia == "Lima")
	drop if mi(date) // | mi(ubigeo)


	gen week = week(date)
	gen byte group = 1*(age<=14)+2*inrange(age, 15, 29)+3*inrange(age, 30, 44) + 4*inrange(age, 45, 65) + 5*inrange(age, 65, .)
	gen year = year(date)
	tab group
	tab year

foreach group in 1 2 3 4 5 {
	preserve
	keep if group==`group'

	if (`group' == 1) loc rango "<15"
	if (`group' == 2) loc rango "15-29"
	if (`group' == 3) loc rango "30-44"
	if (`group' == 4) loc rango "45-64"
	if (`group' == 5) loc rango ">65"

	if (`group' == 1) loc fmt 0(10)60
	if (`group' == 2) loc fmt 0(10)50
	if (`group' == 3) loc fmt 0(50)150
	if (`group' == 4) loc fmt 0(200)1000
	if (`group' == 5) loc fmt 0(500)2000

	gen byte i = 1
	gcollapse (nansum) deaths=i, by(ubigeo date year week) fast
	xtset ubigeo date
	tsfill, full
	replace deaths = 0 if mi(deaths)

	gcollapse (nansum) deaths, by(year week) fast
	xtset year week


	loc t week

	su `t' if year == 2020
	loc max = r(max)
	gen byte tail = `t' >= `max' - 1

	gen deaths_tail = deaths if tail
	gcollapse (nansum) deaths*, by(year `t') fast

	tw	///
		(line deaths `t' if year == 2020 & `t'<`max', lc(orange) lw(medium)) ///
		///(line deaths_tail `t' if year == 2020 , lc(orange) lw(medium) lpat(dot)) ///
		(line deaths `t' if year == 2017, lc(gs8%60) lw(medium)) ///
		(line deaths `t' if year == 2018, lc(gs6%60) lw(medium)) ///
		(line deaths `t' if year == 2019, lc(gs4%60) lw(medium)) ///
		(lpolyci deaths week if year < 2020, lcolor(gs2%50) clwidth(thick) cmissing(n) fcolor(gs2%30) alcolor(white) alwidth(vvvthin) cmissing(n) degree(2) level(99)) ///
		`cmd' ///
		, ///
		title("Fallecimientos `rango' años en Lima Metrop.") yscale(range(0 0)) ///
		xtitle("Semana") ///
		ytitle("Casos", margin(right) ) ///
		xlabel(0(4)52) ///
		ylabel(`fmt', format(%6.0fc) angle(horizontal)) ///
		scheme(s2color) ///
		graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
		legend(order(1 "2020" 2 "2017-2019" 5 "Polinomio local")  rows(1) region(fcolor(white) lcolor(white)) ) ///
		xsize(20) ysize(12)

	graph export "../figures/excess_mortality_lima_metro_`group'.png", replace width(2000)
	graph export "../figures/excess_mortality_lima_metro_`group'.pdf", replace
	restore
}
exit
