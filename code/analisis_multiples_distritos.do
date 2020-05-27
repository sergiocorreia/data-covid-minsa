* ===========================================================================
* Series por distrito en Lima
* ===========================================================================
	include common.doh

	use "$data_path/total_casos_positivos"
	keep if provincia == "Lima"
	tab distrito, m

	gen x = 100000 * cum_casos / poblacion

	levelsof distrito, loc(distritos)
	loc cmd
	foreach dist of loc distritos {
		loc cmd `"`cmd' (line x date if distrito=="`dist'", lc(gs8%20) lw(medium))"'
	}

	keep if date >= td(06mar2020)
	loc t0 = td(06mar2020)
	loc t1 = td(21may2020)

	tw	///
		(line x date if distrito == "La Molina", lc(green) lw(medium)) ///
		(line x date if distrito == "San Juan de Lurigancho", lc(blue) lw(medium)) ///
		(line x date if distrito == "La Victoria", lc(red) lw(medium)) ///
		(line x date if distrito == "Lima", lc(purple) lw(medium)) ///
		(line x date if distrito == "Jesús María", lc(orange) lw(medium)) ///
		`cmd' ///
		, ///
		title("COVID-19 en Lima, por distrito (acumulado)") yscale(range(0 0)) ///
		xtitle("Fecha") ///
		ytitle("Casos por 100,000 habitantes", margin(right) ) ///
		xlabel(`t0'(14)`t1', format("%tdMon_dd")) ///
		ylabel(, format(%6.0fc) angle(horizontal)) ///
		scheme(s2color) ///
		graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
		legend(order(1 "La Molina" 2 "SJL" 3 "La Victoria" 4 "Lima" 5 "Jesús María")  rows(1) region(fcolor(white) lcolor(white)) ) ///
		xsize(20) ysize(14)


	graph export "../figures/lima_cum.png", replace width(2000)
	graph export "../figures/lima_cum.pdf", replace
