pro dulk_gyro_spectrum

	window, 10
	delta = 4.0
	bb = 0.5	;G
	theta = 80.0 ;degrees
	nv = 1e11
	AU = 1.5e13		; cm
	rsun = 6.95e10 	; cm
	L = 2.0*rsun	; cm
	OMEGA = (!pi*L^2)/(AU^2.0)	;Steradians

	freq = (dindgen(100)*(10.0 - 1.)/99.0) + 1.
	;freq = 10.0^exp_freq;/1e9		;Frequency in GHz.
	flux = fltarr(n_elements(freq))

	for i = 0, n_elements(freq)-1 do begin
		dulk_gysy, delta, bb, theta, nv, freq[i], fi, rc, omega, tau
		flux[i] = fi
	endfor


	plot, freq, flux, $
		/ylog, $
		;/xlog, $
		;yr=[0.01, 100.0], $
		xtitle = 'Frequency (Hz)', $
		ytitle = 'Flux Density SFU'


	stop

END