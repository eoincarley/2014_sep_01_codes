pro decay_time

	; To relate the radio emission decay time to the minimum energy
	; cut-off in the gyrosynchrotron spectrum.

	v = findgen(100)*(0.9-0.1)/99.0 + 0.1
	E = v
	for i=0, n_elements(E)-1 do E[i] = (rel_energy(v[i]))[0]

	t = (1e17*E^2.0)/(1.58e8*v*2.98e10)

	window, 0, xs=600, ys=600
	plot, v, t/60.0, $
		/xs, $
		/ys, $
		xtitle='Velocity (c)', $
		ytitle='Decay time (min)', $
		/ylog

	vel = interpol(v, t, 5.0*60.0)
	
	E0 = rel_energy(vel)	

stop
END
