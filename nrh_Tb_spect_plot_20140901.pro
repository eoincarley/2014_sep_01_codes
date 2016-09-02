pro nrh_Tb_spect_plot_20140901

	!p.charsize=1.5
	loadct, 39
	window, 20, xs=600, ys=600
	nrh_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	nrh_files = findfile(nrh_folder+'*src_properties.sav')
		
	for i=0, n_elements(nrh_files)-1 do begin
		restore, nrh_files[i]
		if i eq 0 then nrh_times = anytim(xy_arcs_struct.times, /utim)
		freq = xy_arcs_struct.freq
		max_tb = xy_arcs_struct.TB
		if i eq 0 then nrh_freq = freq else nrh_freq = [nrh_freq, freq]
		if i eq 0 then nrh_max_tb_time = max_tb else nrh_max_tb_time = [ [nrh_max_tb_time], [max_tb]]
	endfor  

	start_index = 4
	colors = (findgen(n_elements(nrh_times))*255)/(n_elements(nrh_times)-1)
	nrh_freq =  alog10(nrh_freq*1e6)

	for i=0, n_elements(nrh_times)-1 do begin

		nrh_time = nrh_times[i]
		nrh_max_tb = alog10(nrh_max_tb_time[i, *])	;step through time


		max_tb = nrh_max_tb[4:n_elements(nrh_max_tb)-1]
		freq = nrh_freq[4:n_elements(nrh_freq)-1]

		if nrh_time gt anytim('2014-09-01T11:02:40', /utim) lt anytim('2014-09-01T11:03:00', /utim) then begin
			
			plot, freq, max_tb, $
				/ys, $
				yr=[5,9], $
				ytitle='log(frequency [Hz])', $
				xtitle='log(Brightness Temperature (K)', $
				psym=1
			
			result = linfit(freq, max_tb, yfit = yfit)
			oplot, freq, yfit, linestyle=2

			print, 'Spectral index: '+string(result[1])
				

		endif		
	
	endfor

STOP

END	