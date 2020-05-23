* ===========================================================================
* Densidad
* ===========================================================================
	include common.doh

	use "$data_path/total_casos_positivos"
	keep if departamento=="Lima" & provincia=="Lima"
	su date
	keep if date == r(max)
	gen densidad = poblacion / superficie
	gen x = 100000 * cum_casos / poblacion
	gen label = distrito if inlist(distrito, "La Victoria", "Rimac", "El Agustino", "San Isidro", "Los Olivos", "San Juan de Lurigancho", "Jesús María")
	replace label = "SJL" if label == "San Juan de Lurigancho"

	tw	///
		(sc x densidad, mcolor(blue%50) msize(medium) mlabel(label) mlabcolor(black) mlabposition(12)) ///
		(lfitci x densidad, lcolor(gs2%60) fcolor(gs8%20) alcolor(gs8%0)) ///
		, ///
		title("COVID-19 en Lima, segun densidad") yscale(range(0 0)) ///
		xtitle("Densidad (pob. por km2)") ///
		ytitle("Casos por 100,000 habitantes", margin(right) ) ///
		xlabel(, format("%6.0fc")) ///
		ylabel(, format("%6.0fc") angle(horizontal)) ///
		legend(off) ///
		scheme(s2color) ///
		graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
		xsize(20) ysize(16)

	graph export "../figures/densidad.png", replace width(2000)
	graph export "../figures/densidad.pdf", replace
