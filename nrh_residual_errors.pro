pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.2
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

function calculate_residuals, times, flux   

	;A lot of data gaps for 327 MHz and above
  	start_bad_data =anytim('2014-09-01T11:01:50', /utim)
	for i=0, n_elements(times)-1 do begin
		if times[i] gt start_bad_data and flux[i] le 3.0 or flux[i] gt 20 then begin
		  flux[i] = flux[i-1]
		endif
	endfor	

	
	utplot, times, flux, $
			/xs, $
			/ys, $
			yr=[1.0, 50], $
			;xr = [time0, time1], $
			xtickformat='(A1)', $
			xtitle=' ', $
			ytitle = 'Flux Desnity (SFU)', $
  		    /ylog, $
  		    position = [0.15, 0.38, 0.9, 0.9 ]

  	set_line_color	    
  	smoothing=50
  	outplot, times, smooth(flux, smoothing, /edge_mirror), color=5

  	flux_smooth = smooth(flux, smoothing, /edge_mirror)
  	residuals = (flux - flux_smooth)/flux_smooth

  	residuals = residuals*100.0
  	residuals[where(residuals ge 100.0 or residuals le -100.0)] = !values.f_nan	
  	remove_nans, residuals, junk, finite_positions

  	residuals = residuals[finite_positions]
  	times = times[finite_positions]

  	utplot, times, residuals, $
			/xs, $
			/ys, $
			yr=[-100, 100], $
			;xr = [time0, time1], $
			ytitle = 'Residuals (%)', $
  		    ;/ylog, $
  		    position = [0.15, 0.1, 0.9, 0.36 ], $
  		    /noerase, $
  		    psym=1, $
  		    thick=2

  	mean_resid = mean(residuals)
  	stdev_resid = stdev(residuals)
  	
  	thickness = 5
  	outplot, [times[0], times[n_elements(times)-1]], [mean_resid, mean_resid], color=3, thick=thickness
  	outplot, [times[0], times[n_elements(times)-1]], [stdev_resid, stdev_resid] + mean_resid, linestyle=2, color=3, thick=thickness  
  	outplot, [times[0], times[n_elements(times)-1]], -1.0*[stdev_resid, stdev_resid] + mean_resid, linestyle=2, color=3, thick=thickness   
  	outplot, [times[0], times[n_elements(times)-1]], 2.0*[stdev_resid, stdev_resid] + mean_resid, linestyle=1, color=3, thick=thickness  
  	outplot, [times[0], times[n_elements(times)-1]], -2.0*[stdev_resid, stdev_resid] + mean_resid, linestyle=1, color=3, thick=thickness  


  	print, 'Mean residuals (%): '+string(mean_resid)	    
  	print, 'Standard deviation of residuals (%): '+string(stdev_resid)	    

  	return, [mean_resid, stdev_resid]
END

pro nrh_residual_errors, postscript=postscript

	!p.charsize=1.0
	!p.thick=3
	;window, 10, xs=600, ys=600
	pos = [0.15, 0.12, 0.85, 0.88]


	nrh_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	nrh_files = findfile(nrh_folder+'*src_properties.sav')

	time0 = anytim('2014-09-01T11:00:00', /utim)
	time1 = anytim('2014-09-01T11:05:00', /utim)
	date_string = time2file(time0, /date)


	;----------------------------------------------;
	;				NRH flux plot
	;

	for i=0, n_elements(nrh_files)-1 do begin
		restore, nrh_files[6]
		freq_string = string(xy_arcs_struct.freq, format='(I3)')
		
		if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/nrh_flux_residuals'+freq_string+'_20140901.eps'

			times = anytim(xy_arcs_struct.times, /utim)
			flux = anytim(xy_arcs_struct.flux_density, /utim)
			resid_params=calculate_residuals(times, flux)	  
			if i eq 0 then nrh_resid_params = resid_params else nrh_resid_params = [ [[nrh_resid_params]], [[resid_params]]]
			if i eq 0 then freqs = xy_arcs_struct.freq else freqs = [freqs, xy_arcs_struct.freq]

			legend, ['NRH '+freq_string+' MHz', '30-spoint smooth'], $
					linestyle = [0, 0], $
					color=[0, 5], $
					thick=[3,4], $
					box=0, $
					pos=[0.50,0.45], $
					/normal

		if keyword_set(postscript) then device, /close
		set_plot, 'x'

	endfor

	resid_errs = {name:'resid_errors', $	
				  freqs:freqs, $
				  nrh_resid_params:nrh_resid_params}	
	save, resid_errs, filename=nrh_folder+'/nrh_residual_errors.sav', $
			description='Mean and standard deviation for residuals at each frequency. Built using nrh_residual_errors.pro.'


END