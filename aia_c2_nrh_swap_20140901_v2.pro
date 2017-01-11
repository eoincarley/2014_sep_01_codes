pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.5
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=9, $
          ysize=8, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end

pro aia_c2_nrh_swap_20140901_v2, postscript=postscript

	
	if keyword_set(postscript) then begin
		setup_ps, '~/nrh_source_pos3.eps'
	endif else begin
		window, 0, xs=900, ys=900, retain=2
		!p.charsize=1.5
	endelse	

	;----------------------------------------------;
	;  C2 Data (Just to plot a plain background)   ;
	;----------------------------------------------;    

	c2_folder = '~/Data/2014_sep_01/lasco/C2/L1/'
	c2_files = findfile(c2_folder+'*.fts')
    img = lasco_readfits(c2_files[0], c2hdr)
    img[*] = 0.0
	img[0:(n_elements(img[*, 0])-1)/2.0, *] = 80.
	img[ (n_elements(img[*, 0])-50):(n_elements(img[*, 0])-1), *] = 255.

    c2map = make_map(img)
    c2map.dx = 11.9
    c2map.dy = 11.9
    c2map.xc = 14.4704
    c2map.yc = 61.2137


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

	tstart = anytim('2014-09-01T11:03:30')
	tend   = anytim('2014-09-01T11:20:00')

	ratio_step = 5
	mreadfits_header, f, ind
	aia_files = f[where(anytim(ind.date_obs, /utim) ge tstart)]

	FOV = [35.0, 35.0]
	CENTER = [-1100.0, 400.0]



	FOR i=0, n_elements(aia_files)-1 DO BEGIN


		loadct, 0, /silent
		aia_prep, aia_files[i], -1, he_aia_pre, img_pre, /uncomp_delete, /norm
        aia_prep, aia_files[i+ratio_step], -1, he_aia, img, /uncomp_delete, /norm	

		iscaled_img = smooth(img, 10)/smooth(img_pre, 10)
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
		data = (data - data_pre);/10.0


		data = disk_nrgf_swap(data, hdr, 0, 0)
		data = filter_image(data/10.0, fwhm=20)
    	index2map, hdr, data, swap_map
		

    	loadct, 0
    	plot_map, c2map, $
			fov = FOV, $
			center = CENTER, $
			title=' ', $
			xticklen=-0.02, $
			yticklen=-0.02




    	loadct, 0, /silent ;58, 64
    	;reverse_ct
		plot_map, swap_map, $
			dmin = -0.12, $
			dmax = 	0.25, $
			fov = FOV, $
			center = CENTER, $
			/noerase, $
			title=' ', $
			xticklen=-0.02, $
			yticklen=-0.02

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
			composite=2, $
			xticklen=-0.02, $
			yticklen=-0.02

		plot_helio, he_aia.date_obs, $
			/over, $
			gstyle=0, $
			gthick=1.0, $	
			gcolor=255, $
			grid_spacing=15.0


		;oplot_nrh_on_three_color_20140901, he_aia.date_obs;, /back
		set_line_color
		xyouts, 0.2, 0.82, 'AIA 193A '+anytim(he_aia.date_obs, /cc, /trun)+' UT', /normal, charsize=1.5, color=1 
		xyouts, 0.2, 0.79, 'SWAP 174A '+anytim(hdr.date_obs, /cc, /trun)+' UT', /normal, charsize=1.5, color=1 

		nrh_src_pos_20140901

		if keyword_set(postscript) then begin
			device, /close
		endif else begin	
			set_plot, 'x'
		endelse	

		print, 'AIA 193A '+he_aia.date_obs;, /normal, charthick=7.0, charsize=2.5, color=0	
		print, 'SWAP '+hdr.date_obs;, /normal, charthick=2.0, charsize=2.5

		STOP    	

	ENDFOR


END