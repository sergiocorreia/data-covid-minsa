
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
keep if !mi(exam_date) & dpto=="LIMA" & prov=="LIMA" & !mi(ubigeo)
tab dist, m

gen i = 0
gcollapse (count) n=i (first) poblacion, by(ubigeo dist exam_date) fast
gegen id = group(ubigeo)
xtset id exam_date
tsfill, full

bys id (ubigeo): replace ubigeo = ubigeo[1]
bys id (dist): replace dist = dist[_N]
bys id (poblacion): replace poblacion = poblacion[1]

rename n _
bys dist (exam_date): gen n = sum(_)
drop _
replace n = 100000 * n / poblacion

levelsof dist, loc(distritos)
loc cmd
foreach dist of loc distritos {
	loc cmd `"`cmd' (line n exam_date if dist=="`dist'", lc(gs8%20) lw(medium))"'
}

keep if exam_date >= td(06mar2020)
loc t0 = td(06mar2020)
loc t1 = td(21may2020)

tw	///
	(line n exam_date if dist == "LA MOLINA", lc(green) lw(medium)) ///
	(line n exam_date if dist == "SAN JUAN DE LURIGANCHO", lc(blue) lw(medium)) ///
	(line n exam_date if dist == "LA VICTORIA", lc(red) lw(medium)) ///
	(line n exam_date if dist == "LIMA", lc(orange) lw(medium)) ///
	`cmd' ///
	, ///
	title("COVID-19 en Lima, por distrito (acumulado)") yscale(range(0 0)) ///
	xtitle("Fecha") ///
	ytitle("Casos por 100,000 habitantes", margin(right) ) ///
	xlabel(`t0'(14)`t1', format("%tdMon_dd")) ///
	ylabel(, format(%6.0fc) angle(horizontal)) ///
	scheme(s2color) ///
	graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
	legend(order(1 "La Molina" 2 "SJL" 3 "La Victoria" 4 "Cercado")  rows(1) region(fcolor(white) lcolor(white)) ) ///
	xsize(20) ysize(16)

graph export "../figures/lima_cum.png", replace width(2000)
graph export "../figures/lima_cum.pdf", replace
