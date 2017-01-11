pro aia_nrh_imgs_20140901

	;NRH and AIA composite images for 2014 Sep 01 event


	window, xs=1000, ys=1000, retain = 2
	!p.charsize=1.5

	;-------------------------------------------------;
	;			Choose files unaffected by AEC
	;
	aia_folder = '~/Data/2014_sep_01/sdo/211/'
	aia_files = findfile(aia_folder+'aia*.fits')
	mreadfits_header, aia_files, ind, only_tags='exptime'
	f = aia_files[where(ind.exptime gt 1.)]

	tstart = anytim('2014-09-01T11:02:30')
	tend   = anytim('2014-09-01T11:20:00')

	ratio_step = 5
	mreadfits_header, f, ind
	aia_files = f[where(anytim(ind.date_obs, /utim) ge tstart) - ratio_step]


	FOR i=0, n_elements(aia_files)-(ratio_step+1) DO BEGIN

		;-------------------------------------------------;
		;				 	Plot AIA
		read_sdo, aia_files[i], $
			he_aia_pre, $
			data_aia_pre
		read_sdo, aia_files[i+ratio_step], $
			he_aia, $
			data_aia
		index2map, he_aia_pre, $
			smooth(data_aia_pre, 7)/he_aia_pre.exptime, $
			map_aia_pre, $
			outsize = 2048
		index2map, he_aia, $
			smooth(data_aia, 7)/he_aia.exptime, $
			map_aia, $
			outsize = 2048		

		;--------------------------------------------------;
		;				  Plot diff image	
		FOV = [45.0, 45.0]
		CENTER = [-500.0, 0.0]
		loadct, 1, /silent
		plot_map, diff_map(map_aia, map_aia_pre), $
			dmin = -25.0, $
			dmax = 25.0, $
			fov = FOV,$
			center = CENTER

		plot_helio, he_aia.date_obs, $
			/over, $
			gstyle=0, $
			gthick=1.0, $	
			gcolor=255, $
			grid_spacing=15.0

		    
		;-------------------------------------------------;
		;					PLOT NRH
		oplot_nrh_on_three_color,  he_aia.date_obs  


STOP	 
	ENDFOR


END