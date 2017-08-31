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

pro plot_sxi_allfilt_nrh_20140901, postscript=postscript

	

	FOV = [35.0, 35.0]
	CENTER = [-1100.0, 400.0]

	;---------------------------------------;
	;	Produce the pre event maps.
	;	There are four filters in the sequence
	;

	sxi_files = findfile('~/Data/2014_sep_01/goes/sxi/sxi_20170116_154249_eo_fits/*.FTS');'~/Data/2014_sep_01/goes/sxi/sxi_20170116_154249_eo_fits/SXI_20140901_110315155_BA_13.FTS'
	
	; First PTHNA
	mreadfits, sxi_files[0], hdr0, img0
	index2map, hdr0, img0, sxi_map0
	sxiPTHNA_map0 = rot_map(sxi_map0, -1.0*sxi_map0.roll_angle, center = sxi_map0.ROLL_CENTER)

	; First PTHK
	mreadfits, sxi_files[1], hdr0, img0
	index2map, hdr0, img0, sxi_map0
	sxiPTHK_map0 = rot_map(sxi_map0, -1.0*sxi_map0.roll_angle, center = sxi_map0.ROLL_CENTER)

	; First TINA
	mreadfits, sxi_files[4], hdr0, img0
	index2map, hdr0, img0, sxi_map0
	sxiTINA_map0 = rot_map(sxi_map0, -1.0*sxi_map0.roll_angle, center = sxi_map0.ROLL_CENTER)

	; First BE12A
	mreadfits, sxi_files[6], hdr0, img0
	index2map, hdr0, img0, sxi_map0
	sxiBE12A_map0 = rot_map(sxi_map0, -1.0*sxi_map0.roll_angle, center = sxi_map0.ROLL_CENTER)


	for i=7, n_elements(sxi_files)-1 do begin

		sxi_file1 = sxi_files[i]
		mreadfits, sxi_file1, hdr1, img1, /silent	
		index2map, hdr1, img1, sxi_map1
		sxi_map1 = rot_map(sxi_map1, -1.0*sxi_map1.roll_angle, center = sxi_map1.ROLL_CENTER)
		
		stop
		case hdr1.WAVELNTH of
			'PTHNA': sxi_map0 = sxiPTHNA_map0
			'PTHK': sxi_map0 = sxiPTHK_map0
			'TINA': sxi_map0 = sxiTINA_map0
			'BE12A': sxi_map0 = sxiBE12A_map0
		endcase	
		;---------------------------------------;
		;	   Plot the difference image
		;
		if keyword_set(postscript) then begin
			setup_ps, '~/GOESsxi_nrh_20140901.eps'
		endif else begin
			window, 0, xs=900, ys=900, retain=2
			!p.charsize=1.5
		endelse	
		
		diff_map = diff_map(sxi_map1, sxi_map0)
		diff_map.data = smooth(diff_map.data, 2, /edge_mirror)

		loadct, 3
		reverse_ct
		plot_map, diff_map, dmin=-0, dmax=20.0, $
			fov=FOV, $
			center=CENTER, $
			color=255, $
			title=hdr1.WAVELNTH

		plot_helio, hdr1.date_obs, $
			/over, $
			gstyle=0, $
			gthick=5.0, $	
			gcolor=255, $
			grid_spacing=15.0


		;--------------------------------------;
		;		Now plot the radio
		;
		folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
		cd, folder
		filenames = findfile('*.fts')
		time = anytim(diff_map.time, /yoh, /trun, /time_only)

		read_nrh, filenames[8], $
			  nrh_hdr, $
			  nrh_data, $
			  hbeg=time

		index2map, nrh_hdr, nrh_data, $
				 nrh_map  	 


		max_val = max( (nrh_data), /nan) 							   
		nlevels=5.0   
		top_percent = 0.5	; 0.3 on a linear scale for the 2014 Sep 01 event
		levels = (dindgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) $
					+ max_val*top_percent  ;> threshold	

		set_line_color
		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			levels=levels, $
			/noxticks, $
			/noyticks, $
			/noaxes, $
			thick=3, $
			color=5
		
		freq_tag = string(nrh_hdr.freq, format='(I3)')		
		;xyouts, 0.2, 0.78, 'GOES-13 SXI-FM1 BE12A  2014-09-01T11:03:15 UT', $
		;	/normal, color=0, charthick=4, charsize=1.3
		;xyouts, 0.2, 0.81, 'NRH '+freq_tag+' MHz  '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', $
		;	/normal, color=5, charthick=4, charsize=1.3		

		xyouts, 0.16, 0.80, 'GOES-13 SXI-FM1 '+hdr1.WAVELNTH+' '+hdr1.date_obs+' UT' , $
			/normal, color=0, charthick=1, charsize=1.3
		xyouts, 0.16, 0.82, 'NRH '+freq_tag+' MHz  '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', $
			/normal, color=5, charthick=1, charsize=1.3			

		if ~keyword_set(postscript) then x2png, '~/Data/2014_sep_01/goes/sxi/sxi_20170116_154249_eo_fits/png/image_'+string(i, format='(I03)' )+'.png' 	
		if keyword_set(postscript) then device, /close else set_plot, 'x'
		stop
		
	endfor
	

STOP
END