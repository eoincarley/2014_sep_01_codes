pro cme_energy

	rsun = 6.9e10	    ; cm
	B_value=5.5
	Vcme = 4./3.*!pi*0.6*rsun^3.0
	E_mag = (1.0/(8*!pi))*(B_value^2.0)*Vcme
	print, 'Magnetic energy content of CME: '+string(E_mag)+' erg'	

	vel_cme = 2000*1e5 ; cm/s
	M_cme = 1e16
	E_kin = 2e32 ;ergs, from Pesce-Rollins 2015		;0.5*M_cme*vel_cme^2.0
	Mcme = 2.0*E_kin/vel_cme^2.0
	print, 'Kinetic energy content of CME: '+string(E_kin)+' erg'
	print, 'Ratio of kinetic to magnetic energy '+string(E_kin/E_mag)

	G = 6.67D-8	   ; cgs
	Msun = 1.998D33  ; g
	E_pot = G*Mcme*Msun/(1*rsun)	
	print, 'Potential energy content of CME: '+string(E_pot)+' erg'

	print, 'Ratio of mechanical to magnetic energy '+string((E_kin + E_pot)/E_mag)

END	