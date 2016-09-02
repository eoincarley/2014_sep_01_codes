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

pro nrh_orfees_flux_plot_20140901, postscript=postscript

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
		
		if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/nrh_orfees_flux_'+freq_string+'_20140901.eps'

		times = anytim(xy_arcs_struct.times, /utim)
		flux = anytim(xy_arcs_struct.flux_density, /utim)

		nrh_y_range = [0.5, 20.]
		utplot, times, smooth(flux, 5), $
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
				yr=[min(orfees_flux), min(orfees_flux)], $
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

		legend, ['NRH '+freq_string+' MHz', 'Orfees '+orf_frequency_str+' MHz'], $
				linestyle = [0, 0], $
				color=[0, 5], $
				thick=[3,4], $
				box=0, $
				/bottom, $
				/right		

		if keyword_set(postscript) then begin
			device, /close
			;spawn,'open ~/Data/2014_sep_01/radio/'
			set_plot, 'x'
		endif	
	;endfor


END