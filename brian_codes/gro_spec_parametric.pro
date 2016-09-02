pro gro_spec_parametric
	
	max_flux = 100.0
	alpha_thick = 2.8
	alpha_thin = -2.5
	nu_to = 1e9	;Ghz

	nu_ind = ( (dindgen(100)*(10.0 - 8.)/99.0) + 8. )
	nu = 10^nu_ind


	flux = max_flux*(nu/nu_to)^alpha_thick * (1.0 - exp(-1.0*(nu/nu_to)^(alpha_thin - alpha_thick) ) )


	window, 10, xs=600, ys=600
	!p.charsize = 1.5
	plot, nu, flux, $
			/xlog, $
			/ylog, $
			xtitle = 'Frequency (GHz)', $
			ytitle = 'Flux (SFU)';, $
			;yr = [0.1, 100.0]


	stop

END