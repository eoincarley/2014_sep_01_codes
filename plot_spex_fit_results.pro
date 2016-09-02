pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.5
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=7, $
          ysize=7, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end

pro plot_spex_fit_results, postscript=postscript
	
	;
	;
	; Plot the results of fit of thermal plus thin-target model to
	; Fermi GBM spectrum between 11:58:30 and 11:04:40 UT
	; electron spectral index is main parameter of interest
	;
	;
	set_line_color
	if keyword_set(postscript) then begin
		setup_ps, '~/e_spec_ind_xray_radio.eps'
	endif else begin	
		window, 10, xs=800, ys=800
		!p.charsize=1.8
	endelse


	;-------------------------------------------;
	;		e spectral index from radio
	;
	results_txt_file = '/Users/eoincarley/data/2014_sep_01/fermi/opsex_fit_results.txt'
	readcol, results_txt_file, param, junk, result, errs
	e_spec_inds = result[where(param eq 4)]
	e_spec_errs = errs[where(param eq 4)]
	time0 = anytim('1-Sep-2014 10:58:31.007', /utime)
	delt = anytim('1-Sep-2014 10:58:35.103', /utime) - anytim('1-Sep-2014 10:58:31.007', /utime)
	times = dindgen(90)*delt + time0


	time_start = anytim('1-Sep-2014 10:59:30.000', /utime)
	time_stop = anytim('1-Sep-2014 11:03:30.000', /utime)
	indices = where(times gt time_start and times lt time_stop)

	times = times[indices]
	e_spec_inds = e_spec_inds[indices]
	e_spec_errs = e_spec_errs[indices]
	err_frac = e_spec_errs/e_spec_inds

	indices = where(err_frac lt 0.25)


	times = times[indices]
	e_spec_inds = e_spec_inds[indices]
	e_spec_errs = e_spec_errs[indices]

	utplot, times, e_spec_inds, $
			yr=[1, 5.5], $
			/ys, $	
			/xs, $
			psym=10, $
			color=0, $
			xtitle='Time (UT)', $
			ytitle='Non-thermal electron spectral index ('+cgGreek('delta')+')'

	;oploterror, times, e_spec_inds, e_spec_errs, psym=1		

	;-------------------------------------------;
	;		e spectral index from radio
	;
	radio_file = '~/data/2014_sep_01/fermi/e_spec_index_radio.sav'
	restore, radio_file, /verb

	e_spec_ind_radio = -1.1*(alpha_thin -1.2)
	e_spec_ind_errs = -1.1*(-1.0*scaled_errs -1.2)

	loadct, 0
	lower = e_spec_ind_radio - e_spec_ind_errs
	upper = e_spec_ind_radio + e_spec_ind_errs
	oband, alpha_thin_times, lower, upper, color=200

	set_line_color
	outplot, alpha_thin_times, e_spec_ind_radio, $
			 psym=10, $
			 color=5, $
			 thick=4


	;-------------------------------------------;
	;			Oplot x-ray again
	;		 
	loadct, 0
	outplot, times, e_spec_inds, psym=10, thick=4	
	oploterror, times, e_spec_inds, e_spec_errs, psym=1, color=100, thick=4;, /nohat

	set_line_color
	legend, ['X-ray (FERMI GBM), '+ cgGreek('delta') +'!L'+ cgGreek('mu') +', xray!N'+ ' = 3.1'+cgsymbol('+-')+'0.5', $
			 'Radio (NRH+RSTN), ' + cgGreek('delta') +'!L'+ cgGreek('mu') +', radio!N'+ ' = 3.3'+cgsymbol('+-')+'1.3'], $
			color=[0, 5], $
			linestyle=[0, 0], $
			box=0, $
			/top, $
			/left, $
			thick=4, $
			charsize=1.3

	if keyword_set(postscript) then device, /close
	set_plot, 'x'		

	print, 'Mean electron spectral index derived from radio: '+string(mean(e_spec_ind_radio))+' +/- '+string(mean(e_spec_ind_errs))
	print, 'Mean electron spectral index derived from X-ray: '+string(mean(e_spec_inds))+' +/- '+string(mean(e_spec_errs))


;**********************************************************;

	;----------------------------------------------;
	;	Get means of other params from the fit
	;
	EM = result[where(param eq 0)]	; cm^-3
	temp = result[where(param eq 1)]*1e3/8.6e-5	;K
	norm_factor = result[where(param eq 3)]	
	low_e = result[where(param eq 7)]	; keV

	;------------------------------;
	;  Ony those with small errors
	;------------------------------;
	EM_mean = mean( EM[indices] )
	temp_mean = mean( temp[indices] )
	norm_factor_mean = mean( norm_factor[indices] )
	low_e_mean = mean( low_e[indices] )

	print, 'Mean emission measure: '+string(EM_mean)
	print, 'Mean thermal temperature: '+string(temp_mean)
	print, 'Mean normalisation factor: '+string(norm_factor_mean)
	print, 'Mean low energey cut-off: '+string(low_e_mean)
	

STOP

END