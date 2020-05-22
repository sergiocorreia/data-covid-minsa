
// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------

	clear all
	cls
	set more off
	global input_path "../input"
	global output_path "../output"
	set type double, permanently



use "$output_path/covid_22mayo"
keep if !mi(exam_date) & !mi(ubigeo) & dpto=="LIMA" & prov=="LIMA"
gen byte i = 0
gen densidad = poblacion / superficie

gcollapse (count) n=i (first) poblacion, by(ubigeo dist densidad) fast
gen share = 100000 * n / poblacion

keep ubigeo dist n share densidad
gen distrito = ""
replace distrito = "La Victoria" if dist == "LA VICTORIA"
replace distrito = "Rimac" if dist == "RIMAC"
replace distrito = "El Agustino" if dist == "EL AGUSTINO"
replace distrito = "San Isidro" if dist == "SAN ISIDRO"
replace distrito = "Los Olivos" if dist == "LOS OLIVOS"
replace distrito = "La Molina" if dist == "LA MOLINA"
replace distrito = "SJL" if dist == "SAN JUAN DE LURIGANCHO"

tw	///
	(sc share densidad, mcolor(blue%50) msize(medium) mlabel(distrito) mlabcolor(black) mlabposition(11)) ///
	(lfitci share densidad, lcolor(gs2%60) fcolor(gs8%20) alcolor(gs8%0)) ///
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
