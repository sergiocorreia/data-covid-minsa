
// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------

	clear all
	cls
	set more off
	global input_path "../input"
	global output_path "../output"



use "$output_path/covid_22mayo"
keep if inlist(dist, "LA MOLINA", "SAN JUAN DE LURIGANCHO") & !mi(exam_date) & dpto=="LIMA" & prov=="LIMA"

gcollapse (count) n=ubigeo, by(dist exam_date) fast
replace n = 100000 * n / 140679 if dist == "LA MOLINA"
replace n = 100000 * n / 1038495 if dist == "SAN JUAN DE LURIGANCHO"

tw	///
	(line n exam_date if dist == "LA MOLINA", lc(green) lw(medium)) ///
	(line n exam_date if dist == "SAN JUAN DE LURIGANCHO", lc(orange) lw(medium)) ///
	(lowess n exam_date if dist == "LA MOLINA", mean lcolor(green%80) lwidth(thick) lpattern(dash)) ///
	(lowess n exam_date if dist == "SAN JUAN DE LURIGANCHO", mean lcolor(orange%80) lwidth(thick) lpattern(dash)) ///
	, ///
	title("Casos Positivos (La Molina y SJL)") yscale(range(0 0)) ///
	xtitle("Fecha") ///
	ytitle("Casos por 100,000 habitantes") ///
	ylabel(, format(%6.0f) angle(horizontal)) ///
	scheme(s2color) ///
	graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
	legend(order(1 "La Molina" 2 "San Juan de Lurigancho")) ///
	note("Nota: curvas basadas en interpolaciones lowess") ///
	xsize(20) ysize(16)

graph export "lm_sjl.png", replace width(2000)
graph export "lm_sjl.pdf", replace
