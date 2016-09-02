pro aia_imgs_20140901


	window, xs=700, ys=700, retain = 2
	!p.charsize=1.5
	loadct, 0, /silent

	;-------------------------------------------------;
	;			Choose files unaffected by AEC
	;
	swap_folder = '~/Data/2014_sep_01/swap/'
	swap_files = findfile(swap_folder+'*lv1*.fits')
	mreadfits_header, swap_files, ind
	swap_times = anytim(ind.date_obs, /utim)


	aia_folder = '~/Data/2014_sep_01/sdo/193/'
	aia_files = findfile(aia_folder+'aia*.fits')
	mreadfits_header, aia_files, ind, only_tags='exptime'
	f = aia_files[where(ind.exptime gt 1.)]

	tstart = anytim('2014-09-01T11:01:20')
	tend   = anytim('2014-09-01T11:20:00')

	ratio_step = 5
	mreadfits_header, f, ind
	aia_files = f[where(anytim(ind.date_obs, /utim) ge tstart)]

	FOV = [25.0, 25.0]
	CENTER = [-1100.0, 400.0]

	FOR i=0, n_elements(aia_files)-1 DO BEGIN


		aia_prep, aia_files[i], -1, he_aia_pre, img_pre, /uncomp_delete, /norm
        aia_prep, aia_files[i+ratio_step], -1, he_aia, img, /uncomp_delete, /norm	

		iscaled_img = smooth(img, 6)/smooth(img_pre, 6)
        undefine, img
        undefine, img_pre
        iscaled_img = iscaled_img ;> (0.5) < 1.3 ;    ;0.80, 1.5 for ratio image	


        ;--------------------------------------;
		;              SWAP Data               ;
		;--------------------------------------;    
		index = closest(swap_times, anytim(he_aia.date_obs, /utim))
		mreadfits, swap_files[index-1], hdr_pre, data_pre
		mreadfits, swap_files[index], hdr, data
		
		;data_pre = (data_pre - mean(data_pre))/stdev(data_pre)
		;data = (data - mean(data))/stdev(data)

		data_pre = smooth(data_pre, 3)
		data = smooth(data, 3)

		data_sub = data-data_pre 
		
		index2map, hdr, $
			data_sub, $
			swap_map


		plot_map, swap_map, $
			dmin = -1.0, $
			dmax = 	1.0, $
			fov = FOV, $
			center = CENTER

		
		;--------------------------------------;
		;		 	   Plot AIA			   	   ;
		;--------------------------------------;   	

		index2map, he_aia, $
			iscaled_img, $
			aia_map, $
			outsize = 2048			

		plot_map, aia_map, $
			dmin = 0.8, $
			dmax = 1.2, $
			/overlay, $
			composite=2

		plot_helio, he_aia.date_obs, $
			/over, $
			gstyle=0, $
			gthick=1.0, $	
			gcolor=255, $
			grid_spacing=15.0

		    	
STOP	 
	ENDFOR


END