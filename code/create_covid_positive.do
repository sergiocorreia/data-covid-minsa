* ========================================================================= ==
* Cargar data de tests positivos - COVID-19
* ===========================================================================


// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------
	include common.doh


// --------------------------------------------------------------------------
// Importar casos
// --------------------------------------------------------------------------

	import delimited "$input_path/minsa/DATOSABIERTOS_SISCOVID.csv", asdouble case(lower) clear varnames(1)

	* Quitar duplicados
	bys _all: keep if _n == 1

	**gen long birth_date = .
	**replace birth_date = date(fecha_nacimiento, "YMD") if (strpos(fecha_nacimiento, "19") == 1) & strpos(fecha_nacimiento, "-")
	**replace birth_date = date(fecha_nacimiento, "YMD") if (strpos(fecha_nacimiento, "20") == 1) & strpos(fecha_nacimiento, "-")
	**replace birth_date = date(fecha_nacimiento, "DMY") if strpos(fecha_nacimiento, "/19")
	**replace birth_date = date(fecha_nacimiento, "DMY") if strpos(fecha_nacimiento, "/20")
	**li fecha_nacimiento if mi(birth_date) & !mi(fecha_nacimiento)

	gen long exam_date = .
	replace exam_date = date(fecha_resultado, "YMD") if strpos(fecha_resultado, "2020-")
	replace exam_date = date(fecha_resultado, "DMY") if strpos(fecha_resultado, "/2020")
	li fecha_resultado if mi(exam_date)


	format %td *_date
	su *_date, format

	* Quitar fechas invalidas
	**replace birth_date = . if birth_date > td(21may2020)
	replace exam_date = . if !inrange(exam_date, td(01mar2020), td(21may2020))
	
	gen byte is_female = sexo == "FEMENINO" if inlist(sexo, "FEMENINO", "MASCULINO")
	assert inlist(metododx, "PR", "PCR") // Prueba Rapida ; Polymerise chain reaction
	gen byte is_antibody = metododx == "PR"

	clonevar dpto = departamento
	clonevar prov = provincia
	clonevar dist = distrito
	drop departamento provincia distrito
	do cleanup_locations
	merge m:1 dpto prov dist using "$data_path/ubigeo2016_std.dta" , keep(master match) nolab nonote nogen
	merge m:1 dpto dist using "$data_path/ubigeo2016_std_no_prov.dta" , keep(master match match_update) nolab nonote nogen update

	li dpto prov dist if mi(ubigeo) & !mi(dist)
	**br dpto prov dist if mi(ubigeo) & !mi(dist)
	drop if mi(ubigeo)

	keep  uuid *_date is_female is_antibody ubigeo ubigeo_reniec ubigeo_sunat departamento provincia distrito
	order uuid *_date is_female is_antibody ubigeo ubigeo_reniec ubigeo_sunat departamento provincia distrito
	
	bys uuid (exam_date): keep if _n == 1 // Fecha de primer positivo
	gisid uuid
	sort exam_date ubigeo
	compress
	save "$data_path/positivos_covid.dta", replace

	* Fechas mas entendibles
	format %tdCY-N-D *date*
	outsheet using "$output_path/positivos_covid.csv", comma replace

exit
