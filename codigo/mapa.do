
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
keep if !mi(exam_date) & !mi(ubigeo)
gen byte i = 0
gcollapse (count) n=i (first) poblacion, by(ubigeo dpto prov dist lat lon) fast
gen share = 100000 * n / poblacion

keep ubigeo dpto prov dist lat lon n share
keep if n > 10
outsheet using "$output_path/coordinates.csv", replace comma

exit
