* ===========================================================================
* Cargar data de mortalidad por todos los casos
* ===========================================================================


// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------
	include common.doh


// --------------------------------------------------------------------------
// Importar fallecimientos
// --------------------------------------------------------------------------

	import delimited "$input_path/minsa/DATASET_SINADEF_20052020.csv", asdouble case(lower) clear varnames(1)
	drop nº
	gen byte is_female = sexo == "FEMENINO" if inlist(sexo, "FEMENINO", "MASCULINO")
	replace edad = "" if edad =="NO REGISTRADO"
	gen double age = real(edad)
	replace age = 0 if inlist(tiempoedad, "DIAS", "HORAS", "MESES", "MINUTOS", "SEGUNDOS") //  =(

	* Excluir muerte violenta
	replace muerteviolenta = trim(muerteviolenta)
	keep if inlist(muerteviolenta, "", "NO SE CONOCE")

	* Solo Peru
	keep if trim(paisdomicilio) == "PERU"

	drop tiposeguro estadocivil niveldeinstrucción necropsia // ignorados

	rename departamentodomicilio dpto
	rename provinciadomicilio prov
	rename distritodomicilio dist
	do cleanup_locations
	merge m:1 dpto prov dist using "$data_path/ubigeo2016_std.dta" , keep(master match) nolab nonote nogen
	merge m:1 dpto dist using "$data_path/ubigeo2016_std_no_prov.dta" , keep(master match match_update) nolab nonote nogen update
	drop ubigeo_reniec

	gen x = substr(codubigeodomicilio, 7, 8)
	replace x = subinstr(x, "-", "", .)
	gen long ubigeo_reniec = real(x)
	br cod* x ubigeo_reniec
	drop x

	merge m:1 ubigeo_reniec using "$data_path/ubigeo_reniec_map.dta" , keep(master match match_update) nolab nonote nogen update

	cou if mi(ubigeo) // 558
	li dpto prov dist if mi(ubigeo) & !mi(dist) // 11

	gen long death_date = .
	replace death_date = date(fecha, "DMY") if strpos(fecha, "/2020")
	replace death_date = date(fecha, "DMY") if strpos(fecha, "/201")
	format %td *_date
	la var death_date "Date of death"
	li fecha if mi(death_date)

	keep death_date ubigeo ubigeo_reniec ubigeo_sunat departamento provincia distrito is_female age 
	order death_date ubigeo ubigeo_reniec ubigeo_sunat departamento provincia distrito is_female age 
	sort death_date ubigeo

	save "$data_path/fallecimientos_total.dta", replace

	* Fechas mas entendibles
	format %tdCY-N-D *date*
	export delimited "$output_path/fallecimientos_total.csv", delim(",") replace

exit
