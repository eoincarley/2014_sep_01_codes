pro nrh_dt_arc_calc_20140901

	; Modify to use an arc off the solar limb

	; Code to produce distance time map from line on AIA image
	; These maps are then used in the three colour map code aia_dt_plot_three_color.pro

	loadct, 1
	!p.charsize=1.5
	winsz=700
	AU = 1.49e11	; meters
	npoints = 1000
	angle0=70.0
	angle1=270.0
	angles = findgen(npoints)*(angle0 - angle1)/(npoints-1) + angle1
	radius = 1050.0	;arcsec
	arc0 = transpose( [ [(radius+100.0)*cos(angles*!dtor)], [(radius+100.0)*sin(angles*!dtor)] ] )
	arc1 = transpose( [ [(radius+200.0)*cos(angles*!dtor)], [(radius+200.0)*sin(angles*!dtor)] ] )
	arc2 = transpose( [ [(radius+300.0)*cos(angles*!dtor)], [(radius+300.0)*sin(angles*!dtor)] ] )	;808.0
	arc3 = transpose( [ [(radius+400.0)*cos(angles*!dtor)], [(radius+400.0)*sin(angles*!dtor)] ] )



		;-------------------------------------------------;
		;		  Choose files unaffected by AEC
		;
		folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
		cd, folder
		nrh_filenames = (findfile('*.fts'))

		window, 0, xs=winsz, ys=winsz, retain = 2
		window, 4, xs=winsz, ys=winsz, retain = 2
		window, 3, xs=500, ys=500
		
		for j=5, 8 do begin
			tstart = anytim('2014-09-01T10:59:00', /utim)
			tend = anytim('2014-09-01T11:06:00', /utim)
			t0 = anytim(tstart, /yoh, /trun, /time_only)
			t1 = anytim(tend, /yoh, /trun, /time_only)
			read_nrh, nrh_filenames[j], $	; 432 MHz
					nrh_hdrs, $
					nrh_data, $
					hbeg=t0, $
					hend=t1	
			tarr = anytim( nrh_hdrs.date_obs, /utim) 	;( findgen(finish-start)*(tend - tstart)/(finish-start -1) ) + tstart	

			distt = fltarr(n_elements(nrh_hdrs), npoints)

			;----------------------------------------------------;
			;		Define lines over which to interpolate
			;
			index2map, nrh_hdrs[0], nrh_data[*, *, 0], $
					 map_dummy 

			freq_tag = string(nrh_hdrs[0].freq, format='(I3)')			 

			axis1_sz = (size(map_dummy.data))[1]/2.0	
			axis2_sz = (size(map_dummy.data))[2]/2.0
			fnpoints = findgen(npoints)

			;---------------------------------------------------------;
			;
			;				Line length in arcsecs
			;
			arc_radius = sqrt( (arc0[0, 0])^2.0 + (arc0[1, 0])^2.0 )	; arcseconds
			arc_radius = arc_radius/(960.0)		; Rsun
			arc_len = arc_radius*(angle1-angle0)*!dtor	; Rsun
			lind = arc_len*695.0	; Mm  ; AU*(tan(arc_len/3600.0)*!dtor)/1e6
			lindMm = fnpoints*(lind)/(npoints-1.0)

		  
		  	FOR i = 0, n_elements(nrh_hdrs)-1 DO BEGIN ;n_elements(f)-2 DO BEGIN

				;-------------------------------------------------;
				;			 		Read data
				; 
				; The actual dt_plotter takes care of the differencing now. 
				; See aia_dt_plot_three_color.
				nrh_hdr = nrh_hdrs[i]
				nrh_img = nrh_data[*, *, i]
				index2map, nrh_hdr, nrh_img, $
					 map
				
				loadct, 1, /silent
				wset, 4
				plot_map, map

				plot_helio, nrh_hdr.date_obs, $
					/over, $
					gstyle=0, $
					gthick=1.0, $	
					gcolor=255, $
					grid_spacing=15.0

				

				set_line_color
				plots, arc0[0, *], arc0[1, *], /data, color=3, thick=1.5
				plots, arc1[0, *], arc1[1, *], /data, color=3, thick=1.5
				plots, arc2[0, *], arc2[1, *], /data, color=3, thick=1.5
				plots, arc3[0, *], arc3[1, *], /data, color=3, thick=1.5

				;---------------------------------------------------------;
				;				Same lines on data array
				;
				loadct, 3, /silent
				wset, 0
				plot_image, map.data
				pixx0 = FIX( axis1_sz + arc0[0, *]/map_dummy.dx )
				pixy0 = FIX( axis2_sz + arc0[1, *]/map_dummy.dy )
				set_line_color
				plots, pixx0, pixy0, /data, color=3

				pixx1 = FIX( axis1_sz + arc1[0, *]/map_dummy.dx )
				pixy1 = FIX( axis2_sz + arc1[1, *]/map_dummy.dy )
				pixx2 = FIX( axis1_sz + arc2[0, *]/map_dummy.dx )
				pixy2 = FIX( axis2_sz + arc2[1, *]/map_dummy.dy )
				pixx3 = FIX( axis1_sz + arc3[0, *]/map_dummy.dx )
				pixy3 = FIX( axis2_sz + arc3[1, *]/map_dummy.dy )

				prof1 = transpose( interpolate(map.data, pixx0, pixy0) )
				prof2 = transpose( interpolate(map.data, pixx1, pixy1) )
				prof3 = transpose( interpolate(map.data, pixx2, pixy2) )
				prof4 = transpose( interpolate(map.data, pixx3, pixy3) )
				prof = mean( [ [prof1], [prof2], [prof3], [prof4] ], dim=2)

				distt[i, *] = prof 

				loadct, 3, /silent
				wset, 3
				spectro_plot, distt > (0) < 2e7, tarr, lindMm, $
								/xs, $
								/ys, $
								ytitle='Distance (Mm)', $
								yr = [500, 2500]
stop
				;print, anytim(tarr[i-start], /yoh), ' and '+he_aia.date_obs
				progress_percent, i, 0, n_elements(nrh_hdrs)-1

			ENDFOR
			dt_map_struct = {name:'nrh_dt_map', dtmap:distt, time:tarr, distance:lindMm, xyarcsec:[[arc0], [arc1], [arc2], [arc3]] }
		  	save, dt_map_struct, $
		  		filename='~/Data/2014_sep_01/radio/nrh/dtmaps/nrh_'+freq_tag+'_arc_dt_map.sav'
		endfor
 
	STOP

END