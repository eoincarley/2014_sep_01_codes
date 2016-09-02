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

pro rstn_flux_density_oplot_20140901

	loadct, 0
	!p.charsize=1.0
	!p.thick=1
	pos = [0.15, 0.15, 0.88, 0.88]

	rstn_folder = '~/Data/2014_sep_01/radio/rstn/'
	rstn_file = findfile(rstn_folder+'*.sav')

	time0 = anytim('2014-09-01T10:55:00', /utim)
	time1 = anytim('2014-09-01T11:05:00', /utim)
	
	time0bg = anytim('2014-09-01T10:00:00', /utim)
	time1bg = anytim('2014-09-01T10:50:00', /utim)
	
	date_string = time2file(time0, /date)

	restore, rstn_file[0], /verb
	rstn_time = anytim(rstn_time, /utim)

	;backgnd_time = rstn_time[where(rstn_time gt time0bg and rstn_time lt time1bg)]

	bg_sample0 = freq_1415[where(rstn_time ge time0bg and rstn_time le time1bg)]
	bg_sample1 = freq_2695[where(rstn_time ge time0bg and rstn_time le time1bg)]
	bg_sample2 = freq_4995[where(rstn_time ge time0bg and rstn_time le time1bg)]
	;bg_sample3 = freq_8800[where(rstn_time ge time0bg and rstn_time le time1bg)]


	freq_1415 = freq_1415[where(rstn_time ge time0 and rstn_time le time1)]
	freq_2695 = freq_2695[where(rstn_time ge time0 and rstn_time le time1)]
	freq_4995 = freq_4995[where(rstn_time ge time0 and rstn_time le time1)]
	;freq_8800 = freq_8800[where(rstn_time ge time0 and rstn_time le time1)]
	rstn_time = rstn_time[where(rstn_time ge time0 and rstn_time le time1)]


	backgnd_1415 = mean(bg_sample0)
	backgnd_2695 = mean(bg_sample1)
	backgnd_4995 = mean(bg_sample2)
	;backgnd_8800 = mean(bg_sample3)

	; Poisson error on the flux. Ds = s*(Ds_0/s_0), where s is measured flux and s_0 is background flux.
	; The Ds_0/s_0 term is equal to 1/sqrt(Dnu*t) where Dnu is bandwidth and t is integration time. This
	; is essentially the same as 1/sqrt(N) where n is number of samples.  
	;psoin_err_1415 = sqrt(2.)*( stdev(bg_sample0)/backgnd_1415 )	
	;psoin_err_2695 = sqrt(2.)*( stdev(bg_sample1)/backgnd_2695 )
	;psoin_err_4995 = sqrt(2.)*( stdev(bg_sample2)/backgnd_4995 )


	; Other than this the report that Pietro has states that the flux values are most likely within
	; 10% of the true value. There's no justification for this in the report, however.
	freq_1415 = freq_1415-backgnd_1415
	freq_2695 = freq_2695-backgnd_2695
	freq_4995 = freq_4995-backgnd_4995
	
	freq_1415 = freq_1415 + abs(mean(freq_1415[0:100]))
	freq_2695 = freq_2695 + abs(mean(freq_2695[0:100]))
	freq_4995 = freq_4995 + abs(mean(freq_4995[0:100]))

	smoothing = 10
	freq_1415 = smooth(freq_1415, smoothing, /edge_mirror)
	freq_2695 = smooth(freq_2695, smoothing, /edge_mirror)
	freq_4995 = smooth(freq_4995, smoothing, /edge_mirror)

	set_line_color
	outplot, rstn_time, freq_1415, color=6, thick=4;, $
			;/xs, $
			;/ys, $
			;/ylog, $
			;yr=[0.1, 100], $
			;xr=[time0, time1]

	outplot, rstn_time, freq_2695, smoothing, color=7, thick=4				
	outplot, rstn_time, freq_4995, smoothing, color=4, thick=4			

	index_max0 = where(freq_1415 eq max(freq_1415))
	index_max1 = where(freq_2695 eq max(freq_2695))
	index_max2 = where(freq_4995 eq max(freq_4995))

	print, 'Time of 1415 max: '+anytim(rstn_time[index_max0], /cc)+' UT'
	print, 'Time of 2695 max: '+anytim(rstn_time[index_max1], /cc)+' UT'
	print, 'Time of 4995 max: '+anytim(rstn_time[index_max2], /cc)+' UT'



END

pro nrh_orfees_rstn_flux_plot_20140901, postscript=postscript

	; Same as nrh_orfees_flux_plot_20140901.pro but now with RSTN added in.

	!p.charsize=1.0
	!p.thick=3
	pos = [0.15, 0.15, 0.88, 0.88]

	orfees_folder = '~/Data/2014_sep_01/radio/orfees/'
	nrh_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	nrh_files = findfile(nrh_folder+'*src_properties.sav')

	time0 = anytim('2014-09-01T11:00:00', /utim)
	time1 = anytim('2014-09-01T11:05:00', /utim)
	date_string = time2file(time0, /date)


	;----------------------------------------------;
	;				NRH flux plot
	;
	i=8
	;for i=0, n_elements(nrh_files)-1 do begin
		restore, nrh_files[i]
		freq_string = string(xy_arcs_struct.freq, format='(I3)')
		
		if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/nrh_orfees_rstn_flux_'+freq_string+'_20140901.eps'

		times = anytim(xy_arcs_struct.times, /utim)
		flux = anytim(xy_arcs_struct.flux_density, /utim)

		nrh_y_range = [0.1, 60.]
		utplot, times, flux, $
				/xs, $
				/ys, $
				yr=nrh_y_range, $
				xr = [time0, time1], $
				ytitle = ' ', $
				yticklen = 0.00001, $
	  		    ytickformat='(A1)', $
	  		    thick=5, $, 
	  		    /ylog, $
	  		    position = pos

	  	rstn_flux_density_oplot_20140901	    

		;----------------------------------------------;
		;				Orfees flux plot
		;
		restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
		orf_spec = orfees_struct.spec
		orf_time = orfees_struct.time
		orf_freqs = reverse(orfees_struct.freq)
		t_index = where(orf_time gt time0 and orf_time lt time1)
		orf_time = orf_time[t_index]
	 

		index = closest(orf_freqs, xy_arcs_struct.freq)
		orf_frequency_str = string(round(orf_freqs[index]), format='(I03)')
		orfees_flux = smooth(orf_spec[t_index, index], 3)
		;orfees_flux = orfees_flux/max(orfees_flux)

		;orfees_flux = 10^orfees_flux
		set_line_color

		utplot, orf_time, smooth(orfees_flux, 5), $
				/xs, $
				/ys, $
				/ylog, $
				xr = [time0, time1], $
				yr=[0.01, max(orfees_flux)], $
				xtitle = ' ', $
				XTICKFORMAT="(A1)", $
				YTICKFORMAT="(A1)", $
				linestyle=0, $
				xticklen=0.001, $
				yticklen=0.001, $
				/noerase, $
				/noyticks, $
				color=5, $
	  		    position = pos

	    
		axis, yaxis=1, yr=[min(orfees_flux), min(orfees_flux)], /ylog, yticklen = -0.018, /ys, ytitle='Flux Density (Arbitrary Units)', color=5

		axis, yaxis=0, yr=nrh_y_range, /ylog, yticklen = -0.018, /ys, ytitle='Flux Density (SFU)'	

		legend, ['NRH '+freq_string+' MHz', 'Orfees '+orf_frequency_str+' MHz', 'RSTN 1415 MHz', 'RSTN 2695 MHz', 'RSTN 4995 MHz'], $
				linestyle = [0, 0, 0, 0, 0], $
				color=[0, 5, 6, 7, 4], $
				thick=[3,4, 3, 3, 3], $
				box=0, $
				/bottom, $
				/right		

		if keyword_set(postscript) then begin
			device, /close
			spawn,'open ~/Data/2014_sep_01/radio/'
			set_plot, 'x'
		endif	
	;endfor


END