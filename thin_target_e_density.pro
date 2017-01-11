pro thin_target_e_density
	
	EM = 0.00022D49
	F = 1.02D54
	rsun = 6.9D10	; cm	
	L = 0.042*rsun
	Vth = 1e28	;(4./3.)*!pi*L^3.0
	Vpl = 1e28	;(4./3.)*!pi*(L)^3.0	;1.0*Vth		; N.B Assumes non-thermal volume is the same size as thermal volume.
	n0 = sqrt(EM/Vth)
	delta_thin = 3.0
	E_min = 9.3		; keV
	E_0 = 9.3
	e_mass = 0.511e3	;keV/c 
	;grams

	n_b = (F/(n0*Vpl))* $
		( (delta_thin-1)/(delta_thin-0.5) )* $
		( E_min^(-0.5) )*$
		(sqrt(e_mass/2.0/3.0e10^2.0))* $
		(E_0/E_min)^(delta_thin-1.0)

	print, 'Non-thermal electron density: '+string(n_b)	;/rsun	
	print, 'Thermal electron density: '+string(n0)	;/rsun	
	print, 'Percent electrons in power law tail: '+string((n_b/n0)*100.0) +' %'


	test_B_nu, n_b, B_value=B_value 
	print, B_value

stop
END