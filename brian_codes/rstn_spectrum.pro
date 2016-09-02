pro plot_freq, times, freq, freqs, ind0, ind1, color, $
			freq_bg = freq_bg

	freq_bg = mean(freq[ind0:ind1])
	freq = freq - freq_bg

	outplot, times, smooth(freq, 5), color=color
	;xyouts, 0.1, 0.3-i/50.0, freqs+' MHz', color=color, /normal


END


pro rstn_spectrum
	
	window, 0
	set_line_color
	!p.charsize = 1.5

	t0 = anytim('2014-sep-01T10:45:00', /utim)
	tbg = anytim('2014-sep-01T10:55:00', /utim)
	t1 = anytim('2014-sep-01T11:15:00', /utim)

	restore,'~/Data/2014_sep_01/RSTN_daily_san-vito_2014_09_01.sav', /verb, $
			restored_objects = restored

	freqs = ['245', '410', '610', '1415', '2695', '4995', '8800', '15400']
	times = anytim(rstn_time, /utim)
	
	index_start = (where(times ge t0))[0]
	index_bg = (where(times ge tbg))[0]

	freq_1415 = freq_1415 - mean(freq_1415[index_start:index_bg])

	utplot, times, smooth(freq_1415, 5), $
			/xs, $
			/ys, $
			xr = [t0,t1], $
			yr = [1, 200], $
			ytitle = 'Flux density (SFU)', $
			/ylog


	;--------------------------------;		


	;plot_freq, times, freq_245, '245', index_start, index_bg, 2, freq_bg = bg_245
	;plot_freq, times, freq_410, '410', index_start, index_bg, 3, freq_bg = bg_410	
	;plot_freq, times, freq_610, '610', index_start, index_bg, 4, freq_bg = bg_610	
	plot_freq, times, freq_1415, '1415', index_start, index_bg, 5, freq_bg = bg_1415	
	plot_freq, times, freq_2695, '2695', index_start, index_bg, 6, freq_bg = bg_2695
	plot_freq, times, freq_4995, '4995', index_start, index_bg, 10, freq_bg = bg_4995	
	;plot_freq, times, freq_8800, '8800', index_start, index_bg, 6, freq_bg = bg_8800	

	stop

	legend, ['245', '410', '610', '1415', '2695'], $
			color = [2,3,4,5,6], $
			linestyle = [0,0,0,0,0], $
			box=0, $
			/top, $
			/left


	window, 1
	
	t0 = anytim('2014-sep-01T11:01:00', /utim)
	t1 = anytim('2014-sep-01T11:04:00', /utim)
	index_start = where(times ge t0)
	index_stop = where(times ge t1)

	for i=index_start[0], index_stop[0] do begin



		fluxes = [freq_245[i], $;- bg_245,  $
				  freq_410[i], $; - bg_410, $
				  freq_610[i], $; - bg_610, $
				  freq_1415[i], $; - bg_1415, $
				  freq_2695[i]] ; - bg_2695]    ; , freq_4995[i], freq_8800[i]];, freq_15400[i]]

		;print, fluxes		  

		freq_vals = float(['245', '410', '610', '1415', '2695'])




		plot, freq_vals, fluxes, $
				/xlog, $
				/ylog, $
				xtitle = 'Frequency (MHz)', $
				ytitle = 'Flux (SFU)', $
				yr = [0.1, 100], $ 
				linestyle = 1, $
				title = anytim(times[i], /cc)

		oplot, freq_vals, fluxes, $
				psym=1, $
				symsize=2

		spec_index = ( alog10(fluxes[4]*1e-22) - alog10(fluxes[3]*1e-22) )/( alog10(freq_vals[1]*1e6) - alog10(freq_vals[0]*1e6) )		
		print, spec_index

		STOP
	end


	STOP

END