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

pro nrh_src_pos_20140901
	
	loadct, 0, /silent
	nrh_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	cd, nrh_folder
	if keyword_set(postscript) then begin
		setup_ps, '~/nrh_source_motion.eps'
	endif else begin
	;	window, 0, xs=900, ys=900, retain=2
	;	!p.charsize=1.5
	endelse	
	
	
	source_prop_files = findfile(nrh_folder+'*src_properties.sav')
	image_file = findfile('*.fts')
	AU = 149e6	;  km

	;---------------------------------;
	;		First plot the image
	;
	time0 = anytim('2014-09-01T11:01:30', /utim)
	time1 = anytim('2014-09-01T11:05:00', /utim)
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
	symb = [2,2,2,2,2,4,5,6,7, 7, 7]
	freq_index = reverse([0, 1, 5, 7])	;[0,1,2,3,4,5,6,7,8]	
	color_chart = [49,53,61,62]			;[0,1,2,3,4,5,6,7,8] 

	for k=0, n_elements(freq_index)-1 do begin ;n_elements(source_prop_files)-1,2 do begin
		
		loadct, color_chart[k]

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
		colors = findgen(ncols)*(255.-50.)/(ncols-1)+50.

		for i = 0, ncols-1 do begin
			plots, xarcs[i], yarcs[i], color=colors[i], psym=symb[k], symsize=0.8, thick=2
			;plots, xarcs, yarcs, color=colors[i]
		endfor


		print, xy_arcs_struct.freq
	endfor	

	symb = [2,2,2,2,2,4,5,6,7, 7, 7]
	freq_index = reverse([0, 1, 5, 7])	;[0,1,2,3,4,5,6,7,8]	
	colors = [5,4,7,3]
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
		plots, xcm, ycm, color=0, psym=8, symsize=2.5, thick=6
		plots, xcm, ycm, color=1, psym=8, symsize=2.0, thick=6
		plots, xcm, ycm, color=colors[k], psym=8, symsize=1.5, thick=6

		print, xy_arcs_struct.freq
	endfor	



END