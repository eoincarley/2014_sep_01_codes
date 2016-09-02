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

function calculate_residuals, times, flux, freq, yrange


	;----------------------------------------------;
	;				Orfees flux plot
	;
	orfees_folder='~/Data/2014_sep_01/radio/orfees/'
	time0=times[0]
	time1=times[n_elements(times)-1]
	restore, orfees_folder+'orf_20140901_bsubbed_minimum.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = reverse(orfees_struct.freq)
	t_index = where(orf_time gt time0 and orf_time lt time1)
	orf_time = orf_time[t_index]

	index = closest(orf_freqs, freq)
	orf_frequency_str = string(round(orf_freqs[index]), format='(I03)')
	orfees_flux = smooth(orf_spec[t_index, index], 3)

	set_line_color
	orfees_flux_range = [0.04, max(orfees_flux)*1.2]	;[min(orfees_flux), max(orfees_flux)*1.9]	;[0.04, max(orfees_flux)*1.3]
	utplot, orf_time, smooth(orfees_flux, 5), $
			/xs, $
			/ys, $
			/ylog, $
			xr = [time0, time1], $
			yr=orfees_flux_range, $;[min(orfees_flux), max(orfees_flux)*1.8], $
			xtitle = ' ', $
			XTICKFORMAT="(A1)", $
			YTICKFORMAT="(A1)", $
			linestyle=0, $
			xticklen=0.001, $
			yticklen=0.001, $
			/noerase, $
			/noyticks, $
			color=6, $
  		    position = [0.15, 0.38, 0.9, 0.9 ]


  	;-----------------------------------------------------;
  	;					NRH Plot
  	;	    
  	;A lot of data gaps for 327 MHz and above
  	;start_bad_data =anytim('2014-09-01T11:01:50', /utim)
	;for i=0, n_elements(times)-1 do begin
	;	if times[i] gt start_bad_data and flux[i] le 5.0 or flux[i] gt 20 then begin
	;	  flux[i] = flux[i-1]
	;	endif
	;endfor		    
	    
  	utplot, times, flux, $
			/xs, $
			/ys, $
			yr=yrange, $
			ytitle = ' ', $
			yticklen = 0.00001, $
  		    ytickformat='(A1)', $
			xtickformat='(A1)', $
			xtitle=' ', $
			/noerase, $
			/normal, $
			;ytitle = 'Flux Desnity (SFU)', $
  		    /ylog, $
  		    position = [0.15, 0.38, 0.9, 0.9 ]
  
  	set_line_color	    
  	smoothing=30
  	outplot, times, smooth(flux, smoothing, /edge_mirror), color=5, thick=6	    	    	    


	axis, yaxis=1, yr=orfees_flux_range, /ylog, $
		yticklen = -0.018, /ys, ytitle='Flux Density (Arbitrary Units)', color=6, charsize=1.0

  	axis, yaxis=0, yr=yrange, /ylog, yticklen = -0.018, /ys, ytitle='Flux Density (SFU)'




  	;-----------------------------------------------------;
  	;					Plot residuals
  	;
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

pro nrh_residual_errors_orfees, postscript=postscript

	; Same plots as nrh_residual_errors.pro but with Orfees included.

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
	restore, nrh_files[0]
	freq_string = string(xy_arcs_struct.freq, format='(I3)')
	
	if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/nrh_flux_residuals'+freq_string+'_orfees_20140901.eps'

		yrange=[0.1, 1000.]
		times = anytim(xy_arcs_struct.times, /utim)
		flux = anytim(xy_arcs_struct.flux_density, /utim)
		resid_params=calculate_residuals(times, flux, xy_arcs_struct.freq, yrange)	  


		legend, ['NRH '+freq_string+' MHz', 'NRH 30-point smooth', 'Orfees '+freq_string+' MHz'], $
				linestyle = [0, 0, 0], $
				color=[0, 5, 6], $
				thick=[3, 4, 3], $
				box=0, $
				pos=[0.45,0.48], $
				/normal, $
				charsize=1.0

	if keyword_set(postscript) then device, /close
	set_plot, 'x'


END