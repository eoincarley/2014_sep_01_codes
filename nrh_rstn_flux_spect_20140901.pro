pro nrh_rstn_flux_spect_20140901

	; Code to construct flux density spectrum throughout time
	; RSTN here is from the San-Vito site.
	;----------------------------------------;
	;				NRH Flux
	;
	window, 0, xs=700, ys=700
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


	!p.charsize=1.5
	!p.thick=1
	pos = [0.15, 0.15, 0.88, 0.88]

	rstn_folder = '~/Data/2014_sep_01/radio/rstn/'
	rstn_file = findfile(rstn_folder+'*san*.sav')
	restore, rstn_file[0], /verb
	rstn_times = anytim(rstn_time, /utim)

	time0 = anytim('2014-09-01T10:55:00', /utim)
	time1 = anytim('2014-09-01T11:04:30', /utim)

	time0bg = anytim('2014-09-01T10:53:00', /utim)
	time1bg = anytim('2014-09-01T10:56:00', /utim)

	backgnd_1415 = mean(freq_1415[where(rstn_times ge time0bg and rstn_times le time1bg)])
	backgnd_2695 = mean(freq_2695[where(rstn_times ge time0bg and rstn_times le time1bg)])
	backgnd_4995 = mean(freq_4995[where(rstn_times ge time0bg and rstn_times le time1bg)])

	freq_1415 = freq_1415[where(rstn_times ge time0 and rstn_times le time1)]
	freq_2695 = freq_2695[where(rstn_times ge time0 and rstn_times le time1)]
	freq_4995 = freq_4995[where(rstn_times ge time0 and rstn_times le time1)]
	rstn_times = rstn_times[where(rstn_times ge time0 and rstn_times le time1)]

	freq_1415 = freq_1415-backgnd_1415
	freq_2695 = freq_2695-backgnd_2695
	freq_4995 = freq_4995-backgnd_4995
	
	;freq_1415 = freq_1415 + abs(mean(freq_1415[0:150]))		; This correction factor needs to be added to the background to make the 
	;freq_2695 = freq_2695 + abs(mean(freq_2695[0:150]))		; pre-event values sit at zero. No longer applied. Chose better background
	;freq_4995 = freq_4995 + abs(mean(freq_4995[0:150]))		; values, closer to the event.

	smoothing = 20
	freq_1415 = smooth(freq_1415, smoothing, /edge_mirror)
	freq_2695 = smooth(freq_2695, smoothing, /edge_mirror)
	freq_4995 = smooth(freq_4995, smoothing, /edge_mirror)

	set_line_color
	utplot, rstn_times, freq_1415, $
			/xs, $
			/ys, $
			;/ylog, $
			ytitle='SFU (bgnd sub)', $
			yr=[-5, 70], $
			xr=anytim(['2014-09-01T10:55:30', '2014-09-01T11:04:10'], /utim)

	outplot, rstn_times, freq_2695, color=5				
	outplot, rstn_times, freq_4995, color=6		
	outplot, [rstn_times[0], rstn_times[n_elements(rstn_times)-1]], [0, 0], color=1, thick=1, linestyle=2			

	rstn_freq = [1415., 2695., 4995.]
	rstn_flux = [[freq_1415], [freq_2695], [freq_4995]]

	nrh_rstn_flux = {name:'nrh_rstn_flux', $
					 nrh_times:nrh_times, $
					 nrh_freq:nrh_freq, $
					 nrh_flux:nrh_flux, $
					 rstn_times:rstn_times, $
					 rstn_freq:rstn_freq, $
					 rstn_flux:rstn_flux }
				 
	;save, nrh_rstn_flux, filename='~/Data/2014_sep_01/radio/nrh_rstn_flux_20140901.sav'				 


END