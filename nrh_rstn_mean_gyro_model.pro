pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.2
   !p.thick=3
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=6, $
          ysize=6, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end


function paulo_gyro, freqs, params ;Bfield, Del, ener2, Ang

	; Use the  Gyrosynchrotron model (send the data to a C++ code).
	
	;/////////////////////////////////
	; These expressions were put here by Eoin Carley. 
	; To reduce the dynamic range of fitting paramaters
	;nel = 10^nel   
	;np = 10^np
	;energy[1] = 10^energy[1]
	;angle=angle*10.0
	;/////////////////////////////////
	COMMON source_dims, size_arcsec, height_cm, Emin

	rsun = 6.9e10	    ; cm
	Lradio = 0.45*rsun
	size_arcsec = Lradio/727e5 
	height_cm = Lradio
	Emin=9.0	

	f = 10^freqs
	gyro, f, flux_model, $
			bmag=params[0], $
			nel=10^params[1], $
			np=10^params[2], $
			delta=3.5, $	
			ener=[Emin, 10^params[3]], $
			angle=45.0, $
			anor=7.8e30, $
			size=size_arcsec, $
			hei=height_cm

	return, alog10(flux_model)

END	

pro nrh_rstn_mean_gyro_model, postscript=postscript

	; Adapdted fromt nrh_rstn_flux_spect_plot_20140901.pro

	COMMON source_dims	; To pass to function above.

	cd,'~/idl/gyro/'
	!p.charsize=1.5
	window, 10, xs=600, ys=600, xpos=1950, ypos=1000, retain=2

	anor=7.8966100e+30
	freq_model=10^interpol(alog10( [0.01, 20]*1e9), 50)

	if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/gyro_fits/nrh_rstn_spectrum_gyro_model_20140901.eps'

	;//////////////////////////////////////////////////////
	;
	;    Setup params for fit structure. Set restrictions.
	;
	pi = replicate({value:0.D, step:0.D, fixed:0, limited:[0,0], $
		                      limits:[0.D,0]}, 4)	

	pi[0].step = 1	;Large step sizes in solution space for these params.
	pi[1].limited(0) = 1
	pi[1].limits(0) = 6.0
	pi[1].step = 0.1
	pi[2].step = 0.5
	;pi[3].step = 1
	;pi[4].step = 1
	;pi[5].step = 1
	;pi[5].limited(0) = 1
	;pi[5].limits(0) = 10.0	


	restore, '~/Data/2014_sep_01/radio/mean_flux_density_sectrum.sav'
	flux = 10^flux_mean
	err = 10^flux_err_mean 
	;err[4] = err[4] + 13.0
	;err[5] = err[5] + 6.0
	; Work in log space

	set_line_color
	PLOTSYM, 0
	;flux[4] = flux[4] - 13.
	;flux[5] = flux[5] - 6.
	plot, 10^freq/1e6, flux, $
		/ys, $
		/xs, $
		/ylog, $
		/xlog, $
		psym=8, $
		yr = [1.0, 1e2], $
		xr=[1e2, 2e4], $
		thick=4, $
		;title=anytim(nrh_time, /cc), $
		xtitle='Frequency (MHz)', $
		ytitle='Flux Density (SFU)', $
		;/noerase, $
		color=0 ;$	

	oploterror, 10^freq/1e6, flux, err, psym=8, color=0, /hibar
	err[4] = err[4] + 13.0
	err[5] = err[5] + 6.0
	oploterror, 10^freq/1e6, flux, err, psym=8, color=0, /lobar
	;-----------------------------------------------------------------;
	;			Switch to working with logged values so 
	;			fitting routines don't have to work with
	;			large dynamic ranges.
	;
	flux = alog10(flux)
	err = alog10(err)

	;/////////////////////////////////////////////////////
	; 			Use the model to produce a fit
	;
	start = [6.0, 7.2, 8.3, alog10(7000.0)];, 45.0]	;[p[0], p[1], p[2], p[3], p[4], p[5]]
	pi[*].value = start

	weights=flux
	p = mpfitfun('paulo_gyro', freq, flux, $
			weight=weights, parinfo=pi, bestnorm=bestnorm, dof=dof, perror=perror, errmsg=errmsg, maxiter=30)

	gyro, freq_model, flux_model, $
		bmag=p[0], $
		nel=10^p[1], $
		np=10^p[2], $
		delta=3.5, $	
		ener=[Emin, 10^p[3]], $
		angle=45.0, $
		anor=anor, $
		size=size_arcsec, $
		hei=height_cm

	set_line_color
	oplot, freq_model/1e6, flux_model, thick=4, linestyle=0, color=5

	delta_sym = cggreek('delta')
	deg_sym = cgsymbol('deg')
	sun_sym = cgsymbol('sun')
	loadct, 0
	charcol=0
	xpos=0.67
	ypos=0.90
	yinc = 0.035
	!p.charsize=1.1
	xyouts, xpos, ypos, 'B = '+string(p[0], format='(f4.1)')+' G', /normal, color=charcol
	xyouts, xpos, ypos-yinc, 'N = '+string(10^p[1], format='(e7.1)')+' cm!U-3!N', /normal, color=charcol
	xyouts, xpos, ypos-yinc*2.0, 'n!L0!N = '+string(10^p[2], format='(e7.1)')+' cm!U-3!N', /normal, color=charcol
	xyouts, xpos, ypos-yinc*3.0, delta_sym+' = '+string(3.5, format='(f3.1)'), /normal, color=charcol
	xyouts, xpos, ypos-yinc*4.0, 'E!L0!N = '+ string(Emin, format='(I1)')+' keV', /normal, color=charcol
	xyouts, xpos, ypos-yinc*5.0, 'E!L1!N = '+ string(10^p[3], format='(I4)')+' keV', /normal, color=charcol
	xyouts, xpos, ypos-yinc*6.2, 'Angle = '+string(45., format='(I2)')+deg_sym, /normal, color=charcol
	xyouts, xpos, ypos-yinc*7.2, 'Src size = '+string(0.45, format='(f4.2)')+' R!Lsun!N', /normal, color=charcol
	xyouts, xpos, ypos-yinc*8.5, 'Src depth = '+string(0.45, format='(f4.2)')+' R!Lsun!N', /normal, color=charcol
		
	
	;////////////////////////////////////////////////////////



	if keyword_set(postscript) then begin
		device, /close
		spawn,'open ~/Data/2014_sep_01/radio/'
		set_plot, 'x'
	endif	
stop
	x2png, '~/Data/2014_sep_01/radio/gyro_fits/poisson_weight_'+string(i, format='(I03)')+'.png'
	;wait, 1.0	


STOP
END	