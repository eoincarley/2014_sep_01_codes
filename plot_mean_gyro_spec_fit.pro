pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.3
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


pro plot_mean_gyro_spec_fit, parms=parms, postscript=postscript

	; Plot the avergae flux density data and the fit.


	cd,'~/idl/gyro/'
	restore, '~/Data/2014_sep_01/radio/mean_flux_density_sectrum.sav'
	flux = 10^flux_mean
	err = 10^flux_err_mean 

	if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/nrh_rstn_mean_spec_20140901.eps'

	anor=7.8966100e+30
	freq_model=10^interpol(alog10([0.01,20]*1e9),50)
	;freq_model = alog10(freq_model)
	rsun = 6.9e10	    ; cm
	Lradio = 0.45*rsun
	size_arcsec = Lradio/727e5 
	height_cm = Lradio
	Emin=9.0	


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
		yr = [1., 1e2], $
		xr=[1e2, 2e4], $
		thick=4, $
		;title=anytim(nrh_time, /cc), $
		xtitle='Frequency (MHz)', $
		ytitle='Flux Density (SFU)', $
		;/noerase, $
		color=1 

	oploterror, 10^freq/1e6, flux, err, psym=8, color=1

	;/////////// / / /
	;   These are the average values from the Monte Carlo analysis.

	if keyword_set(parms) then begin
		gyro, freq_model, flux_model, $
			bmag=parms[0], $
			nel=10^parms[1], $
			np=10^parms[2], $
			delta=parms[3], $	
			ener=[Emin, 10^parms[4]], $
			angle=45.0, $
			anor=anor, $
			size=size_arcsec, $
			hei=height_cm
	endif else begin	
		gyro, freq_model, flux_model, $
			bmag=5.5, $
			nel=2.7e6, $
			np=1.7e8, $
			delta=3.5, $	
			ener=[9.0, 6600.0], $
			angle=45.0, $
			anor=anor, $
			size=size_arcsec, $
			hei=height_cm, $
			alpha=raz
	endelse		

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
	xyouts, xpos, ypos, 'B = '+string(4.8, format='(f4.1)')+' G', /normal, color=charcol
	xyouts, xpos, ypos-yinc, 'N = '+string(2.4e7, format='(e7.1)')+' cm!U-3!N', /normal, color=charcol
	xyouts, xpos, ypos-yinc*2.0, 'n!L0!N = '+string(1.7e8, format='(e7.1)')+' cm!U-3!N', /normal, color=charcol
	xyouts, xpos, ypos-yinc*3.0, delta_sym+' = '+string(3.8, format='(f3.1)'), /normal, color=charcol
	xyouts, xpos, ypos-yinc*4.0, 'E!L0!N ='+ string(Emin, format='(I2)')+' keV', /normal, color=charcol
	xyouts, xpos, ypos-yinc*5.0, 'E!L1!N = '+ string(6500, format='(I4)')+' keV', /normal, color=charcol
	xyouts, xpos, ypos-yinc*6.2, 'Angle = '+string(45., format='(I2)')+deg_sym, /normal, color=charcol
	xyouts, xpos, ypos-yinc*7.2, 'Size!LPOS!N = '+string(0.45, format='(f4.2)')+' R!Lsun!N', /normal, color=charcol
	xyouts, xpos, ypos-yinc*8.5, 'Length!LLOS!N= '+string(0.45, format='(f4.2)')+' R!Lsun!N', /normal, color=charcol



stop
	if keyword_set(postscript) then begin
		device, /close
		spawn,'open ~/Data/2014_sep_01/radio/'
		set_plot, 'x'
	endif	

END	