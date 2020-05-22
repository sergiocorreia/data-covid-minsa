
// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------

	clear all
	cls
	set more off
	global input_path "../input"
	global output_path "../output"



use "$output_path/covid_22mayo"
keep if inlist(dpto, "LIMA", "CALLAO") & !mi(exam_date)

gcollapse (count) n=ubigeo, by(exam_date) fast

tw	(line n exam_date, lc(black) lw(thick) ) ///
	(lowess n exam_date, mean lcolor(midblue%80) lwidth(thick) lpattern(dash)) , ///
	title("Casos Positivos (Lima y Callao)") yscale(range(0 0)) ///
	xtitle("Fecha") ///
	ytitle("Casos") ///
	ylabel(, format(%3.0f) angle(horizontal)) ///
	scheme(s2color) ///
	graphregion(fcolor(white) lc(white) ifcolor(white) ilc(white) margin(sides)) ///
	legend(off) ///
	xsize(20) ysize(12)

graph export "../figures/lima_callao.png", replace width(2000)
graph export "../figures/lima_callao.pdf", replace
