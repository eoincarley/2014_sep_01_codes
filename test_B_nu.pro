pro test_B_nu, N, B_value=B_value
	
	;N = N*0.01
	rsun = 6.9e10	    ; cm
	Lxray = 0.042*rsun	; Size of the radio source
	Lradio = 0.45*rsun	; Size of the radio source
	;N = 3120982.9	;0.5*freq_to_dens(150e6)	;1646649.2	;	0.01*freq_to_dens(150e6)	;1.6e7	;0.1*freq_to_dens(150e6);2630812.0;(Lxray/Lradio)*83193586;	2630812.0		;0.064*freq_to_dens(150e6)	;cm^-3
	B = dindgen(100)*(100 - 0.01)/99.0 + 0.01
	alpha_thin = -1.8 ;+ 0.1
	delta = 2.9 ;-1.1*(alpha_thin-1.2)
	angle = 45.0
	

	r = 2.72e3*10.0^(0.27*delta)
	x = sin(angle*!dtor)^(0.41+0.03*delta)
	y = (N*Lradio)^(0.32-0.03*delta)
	z = B^(0.68+0.03*delta)

	nu = r*x*y*z
	;print, nu

	;window, 10, xs=400, ys=400
	;plot, B, nu, $
	;	/xs, $
	;	/ys, $
	;	xtitle='B (Gauss)', $
	;	ytitle='Frequency (Hz)', $
	;	charsize=2.0, $
	;	/xlog, $
	;	/ylog

	B_value = interpol(B, nu, 0.972e9)
	;print, 'Magnetic field strength: '+string(B_value)+' G'	
	;print, ' '


	;-------------------------------------;
	;B_value=4.0
	;Vcme = 4./3.*!pi*0.5*rsun^3.0
	;E_mag = (1.0/(8*!pi))*(B_value^2.0)*Vcme
	;print, 'Magnetic energy content of CME: '+string(E_mag)+' erg'	

	;vel_cme = 2000*1e5 ; cm/s
	;M_cme = 1e16
	;E_kin = 2e32 ;ergs, from Pesce-Rollins 2015		;0.5*M_cme*vel_cme^2.0
	;Mcme = 2.0*E_kin/vel_cme^2.0
	;print, 'Kinetic energy content of CME: '+string(E_kin)+' erg'

	;print, 'Ratio of kinetic to magnetic energy '+string(E_kin/E_mag)


	;G = 6.67D-8	   ; cgs
	;Msun = 1.998D33  ; g
	;E_pot = G*Mcme*Msun/(1*rsun)	
	;print, 'Potential energy content of CME: '+string(E_pot)+' erg'

	;print, 'Ratio of mechanical to magnetic energy '+string((E_kin + E_pot)/E_mag)


END