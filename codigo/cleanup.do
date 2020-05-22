qui {
foreach v in dpto prov dist {
	replace `v' = trim(upper(`v'))
	
	replace `v' = subinstr(`v', "ñ", "N", .)
	*replace `v' = subinstr(`v', char(195) + char(177), "N", .)
	
	replace `v' = subinstr(`v', "Ñ", "N", .)
	*replace `v' = subinstr(`v', char(195) + char(145), "N", .)
	
	replace `v' = subinstr(`v', "á", "A", .)
	replace `v' = subinstr(`v', "à", "A", .)
	*replace `v' = subinstr(`v', char(195) + char(161), "A", .)
	
	replace `v' = subinstr(`v', "Á", "A", .)
	replace `v' = subinstr(`v', "À", "A", .)
	*replace `v' = subinstr(`v', char(195) + char(129), "A", .)
	
	replace `v' = subinstr(`v', "é", "E", .)
	replace `v' = subinstr(`v', "è", "E", .)
	*replace `v' = subinstr(`v', char(195) + char(169), "E", .)

	replace `v' = subinstr(`v', "É", "E", .)
	replace `v' = subinstr(`v', "È", "E", .)
	*replace `v' = subinstr(`v', char(195) + char(137), "E", .)
	
	replace `v' = subinstr(`v', "í", "I", .)
	replace `v' = subinstr(`v', "ì", "I", .)
	*replace `v' = subinstr(`v', char(195) + char(173), "I", .)
	
	replace `v' = subinstr(`v', "Í", "I", .)
	replace `v' = subinstr(`v', "Ì", "I", .)
	*replace `v' = subinstr(`v', char(195) + char(141), "I", .)
	
	replace `v' = subinstr(`v', "ó", "O", .)
	replace `v' = subinstr(`v', "ò", "O", .)
	*replace `v' = subinstr(`v', char(195) + char(179), "O", .)
	
	replace `v' = subinstr(`v', "Ó", "O", .)
	replace `v' = subinstr(`v', "Ò", "O", .)
	*replace `v' = subinstr(`v', char(195) + char(147), "O", .)
	
	replace `v' = subinstr(`v', "ú", "U", .)
	replace `v' = subinstr(`v', "ù", "U", .)
	*replace `v' = subinstr(`v', char(195) + char(186), "U", .)

	replace `v' = subinstr(`v', "Ú", "U", .)
	replace `v' = subinstr(`v', "Ù", "U", .)
	*replace `v' = subinstr(`v', char(195) + char(154), "U", .)
}

replace prov = "CALLAO" if prov == "PROV. CONST. DEL CALLAO"
replace dpto = "CALLAO" if prov == "CALLAO" & mi(dpto)
replace dist = "CARMEN DE LA LEGUA REYNOSO" if dist == "CARMEN DE LA LEGUA-REYNOSO"
replace dist = "ANDRES AVELINO CACERES" if dist == "ANDRES AVELINO CACERES DORREGARAY"

}

**replace dpto = "CALLAO" if inlist(dist, "BELLAVISTA", "CALLAO", "CARMEN DE LA LEGUA REYNOSO", "LA PERLA", "LA PUNTA", "VENTANILLA")
**replace prov = "CALLAO" if inlist(dist, "BELLAVISTA", "CALLAO", "CARMEN DE LA LEGUA REYNOSO", "LA PERLA", "LA PUNTA", "VENTANILLA")

replace prov = "HUAMANGA" if dpto == "AYACUCHO" & prov == "AYACUCHO" & dist == "AYACUCHO"
replace prov = "NASCA" if prov == "NAZCA" & dpto == "ICA"
replace dist = "NASCA" if prov == "NASCA" & dist == "NAZCA" & dpto == "ICA"
replace dist = "CORONEL GREGORIO ALBARRACIN LANCHIPA" if inlist(dist, "CORONEL GREGORIO ALBARRACIN LANCHIPA", "CORONEL GREGORIO ALBARRACIN L.")

replace prov = "MAYNAS" if dpto == "LORETO" & (inlist(dist, "ALTO NANAY", "BELEN", "FERNANDO LORES", "INDIANA", "IQUITOS", "LAS AMAZONAS", "MAZAN", "NAPO", "PUNCHANA") | inlist(dist, "SAN JUAN BAUTISTA", "TORRES CAUSANA"))
replace prov = "LAMBAYEQUE" if dpto == "LAMBAYEQUE" & (inlist(dist, "CHOCHOPE", "ILLIMO", "JAYANCA", "LAMBAYEQUE", "MOCHUMI", "MORROPE", "MOTUPE") | inlist(dist, "OLMOS", "PACORA", "SALAS", "SAN JOSE", "TUCUME"))
replace prov = "ALTO AMAZONAS" if dpto == "LORETO" & dist == "SAN JUAN BAUTISTA"

replace dpto = "LIMA" if dpto == "CALLAO" & prov == "LIMA"

replace dist = "CHEPEN" if dist == "CHEP+N"
