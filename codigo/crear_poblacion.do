* ===========================================================================
* Poblacion por distrito al 2015
* ===========================================================================


// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------

	clear all
	cls
	set more off
	* ssc install gtools

	global input_path "../input"
	global output_path "../output"
	set type double, permanently


// --------------------------------------------------------------------------
// Load datq
// --------------------------------------------------------------------------

	insheet  using "$input_path/geodir-ubigeo-inei.csv", clear comma names double
	rename Ubigeo ubigeo
	destring poblacion superficie, replace ignore(",")
	rename y lat
	rename x lon
	keep ubigeo poblacion superficie lat lon
	save "$output_path/poblacion.dta", replace
