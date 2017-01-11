pro aia_c2_nrh_swap_20140901


	window, xs=1000, ys=1000, retain = 2
	!p.charsize=1.5

	;-------------------------------------------------;
	;			Choose files unaffected by AEC
	;

	c2_folder = '~/Data/2014_sep_01/lasco/C2/L1/'
	c2_files = findfile(c2_folder+'*.fts')
	mreadfits_header, c2_files, ind
	c2_times = anytim(ind.date_obs, /utim)

	swap_folder = '~/Data/2014_sep_01/swap/'
	swap_files = findfile(swap_folder+'*lv1*.fits')
	mreadfits_header, swap_files, ind
	swap_times = anytim(ind.date_obs, /utim)


	aia_folder = '~/Data/2014_sep_01/sdo/193/'
	aia_files = findfile(aia_folder+'aia*.fits')
	mreadfits_header, aia_files, ind, only_tags='exptime'
	f = aia_files[where(ind.exptime gt 1.)]

	tstart = anytim('2014-09-01T11:03:30')
	tend   = anytim('2014-09-01T11:20:00')

	ratio_step = 5
	mreadfits_header, f, ind
	aia_files = f[where(anytim(ind.date_obs, /utim) ge tstart)]

	FOV = [55.0, 55.0]
	CENTER = [-1600.0, 400.0]

	FOR i=0, n_elements(aia_files)-1 DO BEGIN

		loadct, 0, /silent
		aia_prep, aia_files[i], -1, he_aia_pre, img_pre, /uncomp_delete, /norm
        aia_prep, aia_files[i+ratio_step], -1, he_aia, img, /uncomp_delete, /norm	

		iscaled_img = smooth(img, 6)/smooth(img_pre, 6)
        undefine, img
        undefine, img_pre
        iscaled_img = iscaled_img ;> (0.5) < 1.3 ;    ;0.80, 1.5 for ratio image	


        ;--------------------------------------;
		;              C2 Data                 ;
		;--------------------------------------;    

        index = closest(c2_times, anytim(he_aia.date_obs, /utim))
	    img = lasco_readfits(c2_files[index], c2hdr)
	    mask = lasco_get_mask(c2hdr)
	    ;img = img*mask
	   	pre = lasco_readfits(c2_files[index-1], c2hdr_pre)
	    ;pre = pre*mask

	    ;img_hf = img - smooth(img, 10)
	    img = img ;+ img_hf*0.5

	    ;img = img - 100.0

	    imgbs = alog10(img) - alog10(pre) 
	    c2map = make_map(imgbs)
	    c2map.dx = 11.9
	    c2map.dy = 11.9
	    c2map.xc = 14.4704
	    c2map.yc = 61.2137


        ;--------------------------------------;
		;              SWAP Data               ;
		;--------------------------------------;    
		index = closest(swap_times, anytim(he_aia.date_obs, /utim))
		mreadfits, swap_files[index-1], hdr_pre, data_pre
		mreadfits, swap_files[index], hdr, data
		
		;data_pre = (data_pre - mean(data_pre))/stdev(data_pre)
		;data = (data - mean(data))/stdev(data)

		;data_pre = smooth(data_pre, 3)
		;data = smooth(data, 3)


		data = (data - data_pre);/10.0


		data = disk_nrgf_swap(data, hdr, 0, 0)
		data = filter_image(data/10.0, fwhm=20)
    	index2map, hdr, data, swap_map

		map_new = merge_map(c2map, swap_map, /add, use_min=0)	

		plot_map, map_new, $
			 dmin = -0.15, $
			 dmax = 0.2, $
			 fov = FOV, $
			 center = CENTER

		print, c2hdr.date_obs
		print, hdr.date_obs	


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

		xyouts, 0.17, 0.82, 'AIA 193A '+he_aia.date_obs, /normal, charthick=7.0, charsize=2.5, color=0	
		xyouts, 0.17, 0.82, 'AIA 193A '+he_aia.date_obs, /normal, charthick=2.0, charsize=2.5



		oplot_nrh_on_three_color_20140901, he_aia.date_obs;, /back

		;set_line_color
		;restore, '/Users/eoincarley/Data/2014_sep_01/xy_cme_front_20140901.sav'
		;plots, xpoints, ypoints, /data, color=3

		;restore, '/Users/eoincarley/Data/2014_sep_01/xy_cme_front2_20140901.sav'
		;plots, xpoints, ypoints, /data, color=5, thick=3
		    	
STOP	 
		;nrh_src_pos_20140901

	ENDFOR


END