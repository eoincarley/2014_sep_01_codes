pro gyro_spectrum

	!p.charsize=2.0
	n_e = 1e10	;cm^-3
	 = 1e4 	;G
	fB = 2.8e6*B
	AU = 1.5e13		; cm
	rsun = 6.95e10 	; cm
	L = 2.0*rsun	; cm
	OMEGA = (!pi*L^2)/(AU^2.0)	;Steradians
	theta = 80.0*!dtor
	exp_freq = (dindgen(100)*(10.0 - 8.0)/99.0) + 8.0
	freq = 10.0^exp_freq

	
	delta = 6.0 	;electron sectral index
	exp1 = -0.52*delta
	exp2 = -0.43 + 0.64*delta
	exp3 = 1.22-0.9*delta

	eta = 3.3e-24 * 10.0^(exp1) * B * n_e * sin(theta)^exp2 * (freq/fB)^exp3 


	sfu = eta*L*OMEGA

	plot, freq, sfu, $
		/ylog, $
		/xlog, $
		;yr=[0.01, 100.0], $
		xtitle = 'Frequency (Hz)', $
		ytitle = 'Flux Density SFU'
	stop

END