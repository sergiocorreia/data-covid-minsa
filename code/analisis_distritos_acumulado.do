
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
keep if inlist(dist, "LA MOLINA", "SAN JUAN DE LURIGANCHO") & !mi(exam_date) & dpto=="LIMA" & prov=="LIMA"

gen i = 0
gcollapse (count) n=i (first) poblacion, by(ubigeo dist exam_date) fast

xtset ubigeo exam_date
tsfill
rename n _
bys dist (exam_date): gen n = sum(_)

replace n = 100000 * n / poblacion

tw	///
	(line n exam_date if dist == "LA MOLINA", lc(green) lw(medium)) ///
	(line n exam_date if dist == "SAN JUAN DE LURIGANCHO", lc(orange) lw(medium)) ///
	, ///
	title("Casos Positivos (La Molina y SJL)") yscale(range(0 0)) ///
	xtitle("Fecha") ///
	ytitle("Casos por 100,000 habitantes") ///
	ylabel(, format(%6.0f) angle(horizontal)) ///
	scheme(s2color) ///
	graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
	legend(order(1 "La Molina" 2 "San Juan de Lurigancho")) ///
	xsize(20) ysize(16)

graph export "../figures/lm_sjl_cum.png", replace width(2000)
graph export "../figures/lm_sjl_cum.pdf", replace



// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------

	clear all
	cls
	set more off
	global input_path "../input"
	global output_path "../output"



use "$output_path/covid_22mayo"
keep if is_death
drop exam_date
rename death_date exam_date

keep if inlist(dist, "LA MOLINA", "SAN JUAN DE LURIGANCHO") & !mi(exam_date) & dpto=="LIMA" & prov=="LIMA"

gen i = 0
gcollapse (count) n=i, by(ubigeo dist exam_date) fast
xtset ubigeo exam_date
tsfill
rename n _
bys dist (exam_date): gen n = sum(_)

replace n = 100000 * n / 140679 if dist == "LA MOLINA"
replace n = 100000 * n / 1038495 if dist == "SAN JUAN DE LURIGANCHO"

tw	///
	(line n exam_date if dist == "LA MOLINA", lc(green) lw(medium)) ///
	(line n exam_date if dist == "SAN JUAN DE LURIGANCHO", lc(orange) lw(medium)) ///
	, ///
	title("Fallecimientos por COVID-19 (La Molina y SJL)") yscale(range(0 0)) ///
	xtitle("Fecha") ///
	ytitle("Muertes por 100,000 habitantes") ///
	ylabel(, format(%6.0f) angle(horizontal)) ///
	scheme(s2color) ///
	graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
	legend(order(1 "La Molina" 2 "San Juan de Lurigancho")) ///
	xsize(20) ysize(16)

graph export "../figures/lm_sjl_cum_muertes.png", replace width(2000)
graph export "../figures/lm_sjl_cum_muertes.pdf", replace
