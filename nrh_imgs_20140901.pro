pro nrh_imgs_20140901

	;Code to produce pngs of NRH observations of the 2014 Sep 01 event 
	;Produces pngs for all frequencies
	;Written 2014-Oct-2
	folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	cd, folder
	filenames = findfile('*.fts')

	;-------------------------------------------------------------;
	;	  Read Data 5 min chunks to prevent RAM overload
	;

	window, 10, xs=700, ys=700, retain=2
	!p.charsize=1.5
	tstart = anytim(file2time('20140901_105500'), /utim)
	tend   = anytim(file2time('20140901_110500'), /utim)
	
	for k=0, n_elements(filenames)-1 do begin
		
		t0_pre = anytim(tstart, /utim)
		t0str_pre = anytim(t0_pre, /yoh, /trun, /time_only)

		t1_pre = anytim(tstart, /utim) + 5.0
		t1str_pre = anytim(t1_pre, /yoh, /trun, /time_only)

		read_nrh, filenames[k], $
				  nrh_hdr, $
				  nrh_data, $
				  hbeg=t0str_pre, $
				  hend=t1str_pre
	
		nrh_data_pre = smooth(mean(nrh_data, dim=3), 5)

		t0 = anytim(tstart, /utim) + 60
		i=61.0
		image_num = 0
		while t0 lt tend DO BEGIN
				
			t0 = anytim(tstart, /utim) + i
			t0str = anytim(t0, /yoh, /trun, /time_only)

			read_nrh, filenames[k], $
					  nrh_hdr, $
					  nrh_data, $
					  hbeg=t0str
			
			nrh_data = smooth(nrh_data, 5)
			nrh_data = nrh_data - nrh_data_pre

			index2map, nrh_hdr, nrh_data, $
					   nrh_map  
			
			nrh_str_hdr = nrh_hdr
			nrh_times = nrh_hdr.date_obs

			
			;--------------------------------------------------------;
			;					Plot Total I
			;
			if nrh_hdr.freq lt 175 then max_temp=1e9 else max_temp=5e7
			freq_tag = string(nrh_hdr.freq, format='(I03)')
			loadct, 0, /silent
			plot_map, nrh_map, /nodata

			loadct, 25, /silent
			plot_map, nrh_map, $
					  title='NRH '+string(nrh_hdr.freq, format='(I03)')+' MHz '+$
					  string( anytim( nrh_times, /yoh, /trun) )+' UT', $
					  dmin = 1e5, $
					  dmax = max_temp, $
					  /noerase

			set_line_color
			plot_helio, nrh_times, $
						/over, $
						gstyle=1, $
						gthick=1.0, $
						gcolor=1, $
						grid_spacing=15.0			
		
			loadct, 25, /silent
			cgcolorbar, range = [1e5, max_temp], $
					/vertical, $
					/right, $
					color=255, $
					/ylog, $
					pos = [0.87, 0.15, 0.88, 0.85], $
					title = 'Brightness Temperature (log(T[K]))', $
					FORMAT = '(e10.1)'


			;x2png, 'image_'+string(image_num, format='(I04)')+'.png'
			i = i + 1.
			image_num = image_num+1
		
		endwhile

		;spawn, 'ffmpeg -y -r 25 -i nrh_%04d.png -vb 50M nrh_'+freq_tag+'mhz_'+time2file(tstart, /sec)+'_clean.mpg'
		;spawn, 'rm -rf nrh*.png'

	endfor

END
