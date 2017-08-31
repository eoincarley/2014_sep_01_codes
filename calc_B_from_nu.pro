pro calc_B_from_nu, N, B_value=B_value
	
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

	B_value = interpol(B, nu, 0.972e9)

END