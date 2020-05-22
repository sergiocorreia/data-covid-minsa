clear all
cls
set more off

tempfile temp

import delimited "$input_path/ubigeo/ubigeo_peru_2016_departamentos.csv", asdouble case(lower) clear varnames(1) encoding("utf-8")
rename id department_id
rename name dpto
save "`temp'"


import delimited "$input_path/ubigeo/ubigeo_peru_2016_provincias.csv", asdouble case(lower) clear varnames(1) encoding("utf-8")
rename id province_id
rename name prov
merge m:1 department_id using "`temp'", assert(match) nogen nolab nonote
save "`temp'", replace

import delimited "$input_path/ubigeo/ubigeo_peru_2016_distritos.csv", asdouble case(lower) clear varnames(1) encoding("utf-8")
rename id ubigeo
rename name dist
merge m:1 province_id using "`temp'", assert(match) nogen nolab nonote

order ubigeo dpto prov dist
keep ubigeo dpto prov dist
sort ubigeo
save "$output_path/ubigeo2016", replace
do cleanup
gisid ubigeo
gisid dpto prov dist
save "$output_path/ubigeo2016_std", replace

bys dpto dist: gen N = _N
tab N
drop if N > 1
keep dpto dist ubigeo
gisid dpto dist
save "$output_path/ubigeo2016_std_no_prov", replace


