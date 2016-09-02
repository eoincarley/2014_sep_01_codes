pro nrh_Tb_spect_plot_20140901

	!p.charsize=1.5
	loadct, 39
	window, 20, xs=600, ys=600
	restore, '~/Data/2014_sep_01/radio/nrh_rstn_flux_20140901.sav', /verb


	nrh_times = nrh_rstn_flux.nrh_times
	nrh_fluxes = nrh_rstn_flux.nrh_flux
	nrh_freq = nrh_rstn_flux.nrh_freq


	start_index = 4
	colors = (findgen(n_elements(nrh_times))*255)/(n_elements(nrh_times)-1)

	for i=0, n_elements(nrh_times)-1 do begin

		nrh_time = nrh_times[i]
		nrh_flux = alog10(nrh_fluxes[i, *])	;step through frequencies


	
	endfor

STOP

END	