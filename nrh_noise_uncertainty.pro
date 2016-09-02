pro nrh_noise_uncertainty

	; Code to compare what the background levels are compared to the source max
	

	folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/' 
	cd, folder
	filenames = findfile('*.fts')

	winsize=600
	window, 0, xs=winsize, ys=winsize, retain=2
	window, 1, xs=winsize, ys=winsize, retain=2
	winsize=500
	window, 2, xs=winsize, ys=winsize, xpos = 100, ypos=100, retain=2
	!p.charsize=1.5
	
	FOV = [25, 25]
	CENTER = [-1000, 650]
	nlevels=5.0   
	top_percent = 0.50

	for k=0, n_elements(filenames)-1 do begin
		tstart = anytim(file2time('20140901_110015'), /utim)	
		tstop =  anytim(file2time('20140901_110600'), /utim)
		i=0
		while tstart lt tstop do begin

			t0str = anytim(tstart, /yoh, /trun, /time_only)

			read_nrh, filenames[k], $
					  nrh_hdr, $
					  nrh_data, $
					  hbeg=t0str;, $ 
					  ;hend=t1str
					
			index2map, nrh_hdr, nrh_data, $
					   nrh_map  
					
			nrh_str_hdr = nrh_hdr
			nrh_times = nrh_hdr.date_obs
					
			;------------------------------------;
			;			Plot Total I
			freq = nrh_hdr.FREQ
			loadct, 3, /silent
			wset, 0
			plot_map, nrh_map, $
				fov = FOV, $
				center = CENTER, $
				dmin = 1e5, $
				dmax = 1e8, $
				title='NRH '+string(nrh_hdr.freq, format='(I03)')+' MHz '+ $
				string( anytim( nrh_times, /yoh, /trun) )+' UT'
				  
			set_line_color
			plot_helio, nrh_times, $
				/over, $
				gstyle=1, $
				gthick=1.0, $
				gcolor=4, $
				grid_spacing=15.0

			max_val = max( (nrh_data) ,/nan) 									   
			levels = (dindgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) $
					+ max_val*top_percent  

			plot_map, nrh_map, $
				/overlay, $
				/cont, $
				levels=levels, $
				/noxticks, $
				/noyticks, $
				/noaxes, $
				thick=1, $
				color=5		


			;------------------------------------;
			;	  Now plot raw data structure	 ;
			;
			wset, 1
			x0 = (CENTER[0]/nrh_hdr.cdelt1 + (nrh_hdr.naxis1/2.0)) - (FOV[0]*60.0/nrh_hdr.cdelt1)/2.0
	        x1 = (CENTER[0]/nrh_hdr.cdelt1 + (nrh_hdr.naxis1/2.0)) + (FOV[0]*60.0/nrh_hdr.cdelt1)/2.0
	        y0 = (CENTER[1]/nrh_hdr.cdelt2 + (nrh_hdr.naxis2/2.0)) - (FOV[1]*60.0/nrh_hdr.cdelt2)/2.0
	        y1 = (CENTER[1]/nrh_hdr.cdelt2 + (nrh_hdr.naxis2/2.0)) + (FOV[1]*60.0/nrh_hdr.cdelt2)/2.0
			nrh_data = nrh_map.data
			data_section = nrh_data[x0:x1, y0:y1]

			loadct, 25, /silent
			plot_image, data_section > 1e4 <1e9, title='Raw data, pixel numbers.'

			;---------------------------------------;
			;		Backgrund noise area
			;
			; The deconvolution (CLEAN) is leaving quite significant areas of negative values in the
			; array. Even in the areas containing just background the values are distributed around
			; zero. This is unphysical. To look into what the average positive variation is I take
			; the absolute value of the array and then compute the mean and standard deviation. There
			; should be no error introduced, since the deconvolution will not produce negaive areas
			; any bigger (in absolute value) than positive areas in the original sky brightness distribution.
			noise_section = abs(nrh_data[0:30, 0:30])
			wset, 2
			shade_surf, noise_section, charsize=3.0
			uncertainty = (mean(noise_section)+2.0*stdev(noise_section))/max(data_section)
			stop
			if i eq 0 then Tb_error = uncertainty else Tb_error = [Tb_error, uncertainty]
			if i eq 0 then Tb_max = max(data_section) else Tb_max = [Tb_max, max(data_section)]
			if i eq 0 then times = tstart else times = [times, tstart]

			tstart = tstart + 1.0
			i=i+1
		endwhile		
		plothist_new, Tb_error, /auto
		print, 'Average error for '+string(freq)+'MHz : '+string(mean(Tb_error))
		if k eq 0 then tb_errs = Tb_error else tb_errs = [ [tb_errs], [Tb_error] ]
		if k eq 0 then freqs = freq else freqs = [freqs, freq]

	endfor	

	nrh_tb_err = {name:'NRH_TB_ERRS', $
					freqs:freqs, $
					tb_errs:tb_errs, $
					times:times}

	save, nrh_tb_err, filename=folder+'/nrh_tb_bkg_errs.sav'
END
