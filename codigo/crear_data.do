* ===========================================================================
* Cargar data de COVID-Peru
* ===========================================================================
* TODO: Usar multiples examenes para completar ubicaciones vacias?

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


	do crear_ubigeo


// --------------------------------------------------------------------------
// Importar fallecimientos
// --------------------------------------------------------------------------

	import delimited "$input_path/FALLECIDOS_CDC.csv", asdouble case(lower) clear varnames(1)
	gen long birth_date = date(fecha_nacimiento, "YMD")
	gen long death_date = date(fecha_fallecimiento, "DMY")
	format %td *_date
	gen byte is_female = sexo == "FEMENINO" if inlist(sexo, "FEMENINO", "MASCULINO")
	
	bys _all: keep if _n == 1
	gen byte bad_data = mi(departamento) | mi(provincia) | mi(distrito)
	bys uuid death_date (bad_data): keep if _n == 1
	bys uuid: gen N = _N
	tab N
	li fecha* departamento provincia distrito if N > 1
	bys uuid (death_date): keep if _n == 1
	gisid uuid

	clonevar dpto = departamento
	clonevar prov = provincia
	clonevar dist = distrito
	do cleanup

	keep uuid *_date is_female dpto prov dist
	compress
	tempfile temp
	save "`temp'"


// --------------------------------------------------------------------------
// Importar casos
// --------------------------------------------------------------------------

	import delimited "$input_path/DATOSABIERTOS_SISCOVID.csv", asdouble case(lower) clear varnames(1)

	* Quitar duplicados
	bys _all: keep if _n == 1
	**bys uuid: gen N = _N
	**gisid uuid

	gen long birth_date = .
	replace birth_date = date(fecha_nacimiento, "YMD") if (strpos(fecha_nacimiento, "19") == 1) & strpos(fecha_nacimiento, "-")
	replace birth_date = date(fecha_nacimiento, "YMD") if (strpos(fecha_nacimiento, "20") == 1) & strpos(fecha_nacimiento, "-")

	replace birth_date = date(fecha_nacimiento, "DMY") if strpos(fecha_nacimiento, "/19")
	replace birth_date = date(fecha_nacimiento, "DMY") if strpos(fecha_nacimiento, "/20")
	li if mi(birth_date) & !mi(fecha_nacimiento)

	gen long exam_date = .
	replace exam_date = date(fecha_prueba, "YMD") if strpos(fecha_prueba, "2020-")
	replace exam_date = date(fecha_prueba, "DMY") if strpos(fecha_prueba, "/2020")
	li fecha_prueba if mi(exam_date)

	format %td *_date
	su *_date, format

	* Quitar fechas invalidas
	replace birth_date = . if birth_date > td(21may2020)
	replace exam_date = . if !inrange(exam_date, td(01mar2020), td(21may2020))
	
	gen byte is_female = sexo == "FEMENINO" if inlist(sexo, "FEMENINO", "MASCULINO")
	gen byte exam_type = 1 * (tipo_prueba == "PCR") + 2 * (tipo_prueba == "PC")
	la def exam_type 1 "PCR" /* polymerise chain reaction */ 2 "PC" /* positive control */
	la val exam_type exam_type

	clonevar dpto = departamento
	clonevar prov = provincia
	clonevar dist = distrito

	do cleanup

	keep uuid *_date is_female exam_type dpto prov dist

	bys uuid (exam_date): keep if _n == 1 // Fecha de primer positivo

	merge 1:1 uuid using "`temp'", // keepus() nogen nolab nonote
	gen byte is_death = _merge != 1
	drop _merge


	drop if mi(dist)
	merge m:1 dpto prov dist using "$output_path/ubigeo2016_std.dta" , keep(master match) nolab nonote nogen
	merge m:1 dpto dist using "$output_path/ubigeo2016_std_no_prov.dta" , keep(master match match_update) nolab nonote nogen update

	**br if _merge == 1 // 8865 8851 235
	li dpto prov dist if mi(ubigeo)
	drop if mi(ubigeo)

	merge m:1 ubigeo using "$output_path/poblacion", keep(master match) keepusing(poblacion superficie lat lon) nogen nolab nonote



keep uuid birth_date exam_date death_date is_female exam_type is_death dpto prov dist ubigeo poblacion superficie lat lon
order uuid birth_date exam_date death_date is_female exam_type is_death dpto prov dist ubigeo poblacion superficie lat lon
sort exam_date death_date
compress

saveold "$output_path/covid_22mayo", replace v(14)

* Fechas mas entendibles
format %tdCY-N-D *date*
outsheet using "$output_path/covid_22mayo.csv", comma replace

exit
