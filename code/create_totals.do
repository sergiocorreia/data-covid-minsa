* ========================================================================= ==
* Crear totales por dia y distritos
* ===========================================================================


// --------------------------------------------------------------------------
// Setup
// --------------------------------------------------------------------------
	include common.doh




// --------------------------------------------------------------------------
// Casos positivos
// --------------------------------------------------------------------------

	use "$data_path/positivos_covid.dta", clear
	rename exam_date date
	drop if mi(date) | mi(ubigeo)
	gen byte casos_pr = (is_antibody == 1)
	gen byte casos_pcr = (is_antibody == 0)

	gcollapse (sum) casos*, by(ubigeo date) fast
	xtset ubigeo date
	tsfill, full
	replace casos_pr = 0 if mi(casos_pr)
	replace casos_pcr = 0 if mi(casos_pcr)
	gen casos = casos_pr + casos_pcr

	bys ubigeo (date): gen long cum_casos_pr = sum(casos_pr)
	bys ubigeo (date): gen long cum_casos_pcr = sum(casos_pcr)
	bys ubigeo (date): gen long cum_casos = sum(casos)

	merge m:1 ubigeo using "$data_path/ubigeo2016", assert(match using) keep(master match) keepus(departamento provincia distrito ubigeo_reniec ubigeo_sunat) nogen nolab nonote
	merge m:1 ubigeo using "$data_path/poblacion", assert(match using) keep(master match) keepus(poblacion superficie lat lon) nogen nolab nonote
	
	compress
	xtset ubigeo date
	save "$data_path/total_casos_positivos", replace

	* Fechas mas entendibles
	format %tdCY-N-D *date*
	outsheet using "$output_path/total_casos_positivos.csv", comma replace


// --------------------------------------------------------------------------
// Muertes no violentas
// --------------------------------------------------------------------------

	use "$data_path/fallecimientos_total.dta", clear
	rename death_date date
	drop if mi(date) | mi(ubigeo)

	gen byte i = 0
	gcollapse (count) deaths=i, by(ubigeo date) fast
	xtset ubigeo date
	tsfill, full
	replace deaths = 0 if mi(deaths)
	*bys ubigeo (date): gen long cum_deaths = sum(deaths)

	merge m:1 ubigeo using "$data_path/ubigeo2016", assert(match using) keep(master match) keepus(departamento provincia distrito ubigeo_reniec ubigeo_sunat) nogen nolab nonote
	merge m:1 ubigeo using "$data_path/poblacion", assert(match using) keep(master match) keepus(poblacion superficie lat lon) nogen nolab nonote
	
	compress
	xtset ubigeo date
	save "$data_path/total_muertes_no_violentas", replace

	* Fechas mas entendibles
	format %tdCY-N-D *date*
	*outsheet using "$output_path/total_muertes_no_violentas.csv", comma replace


// --------------------------------------------------------------------------
// Fallecimientos por covid
// --------------------------------------------------------------------------

	use "$data_path/fallecimientos_covid.dta", clear
	rename death_date date
	drop if mi(date) | mi(ubigeo)

	gen byte i = 0
	gcollapse (count) deaths=i, by(ubigeo date) fast
	xtset ubigeo date
	tsfill, full
	replace deaths = 0 if mi(deaths)
	bys ubigeo (date): gen long cum_deaths = sum(deaths)

	merge m:1 ubigeo using "$data_path/ubigeo2016", assert(match using) keep(master match) keepus(departamento provincia distrito ubigeo_reniec ubigeo_sunat) nogen nolab nonote
	merge m:1 ubigeo using "$data_path/poblacion", assert(match using) keep(master match) keepus(poblacion superficie lat lon) nogen nolab nonote
	
	compress
	xtset ubigeo date
	save "$data_path/total_muertes_covid", replace

	* Fechas mas entendibles
	format %tdCY-N-D *date*
	outsheet using "$output_path/total_muertes_covid.csv", comma replace

