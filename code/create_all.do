* ===========================================================================
* Create/process all datasets
* ===========================================================================

	do create_ubigeo // data by district
	do create_pop // pop, lat, lon, etc.

	do create_covid_positive
	do create_covid_mortality
	do create_all_mortality
	do create_totals


exit
