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

pro nrh_src_pos_20140901, calc_speed=calc_speed

	; This needs a map in the active X-window. For example, run aia_imgs_20140901.pro first
	
	loadct, 0, /silent
	nrh_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	cd, nrh_folder
	if keyword_set(postscript) then begin
		setup_ps, '~/nrh_source_motion.eps'
	endif else begin
	;	window, 0, xs=900, ys=900, retain=2
	;	!p.charsize=1.5
	endelse	
	
	
	source_prop_files = findfile(nrh_folder+'*src_properties.sav')	; Created with nrh_choose_centroid.pro
	image_file = findfile('*.fts')
	AU = 149e6	;  km

	;---------------------------------;
	;		First plot the image
	;
	time0 = anytim('2014-09-01T11:01:30', /utim)
	time1 = anytim('2014-09-01T11:10:00', /utim)
	date_string = time2file(time0, /date)
	t0str = anytim(time0, /yoh, /trun, /time_only)

	read_nrh, image_file[8], $
			  nrh_hdr, $
			  nrh_data, $
			  hbeg=t0str;, $ 
			  ;hend=t1str
			
	index2map, nrh_hdr, nrh_data, $
			   nrh_map  
				
	nrh_str_hdr = nrh_hdr
	nrh_times = nrh_hdr.date_obs
	freq = nrh_hdr.FREQ		

	;------------------------------------;
	;			Plot Total I
	;
	;data = nrh_map.data
	;data[*] = 240
	;nrh_map.data = data
	;FOV = [15, 15]
	;CENTER = [-1100, 400]

	;plot_map, nrh_map, $
	;	fov = FOV, $
	;	center = CENTER, $
	;	dmin = 0, $
	;	dmax = 300, $
	;	title=' ';, $
	;	pos = [0.1, 0.15, 0.8, 0.95]
		  
	;plot_helio, nrh_times, $
	;	/over, $
	;	gstyle=1, $
	;	gthick=3.0, $
	;	gcolor=1, $
	;	grid_spacing=15.0

	;-----------------------------------;
	;	  Now plot source positions
	;
	symb = [4,5,6,7, 7, 7]
	freq_index = ([0, 5, 7])	;[0,1,2,3,4,5,6,7,8]	
	color_chart = [62, 53, 49]			;[0,1,2,3,4,5,6,7,8] 

	for k=0, n_elements(freq_index)-1 do begin ;n_elements(source_prop_files)-1,2 do begin
		
		loadct, color_chart[k]
		reverse_ct
		

		restore, source_prop_files[freq_index[k]]
		xarcs = xy_arcs_struct.x_max_fit
		yarcs = xy_arcs_struct.y_max_fit
		times = anytim(xy_arcs_struct.times, /utim)
		indices = where(times ge time0 and times le time1)
		xarcs = xarcs[indices]
		yarcs = yarcs[indices]
		xarcs = xarcs[where(xarcs gt -1600 and xarcs lt -800)]
		yarcs = yarcs[where(xarcs gt -1600 and xarcs lt -800)]

		xarcs = xarcs[where(yarcs gt 100 and yarcs lt 900)]
		yarcs = yarcs[where(yarcs gt 100 and yarcs lt 900)]


		ncols = n_elements(xarcs)
		colors = findgen(ncols)*(170.-20.)/(ncols-1)+20.

		for i = 0, ncols-1 do begin
			plots, xarcs[i], yarcs[i], color=colors[i], psym=symb[k], symsize=0.8, thick=4
			;plots, xarcs, yarcs, color=colors[i]
		endfor
		print, xy_arcs_struct.freq
	endfor	

	set_line_color
	symb = [2,2,2,2,2,4,5,6,7, 7, 7]
	freq_index =  ([0, 5, 7])	;[0,1,2,3,4,5,6,7,8]	
	colors = [3, 4, 5]
	for k=0, n_elements(freq_index)-1 do begin ;n_elements(source_prop_files)-1,2 do begin
		
		set_line_color
		restore, source_prop_files[freq_index[k]]
		xarcs = xy_arcs_struct.x_max_fit
		yarcs = xy_arcs_struct.y_max_fit
		times = anytim(xy_arcs_struct.times, /utim)
		indices = where(times ge time0 and times le time1)
		xarcs = xarcs[indices]
		yarcs = yarcs[indices]
		xarcs = xarcs[where(xarcs gt -1600 and xarcs lt -800)]
		yarcs = yarcs[where(xarcs gt -1600 and xarcs lt -800)]

		xarcs = xarcs[where(yarcs gt 100 and yarcs lt 900)]
		yarcs = yarcs[where(yarcs gt 100 and yarcs lt 900)]

		ncols = n_elements(xarcs)

		xcm = total(xarcs)/n_elements(xarcs)
		ycm = total(yarcs)/n_elements(yarcs)
		plotsym, 0, /fill
		plots, xcm, ycm, color=1, psym=8, symsize=1.5, thick=6
		plots, xcm, ycm, color=colors[k], psym=8, symsize=1.2, thick=6
		;plots, xcm, ycm, color=colors[k], psym=8, symsize=1.8, thick=6

		print, xy_arcs_struct.freq
	endfor	

	;if keyword_set(postscript) then device, /close
	;set_plot, 'x'


	if keyword_set(calc_speed) then begin
		;-----------------------------------------------------------;
		;
		;				Source Speeds
		;
		freq_index = [0,1,2,3,4,5,6,7,8]	
		step=30		; This step size (or 30) produces a speed that mathces what it should be e.g., 
					; simply taking the first and last points as displacements and a time of 500 seconds gives ~360 km/s	

		window, 1, xs=600, ys=600
		loadct, 0			

		utplot, [times[0], times[n_elements(times)-1]], [0, 1e6], /xs, /ys, /nodata

		for k=0, n_elements(freq_index)-1 do begin ;n_elements(source_prop_files)-1,2 do begin
			
			restore, source_prop_files[freq_index[k]]
			xarcs = xy_arcs_struct.x_max_fit
			yarcs = xy_arcs_struct.y_max_fit
			times = anytim(xy_arcs_struct.times, /utim)
			indices = where(times ge time0 and times le time1)
			xarcs = xarcs[indices]
			yarcs = yarcs[indices]
			xarcs = xarcs[where(xarcs gt -1600 and xarcs lt -800)]
			yarcs = yarcs[where(xarcs gt -1600 and xarcs lt -800)]

			xarcs = xarcs[where(yarcs gt 100 and yarcs lt 900)]
			yarcs = yarcs[where(yarcs gt 100 and yarcs lt 900)]
								
			for i=0, n_elements(xarcs)-(step+1), step do begin
				
					;color = interpol(colors, tcolors, anytim(times[i], /utim))
					;plots, xarcs[i], yarcs[i], color=color, psym=sym, symsize=2.0
					;if i eq 0.0 or xarcs[i]*xarcs[i+1] lt 0.0 then xyouts, xarcs[i]+35.0, yarcs[i]+20.0, 'NRH '+string(freq, format='(I3)')+' MHz', /data, color=color
				
					x1 = xarcs[i]
					x2 = xarcs[i+step]
					y1 = yarcs[i]
					y2 = yarcs[i+step]
					dt = anytim(times[i+step], /utim) - anytim(times[i], /utim)

					displ_arcs = sqrt( (x2-x1)^2 + (y2-y1)^2 )
					displ_degs = displ_arcs/3600.0
					displ = AU*tan(displ_degs*!dtor)	; km

					if i eq 0 then begin
						displs = displ 
						times_tot = times[i] 
					endif else begin

						if times[i] gt times_tot[n_elements(times_tot)-1] then begin
							displs = [displs, displs[n_elements(displs)-1]+displ]
							times_tot = [times_tot, times[i]]
						endif
							
					endelse	
			
				;wait, 0.1
			endfor	 

			utplot, times_tot, displs, $
					ytitle='Displacement (km)', $
					linestyle=0, $
					xr=[times[0], times[n_elements(times)-1]], $
					yr=[0, 1e6], $
					/xs, $
					/ys, $
					/noerase

			tims_sec = anytim(times_tot, /utim) - anytim(times_tot[0], /utim)		
			result = linfit(tims_sec, displs, yfit=yfit)

			q = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]}, 3)
			;q(2).fixed = 1

			err = displs
			err[*] = 30.0*727. ;30 arcsecs is approx size of the source in the images. Multiple by 727 km (km per arcsec)
			start = [0, 200, 10]
			fit = 'p[2]*x^2 + p[1]*x + p[0]'			
			
			p = mpfitexpr(fit, tims_sec, displs, err, perror=perror, yfit=yfit, start);, parinfo=q)

			outplot, times_tot, yfit, linestyle=1

			tsim = (findgen(100)*( tims_sec[n_elements(tims_sec)-1] - tims_sec[0])/99.0 )+tims_sec[0]
			ysim = p[2]*tsim^2 + p[1]*tsim + p[0]
			speed_sim = (deriv(tsim, ysim))

			print, 'Frequency: '+string(XY_ARCS_STRUCT.freq)+' MHz'
			print, 'Initial speed: '+string(p[1]) +' '+ string(perror[1])
			print, 'Average speed:'+string(mean(speed_sim))
			
			if k eq 0 then speeds = mean(speed_sim) else speeds = [speeds, mean(speed_sim)]

		endfor
		print, speeds
		stop
	endif	
			


END