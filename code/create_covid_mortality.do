* ===========================================================================
* Cargar data de mortalidad por COVID-19
* ===========================================================================


// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------
	include common.doh


// --------------------------------------------------------------------------
// Importar fallecimientos
// --------------------------------------------------------------------------

	import delimited "$input_path/minsa/fallecidos_covid.csv", asdouble case(lower) clear varnames(1)


	gen long birth_date = .
	cap rename fecha_nac fecha_nacimiento // nombre cambio en may22
	replace birth_date = date(fecha_nacimiento, "YMD") if (strpos(fecha_nacimiento, "19") == 1) & strpos(fecha_nacimiento, "-")
	replace birth_date = date(fecha_nacimiento, "YMD") if (strpos(fecha_nacimiento, "20") == 1) & strpos(fecha_nacimiento, "-")
	replace birth_date = date(fecha_nacimiento, "DMY") if strpos(fecha_nacimiento, "/19")
	replace birth_date = date(fecha_nacimiento, "DMY") if strpos(fecha_nacimiento, "/20")
	li if mi(birth_date) & !mi(fecha_nacimiento)

	gen long death_date = .
	replace death_date = date(fecha_fallecimiento, "YMD") if strpos(fecha_fallecimiento, "2020-")
	replace death_date = date(fecha_fallecimiento, "DMY") if strpos(fecha_fallecimiento, "/2020")
	li fecha_fallecimiento if mi(death_date)

	format %td *_date
	la var death_date "Date of death"
	la var birth_date "Date of birth"

	* Detect/fix data problems with dates
	cou if mi(death_date) & !mi(fecha_fallecimiento)
	cou if mi(birth_date) & !mi(fecha_nacimiento)
	cou if birth_date > td(21may2020) & !mi(birth_date)

	replace birth_date = . if birth_date > td(22may2020) & !mi(birth_date)
	gen byte is_female = sexo == "FEMENINO" if inlist(sexo, "FEMENINO", "MASCULINO")
	
	* Remove duplicates
	bys _all: keep if _n == 1

	clonevar dpto = departamento
	clonevar prov = provincia
	clonevar dist = distrito
	drop departamento provincia distrito
	do cleanup_locations
	merge m:1 dpto prov dist using "$data_path/ubigeo2016_std.dta" , keep(master match) nolab nonote nogen
	merge m:1 dpto dist using "$data_path/ubigeo2016_std_no_prov.dta" , keep(master match match_update) nolab nonote nogen update

	* !!!! Un % alto de la data de fallecimientos no se puede georeferenciar por distrito
	cou if mi(ubigeo) // 708
	li dpto prov dist if mi(ubigeo) & !mi(dist) // 13

	* Cuando hay duplicados, escoger los que tienen ubigeo correcto
	gen byte bad_data = mi(ubigeo)
	bys uuid death_date (bad_data): keep if _n == 1

	* Cuando aun quedan duplicados, escoger la primera fecha de fallecimiento
	bys uuid: gen N = _N
	tab N
	li uuid fecha* departamento provincia distrito if N > 1, sepby(uuid)
	bys uuid (death_date): keep if _n == 1
	gisid uuid

	keep uuid *_date is_female ubigeo ubigeo_reniec ubigeo_sunat departamento provincia distrito
	order uuid *_date is_female ubigeo ubigeo_reniec ubigeo_sunat departamento provincia distrito
	compress
	save "$data_path/fallecimientos_covid.dta", replace

	* Fechas mas entendibles
	format %tdCY-N-D *date*
	export delimited "$output_path/fallecimientos_covid.csv", delim(",") replace

exit
