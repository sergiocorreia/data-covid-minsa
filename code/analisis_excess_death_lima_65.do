* ===========================================================================
* Exceso de mortalidad - Lima
* ===========================================================================
	include common.doh


	use "$data_path/fallecimientos_total.dta", clear
	rename death_date date
	drop if mi(date) | mi(ubigeo)
	keep if (departamento == "Callao") | (departamento == "Lima" & provincia == "Lima")

	gen byte i = 0
	keep if age >= 65
	gcollapse (count) deaths=i, by(ubigeo date) fast
	xtset ubigeo date
	tsfill, full
	replace deaths = 0 if mi(deaths)
	*bys ubigeo (date): gen long cum_deaths = sum(deaths)

	merge m:1 ubigeo using "$data_path/ubigeo2016", assert(match using) keep(master match) keepus(departamento provincia distrito ubigeo_reniec ubigeo_sunat) nogen nolab nonote
	merge m:1 ubigeo using "$data_path/poblacion", assert(match using) keep(master match) keepus(poblacion superficie lat lon) nogen nolab nonote
	
	compress
	xtset ubigeo date

	gen t = date // wofd(date)
	su t
	loc max = r(max)
	gen byte tail = t >= `max' - 3
	*drop if t == r(max) // week not ended
	
	gen day = doy(date)
	gen week = week(date)
	gen year = year(date)
	*format %tw week

	loc t day
	loc fmt 0(1000)6000
	loc fmt 0(100)500
	loc fmt 0(50)300
	gen deaths_tail = deaths if tail
	gcollapse (nansum) deaths*, by(year `t') fast

	tw	///
		(line deaths `t' if year == 2017, lc(gs8) lw(medium)) ///
		(line deaths `t' if year == 2018, lc(gs6) lw(medium)) ///
		(line deaths `t' if year == 2019, lc(gs4) lw(medium)) ///
		(line deaths `t' if year == 2020, lc(orange) lw(medium)) ///
		(line deaths_tail `t' if year == 2020 , lc(white) lw(medium) lpat(dot)) ///
		`cmd' ///
		, ///
		title("Muertes no violentas por dia (Lima Metrop, 2017-2020)") yscale(range(0 0)) ///
		xtitle("Dia") ///
		ytitle("Casos", margin(right) ) ///
		xlabel(0(30)360) ///
		ylabel(`fmt', format(%6.0fc) angle(horizontal)) ///
		scheme(s2color) ///
		graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
		legend(order(1 "2017" 2 "2018" 3 "2019" 4 "2020")  rows(1) region(fcolor(white) lcolor(white)) ) ///
		xsize(20) ysize(16)

	graph export "../figures/excess_mortality_lima_metro_65.png", replace width(2000)
	graph export "../figures/excess_mortality_lima_metro_65.pdf", replace

exit
