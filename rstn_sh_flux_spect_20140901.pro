pro rstn_sh_flux_spect_20140901

	; Sagamore hill flux	
	;----------------------------------------;
	;				NRH Flux
	;
	nrh_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	nrh_files = findfile(nrh_folder+'*src_properties.sav')
		
	for i=0, n_elements(nrh_files)-1 do begin
		restore, nrh_files[i]
		if i eq 0 then nrh_times = anytim(xy_arcs_struct.times, /utim)
		freq = xy_arcs_struct.freq
		flux = smooth(xy_arcs_struct.flux_density, 30)
		if i eq 0 then nrh_freq = freq else nrh_freq = [nrh_freq, freq]
		if i eq 0 then nrh_flux = flux else nrh_flux = [ [nrh_flux], [flux]]
	endfor  	


	!p.charsize=1.0
	!p.thick=1
	pos = [0.15, 0.15, 0.88, 0.88]

	rstn_folder = '~/Data/2014_sep_01/radio/rstn/'
	rstn_file = findfile(rstn_folder+'*sag*.sav')
	restore, rstn_file[0], /verb
	rstn_times = anytim(rstn_time, /utim)

	time0 = anytim('2014-09-01T10:50:00', /utim)
	time1 = anytim('2014-09-01T11:04:30', /utim)

	time0bg = anytim('2014-09-01T10:53:00', /utim)
	time1bg = anytim('2014-09-01T10:55:00', /utim)

	backgnd_410 = mean(freq_410[where(rstn_times ge time0bg and rstn_times le time1bg)])
	backgnd_610 = mean(freq_610[where(rstn_times ge time0bg and rstn_times le time1bg)])
	backgnd_1415 = mean(freq_1415[where(rstn_times ge time0bg and rstn_times le time1bg)])
	backgnd_2695 = mean(freq_2695[where(rstn_times ge time0bg and rstn_times le time1bg)])
	backgnd_4995 = mean(freq_4995[where(rstn_times ge time0bg and rstn_times le time1bg)])
	backgnd_8800 = mean(freq_8800[where(rstn_times ge time0bg and rstn_times le time1bg)])
	backgnd_15400 = mean(freq_15400[where(rstn_times ge time0bg and rstn_times le time1bg)])

	freq_410 = freq_410[where(rstn_times ge time0 and rstn_times le time1)]
	freq_610 = freq_610[where(rstn_times ge time0 and rstn_times le time1)]
	freq_1415 = freq_1415[where(rstn_times ge time0 and rstn_times le time1)]
	freq_2695 = freq_2695[where(rstn_times ge time0 and rstn_times le time1)]
	freq_4995 = freq_4995[where(rstn_times ge time0 and rstn_times le time1)]
	freq_8800 = freq_8800[where(rstn_times ge time0 and rstn_times le time1)]
	freq_15400 = freq_15400[where(rstn_times ge time0 and rstn_times le time1)]
	rstn_times = rstn_times[where(rstn_times ge time0 and rstn_times le time1)]

	freq_410 = freq_410-backgnd_410
	freq_610 = freq_610-backgnd_610
	freq_1415 = freq_1415-backgnd_1415
	freq_2695 = freq_2695-backgnd_2695
	freq_4995 = freq_4995-backgnd_4995
	freq_8800 = freq_8800-backgnd_8800
	freq_15400 = freq_15400-backgnd_15400
	
	;freq_1415 = freq_1415 + abs(mean(freq_1415[0:150]))		; This correction factor needs to be added to the background to make the 
	;freq_2695 = freq_2695 + abs(mean(freq_2695[0:150]))		; pre-event values sit at zero. No longer applied. Chose better background
	;freq_4995 = freq_4995 + abs(mean(freq_4995[0:150]))		; values, closer to the event.

	smoothing = 10
	freq_410 = smooth(freq_410, smoothing, /edge_mirror)
	freq_610 = smooth(freq_610, smoothing, /edge_mirror)
	freq_1415 = smooth(freq_1415, smoothing, /edge_mirror)
	freq_2695 = smooth(freq_2695, smoothing, /edge_mirror)
	freq_4995 = smooth(freq_4995, smoothing, /edge_mirror)
	freq_8800 = smooth(freq_8800, smoothing, /edge_mirror)
	freq_15400 = smooth(freq_15400, smoothing, /edge_mirror)

	set_line_color
	utplot, rstn_times, freq_1415, $
			/xs, $
			/ys, $
			;/ylog, $
			yr=[-5, 70], $
			xr=[time0, time1]

	outplot, rstn_times, freq_410, color=2, linestyle=2		
	outplot, rstn_times, freq_610, color=3, linestyle=2		
	outplot, rstn_times, freq_1415, color=4, linestyle=2				
	outplot, rstn_times, freq_2695, color=5, linestyle=2					
	outplot, rstn_times, freq_4995, color=6, linestyle=2			
	;outplot, rstn_times, freq_8800, color=7, linestyle=2			
	;outplot, rstn_times, freq_15400, color=8, linestyle=2				
	outplot, [rstn_times[0], rstn_times[n_elements(rstn_times)-1]], [0, 0], color=1, thick=1, linestyle=2			

	rstn_freq = [610.0, 1415., 2695., 4995.]
	rstn_flux = [[freq_610], [freq_1415], [freq_2695], [freq_4995]]

	sh_rstn_flux = {name:'rstn_sh_flux', $
					 rstn_times:rstn_times, $
					 rstn_freq:rstn_freq, $
					 rstn_flux:rstn_flux }
				 
	save, sh_rstn_flux, filename='~/Data/2014_sep_01/radio/rstn_flux_sh_20140901.sav'				 


END