pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.1
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


pro rstn_flux_density_20140901, postscrip=postscript

	loadct, 0
	!p.charsize=1.0
	!p.thick=1
	pos = [0.15, 0.15, 0.88, 0.88]

	rstn_folder = '~/Data/2014_sep_01/radio/rstn/'
	rstn_file = findfile(rstn_folder+'*.sav')

	time0 = anytim('2014-09-01T10:50:00', /utim)
	time1 = anytim('2014-09-01T11:13:00', /utim)
	
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
	;freq_1415 = freq_1415-backgnd_1415
	;freq_2695 = freq_2695-backgnd_2695
	;freq_4995 = freq_4995-backgnd_4995
	
	;freq_1415 = freq_1415 + abs(mean(freq_1415[0:100]))
	;freq_2695 = freq_2695 + abs(mean(freq_2695[0:100]))
	;freq_4995 = freq_4995 + abs(mean(freq_4995[0:100]))

	smoothing = 10
	freq_1415 = smooth(freq_1415, smoothing, /edge_mirror)
	freq_2695 = smooth(freq_2695, smoothing, /edge_mirror)
	freq_4995 = smooth(freq_4995, smoothing, /edge_mirror)
	;freq_8800 = smooth(freq_8800-backgnd_8800, smoothing, /edge_mirror)

	if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/rstn_flux_20140901.eps'

	set_line_color
	utplot, rstn_time, freq_1415, $
			/xs, $
			/ys, $
			;/ylog, $
			yr=[40, 150], $
			xr=[time0, time1], $
			thick=5, $
			color=6, $
			ytitle='Flux density (SFU)', $
			pos=pos

	;outplot, rstn_time, freq_610, color=7, thick=4					
	outplot, rstn_time, freq_2695, color=7, thick=4				
	outplot, rstn_time, freq_4995, color=4, thick=4		
	outplot, [rstn_time[0], rstn_time[n_elements(rstn_time)-1]], [0, 0], color=1, thick=1, linestyle=2			
	;outplot, rstn_time, freq_8800, color=9, thick=4			

	index_max0 = where(freq_1415 eq max(freq_1415))
	index_max1 = where(freq_2695 eq max(freq_2695))
	index_max2 = where(freq_4995 eq max(freq_4995))

	legend, ['RSTN 1415 MHz', 'RSTN 2695 MHz', 'RSTN 4995 MHz'], $
				linestyle = [0, 0, 0], $
				color=[6, 7, 4], $
				thick=[4, 4, 4], $
				box=0, $
				/top, $
				/left		

	if keyword_set(postscript) then begin
		device, /close
		spawn,'open ~/Data/2014_sep_01/radio/'
		set_plot, 'x'
	endif					


	print, 'Time of 1415 max: '+anytim(rstn_time[index_max0], /cc)+' UT'
	print, 'Time of 2695 max: '+anytim(rstn_time[index_max1], /cc)+' UT'
	print, 'Time of 4995 max: '+anytim(rstn_time[index_max2], /cc)+' UT'


STOP
END