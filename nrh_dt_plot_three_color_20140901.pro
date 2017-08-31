pro stamp_date, wave1, wave2, wave3
   set_line_color

   xpos_aia_lab = 0.17
   ypos_aia_lab = 0.83

   lbl_shift=0.003
   xyouts, xpos_aia_lab+lbl_shift, ypos_aia_lab+0.07, wave1, alignment=0, /normal, color = 1, charthick=5
   xyouts, xpos_aia_lab-lbl_shift, ypos_aia_lab+0.07, wave1, alignment=0, /normal, color = 1, charthick=5
   xyouts, xpos_aia_lab, ypos_aia_lab+0.07, wave1, alignment=0, /normal, color = 3, charthick=0.5
   
   xyouts, xpos_aia_lab+lbl_shift, ypos_aia_lab+0.035, wave2, alignment=0, /normal, color = 0, charthick=5
   xyouts, xpos_aia_lab-lbl_shift, ypos_aia_lab+0.035, wave2, alignment=0, /normal, color = 0, charthick=5
   xyouts, xpos_aia_lab, ypos_aia_lab+0.035, wave2, alignment=0, /normal, color = 4, charthick=2
   
   xyouts, xpos_aia_lab+lbl_shift, ypos_aia_lab, wave3, alignment=0, /normal, color = 0, charthick=5
   xyouts, xpos_aia_lab-lbl_shift, ypos_aia_lab, wave3, alignment=0, /normal, color = 0, charthick=5
   xyouts, xpos_aia_lab, ypos_aia_lab, wave3, alignment=0, /normal, color = 10, charthick=2

END

pro nrh_dt_plot_three_color_20140901, dtmap=dtmap, tmap=tmap, postscript=postscript, plot_map=plot_map

	;Code to plot the distance time maps from AIA

	!p.font = 0
	!p.charsize = 1.0
	loadct, 0
	;!p.charthick = 0.5

	folder = '~/Data/2014_sep_01/radio/nrh/dtmaps/'	;'~/Data/2014_Apr_18/sdo/'	;'~/Data/2015_nov_04/sdo/event1/'
	
	if keyword_set(postscript) then begin
		set_plot, 'ps'
		device, filename='~/nrh_dt_maps_20140901.eps', $
				/encapsulate, $
				/color, $ 
				/inches, $
				/helvetica, $
				bits_per_pixel=32, $
				xs=5, $
				ys=5
	endif else begin
		window, 0, xs=800, ys=800
	endelse

	min_scl = 100
	max_scl = 250
	;-------------------------------------------;
	;				Plot 171
	;
	freq_tag = ['327', '408', '432', '445']	; ['094', '131', '335']	
	cd, folder

	restore, 'nrh_'+freq_tag[0]+'_arc_dt_map.sav'
	t_a = dt_map_struct.time
	lindMm = dt_map_struct.distance	
	distt_a = dt_map_struct.dtmap 

	restore, 'nrh_'+freq_tag[1]+'_arc_dt_map.sav'
	t_b = dt_map_struct.time
	distt_b = dt_map_struct.dtmap 

	restore, 'nrh_'+freq_tag[2]+'_arc_dt_map.sav'
	t_c = dt_map_struct.time
	distt_c = dt_map_struct.dtmap 


	arrs = [n_elements(t_a), n_elements(t_b), n_elements(t_c)]
	val = max(arrs, t_max, subscript_min = t_min)
	n_array = [0,1,2]


	case t_min of
	  0: image_time = t_a
	  1: image_time = t_b
	  2: image_time = t_c
	endcase

	t_mid = n_array[where(n_array ne t_max and n_array ne t_min)]

	if t_min eq t_max then begin
	     max_tim = t_a
	     mid_tim = t_b
	     min_tim = t_c
	endif else begin
	  case t_max of
	     0: max_tim = t_a
	     1: max_tim = t_b
	     2: max_tim = t_c
	  endcase
	  case t_min of
	     0: min_tim = t_a
	     1: min_tim = t_b
	     2: min_tim = t_c
	  endcase
	  case t_mid of
	     0: mid_tim = t_a
	     1: mid_tim = t_b
	     2: mid_tim = t_c
	  endcase
	endelse


	; This loop finds the closest file to min_tim[n] for each of the filters. It constructs an
	; array of indices for each of the filters.
	for n = 0, n_elements(min_tim)-1 do begin
	  sec_min = min(abs(min_tim - min_tim[n]), loc_min)
	  if n eq 0 then next_min_im = loc_min else next_min_im = [next_min_im, loc_min]

	  sec_max = min(abs(max_tim - min_tim[n]), loc_max)
	  if n eq 0 then next_max_im = loc_max else next_max_im = [next_max_im, loc_max]

	  sec_mid = min(abs(mid_tim - min_tim[n]), loc_mid)
	  if n eq 0 then next_mid_im = loc_mid else next_mid_im = [next_mid_im, loc_mid]
	endfor

	if t_min eq t_max then begin
	     loc_a = next_max_im
	     loc_b = next_mid_im
	     loc_c = next_min_im
	endif else begin
	  case t_max of
	     0: loc_a = next_max_im
	     1: loc_b = next_max_im
	     2: loc_c = next_max_im
	  endcase
	  case t_mid of
	     0: loc_a = next_mid_im
	     1: loc_b = next_mid_im
	     2: loc_c = next_mid_im
	  endcase
	  case t_min of
	     0: loc_a = next_min_im
	     1: loc_b = next_min_im
	     2: loc_c = next_min_im
	  endcase
	endelse  

	plota = smooth(sigrange(distt_a[loc_a, *]), 1) ;> (0) < 1e7
	plotb = smooth(sigrange(distt_b[loc_b, *]), 1) ;> (0) < 1e7
	plotc = smooth(sigrange(distt_c[loc_c, *]), 1) ;> (0) < 1e7 ;(smooth(sigrange(distt_c[loc_c, *]), 2)) > (1e5) < 1e7
	
	tstart = anytim('2014-09-01T10:58:00', /utim) > min_tim[0] ;anytim('2014-04-18T12:00:00',/utim) > min_tim[0]
	tend = anytim('2014-09-01T11:10:00', /utim) < min_tim[n_elements(min_tim)-1] ;anytim('2014-04-18T13:10:00', /utim)	< min_tim[n_elements(min_tim)-1]
	istart = closest(min_tim, tstart)
	istop = closest(min_tim, tend)
	

	; Take section of the array
	hstart = 500.0 	;Mm
	hstop = 2700.0 	;Mm
	hindex0 = closest(lindMm, hstart)
	hindex1 = closest(lindMm, hstop)
	istart = closest(min_tim, tstart)
	istop = closest(min_tim, tend)

	truecolorim = [[[ plota[istart:istop, hindex0:hindex1] ]], [[ plotb[istart:istop, hindex0:hindex1] ]], [[ plotc[istart:istop, hindex0:hindex1] ]]] 

	;-------------------------------------------;
	;		PLOT three colour map
	;
	;truecolorim[*, *, 1]=truecolorim[*, *, 2]*0.5 + truecolorim[*, *, 0]*0.5
	;loadct, 72
	if keyword_set(plot_map) then begin
		plot_image, truecolorim[*, *, 2], $	;usually img
	    	position = [0.15, 0.15, 0.95, 0.95], $
	    	XTICKFORMAT="(A1)", $
	    	YTICKFORMAT="(A1)", $
		 	/noerase, $
		 	/normal, $
		 	xticklen=-0.001, $
	        yticklen=-0.001       

	    ; This allows a point and click for the distance and time.    
	 	utplot, min_tim, lindMm, $	;/rsun + 0.9, $
		 	/nodata, $
		 	/xs, $
		 	/ys, $
		 	yr=[lindMm(hindex0), lindMm(hindex1)], $, $
		  	xr = [tstart, tend], $
			position = [0.15, 0.15, 0.95, 0.95], $
			/noerase, $
			/normal, $
	    	ytitle='Distance (Mm)'
	endif    	
	;window, 1, xs=400, ys=400
	xindex = where(lindMm gt 1200 and lindMm lt 2000)
	lindMm = lindMm[xindex]
	for i=0, n_elements(min_tim)-1 do begin
		profil = smooth(distt_c[i, xindex]>1e5, 5, /edge_mirror)

		;plot, lindMm, profil, $
		;yr=[1e5, 1e7], /ylog
		;print, anytim(min_tim[i], /cc)

		
		index_gt = where(profil gt 5e5)
		if index_gt[0] gt -1 then begin
			index0 = index_gt[0]
			index1 = index_gt[n_elements(index_gt)-1]
			set_line_color
			;plots, [lindMm[index0], lindMm[index1]], [ profil[index0], profil[index1] ], psym=5, symsize=2, color=3

			tim = min_tim[i] 
			l0 = lindMm[index0]
			l1 = lindMm[index1]
			plots, tim, l0, psym=4, symsize=2, color=3
			plots, tim, l1, psym=4, symsize=2, color=3
			if isa(times) eq 0 then begin
				times = tim
				distl0 = l0
				distl1 = l1
			endif else begin
				times = [times, tim]
				distl0 = [distl0, l0]
				distl1 = [distl1, l1]
			endelse	
		endif	

	endfor
	dtmap = distt_c
	tmap = t_c

	save, times, distl0, distl1, filename=folder +'nrh_'+freq_tag[2]+'_width_track.sav'
stop

END