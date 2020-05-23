* ===========================================================================
* Poblacion por distrito al 2017
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
// Load data
// --------------------------------------------------------------------------

	insheet  using "$input_path/misc/geodir-ubigeo-inei.csv", clear comma names double
	rename Ubigeo ubigeo
	destring poblacion superficie, replace ignore(",")
	rename y lat
	rename x lon
	keep ubigeo poblacion superficie lat lon
	save "$data_path/poblacion.dta", replace

exit
