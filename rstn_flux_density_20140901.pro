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

	; Plot San Vito and Sag Hill together

	loadct, 0
	!p.charsize=1.0
	!p.thick=1
	pos = [0.15, 0.15, 0.88, 0.88]

	rstn_folder = '~/Data/2014_sep_01/radio/rstn/'
	rstn_file = findfile(rstn_folder+'*san-vito*.sav')

	time0 = anytim('2014-09-01T10:50:00', /utim)
	time1 = anytim('2014-09-01T11:13:00', /utim)
	
	time0bg = anytim('2014-09-01T10:00:00', /utim)
	time1bg = anytim('2014-09-01T10:50:00', /utim)
	
	date_string = time2file(time0, /date)

	restore, rstn_file[0], /verb
	rstn_time = anytim(rstn_time, /utim)

	freq_1415 = freq_1415[where(rstn_time ge time0 and rstn_time le time1)]
	freq_2695 = freq_2695[where(rstn_time ge time0 and rstn_time le time1)]
	freq_4995 = freq_4995[where(rstn_time ge time0 and rstn_time le time1)]
	rstn_time = rstn_time[where(rstn_time ge time0 and rstn_time le time1)]

	smoothing = 10
	freq_1415 = smooth(freq_1415, smoothing, /edge_mirror)
	freq_2695 = smooth(freq_2695, smoothing, /edge_mirror)
	freq_4995 = smooth(freq_4995, smoothing, /edge_mirror)

	if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/rstn_flux_20140901.eps'

	set_line_color
	utplot, rstn_time, freq_1415, $
			/xs, $
			/ys, $
			;/ylog, $
			yr=[10, 150], $
			xr=[time0, time1], $
			thick=5, $
			color=6, $
			ytitle='Flux density (SFU)', $
			pos=pos
		
	outplot, rstn_time, freq_2695, color=7, thick=4				
	outplot, rstn_time, freq_4995, color=4, thick=4		
	outplot, [rstn_time[0], rstn_time[n_elements(rstn_time)-1]], [0, 0], color=1, thick=1, linestyle=2			
	

	index_max0 = where(freq_1415 eq max(freq_1415))
	index_max1 = where(freq_2695 eq max(freq_2695))
	index_max2 = where(freq_4995 eq max(freq_4995))

	;-----------------------------------------------;
	;
	;			    Now do Sag Hill
	;	
	rstn_folder = '~/Data/2014_sep_01/radio/rstn/'
	rstn_file = findfile(rstn_folder+'*sag-hill*.sav')
	restore, rstn_file[0], /verb
	rstn_times = anytim(rstn_time, /utim)

	time0 = anytim('2014-09-01T10:50:00', /utim)
	time1 = anytim('2014-09-01T11:13:00', /utim)
	freq_610 = freq_610[where(rstn_times ge time0 and rstn_times le time1)]
	rstn_times = rstn_times[where(rstn_times ge time0 and rstn_times le time1)]

	smoothing = 2
	freq_610 = smooth(freq_610, smoothing, /edge_mirror)
	outplot, rstn_times, freq_610, color=9, thick=5, linestyle=2		



	legend, ['RSTN Sag-Hill 615 MHz', 'RSTN San-Vito 1415 MHz', 'RSTN San-Vito 2695 MHz', 'RSTN San-Vito 4995 MHz'], $
				linestyle = [2, 0, 0, 0], $
				color=[9, 6, 7, 4], $
				thick=[4, 4, 4, 4], $
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