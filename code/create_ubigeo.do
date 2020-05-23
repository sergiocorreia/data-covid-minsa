* ===========================================================================
* Create district-level data
* ===========================================================================


// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------
	include common.doh


// --------------------------------------------------------------------------
// Concordancia de ubigeos
// --------------------------------------------------------------------------

	import delimited "$input_path/ubigeo/equivalencia-ubigeos-oti-concytec.csv", asdouble case(lower) clear varnames(1) encoding("utf-8")
	rename cod_ubigeo_inei ubigeo
	rename cod_ubigeo_reniec ubigeo_reniec
	rename cod_ubigeo_sunat ubigeo_sunat

	replace ubigeo = "" if mi(real(ubigeo))
	replace ubigeo_reniec = "" if mi(real(ubigeo_reniec))
	replace ubigeo_sunat = "" if mi(real(ubigeo_sunat))

	destring ubigeo*, replace
	drop if mi(ubigeo)
	keep ubigeo*
	compress
	sort ubigeo
	save "$data_path/concordancia_ubigeos", replace
	

// --------------------------------------------------------------------------
// Create ubigeo <-> distrito
// --------------------------------------------------------------------------

	tempfile temp

	import delimited "$input_path/ubigeo/ubigeo_peru_2016_departamentos.csv", asdouble case(lower) clear varnames(1) encoding("utf-8")
	rename id department_id
	rename name departamento
	save "`temp'"

	import delimited "$input_path/ubigeo/ubigeo_peru_2016_provincias.csv", asdouble case(lower) clear varnames(1) encoding("utf-8")
	rename id province_id
	rename name provincia
	merge m:1 department_id using "`temp'", assert(match) nogen nolab nonote
	save "`temp'", replace

	import delimited "$input_path/ubigeo/ubigeo_peru_2016_distritos.csv", asdouble case(lower) clear varnames(1) encoding("utf-8")
	rename id ubigeo
	rename name distrito
	merge m:1 province_id using "`temp'", assert(match) nogen nolab nonote

	replace departamento = ustrtrim(departamento)
	replace provincia = ustrtrim(provincia)
	replace distrito = ustrtrim(distrito)
	
	merge 1:1 ubigeo using "$data_path/concordancia_ubigeos", keep(master match) keepus(ubigeo_reniec ubigeo_sunat) nogen nolab nonote

	order ubigeo departamento provincia distrito ubigeo_reniec ubigeo_sunat
	keep ubigeo departamento provincia distrito ubigeo_reniec ubigeo_sunat
	sort ubigeo
	gisid ubigeo
	gisid departamento provincia distrito
	format %06.0f ubigeo*
	save "$data_path/ubigeo2016", replace

	export delimited "$output_path/ubigeo2016.csv", delim(",") replace

	* Limpiar tildes, etc.

	clonevar dpto = departamento
	clonevar prov = provincia
	clonevar dist = distrito
	do cleanup_locations

	gisid ubigeo
	gisid departamento provincia distrito
	gisid dpto prov dist
	save "$data_path/ubigeo2016_std", replace

	* Tratar de hacer joins sin provincia (solo dpto y dist)
	bys dpto dist: gen N = _N
	tab N
	drop if N > 1
	keep dpto dist ubigeo departamento provincia distrito ubigeo_reniec ubigeo_sunat
	gisid dpto dist
	save "$data_path/ubigeo2016_std_no_prov", replace


// --------------------------------------------------------------------------
// Create map from ubigeo reniec
// --------------------------------------------------------------------------

	use "$data_path/ubigeo2016", clear
	drop if mi(ubigeo_reniec)
	gisid ubigeo_reniec
	save "$data_path/ubigeo_reniec_map", replace

exit
