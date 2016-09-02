pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.3
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=6, $
          ysize=6, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end


pro nrh_orfees_Tb_20140901, postscrip=postscript


	!p.charsize=1.0
	!p.thick=5
	pos = [0.15, 0.15, 0.88, 0.88]

	nrh_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'
	nrh_files = findfile(nrh_folder+'*src_properties.sav')

	time0 = anytim('2014-09-01T11:00:00', /utim)
	time1 = anytim('2014-09-01T11:05:00', /utim)
	date_string = time2file(time0, /date)


	;----------------------------------------------;
	;				NRH flux plot
	;
	colors = indgen(n_elements(nrh_files))+2

	if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/nrh_Tb_20140901.eps'

	i=0
	restore, nrh_files[i]
	freq_string = string(xy_arcs_struct.freq, format='(I3)')
	times = anytim(xy_arcs_struct.times, /utim)
	Tb = anytim(xy_arcs_struct.TB, /utim)

	utplot, times, smooth(Tb, 5), $
			/xs, $
			/ys, $
			yr=[3e5, 1e10], $
			xr = [time0, time1], $
			ytitle = 'Brightness Temberature (K)', $
			;yticklen = 0.00001, $
  		    /ylog, $
  		    position = pos, $
  		    color = colors[i], $
  		    /noerase

	
	for i=1, n_elements(nrh_files)-1 do begin

		restore, nrh_files[i]
		times = anytim(xy_arcs_struct.times, /utim)
		Tb = anytim(xy_arcs_struct.TB, /utim)

		utplot, times, smooth(Tb, 5), $
				/xs, $
				/ys, $
				yr=[3e5, 1e10], $
				xr = [time0, time1], $
				xtitle = ' ', $
				ytitle = ' ', $
				ytickformat='(A1)', $
				xtickformat='(A1)', $
	  		    /ylog, $
	  		    position = pos, $
	  		    color = colors[i], $
	  		    /noerase

	endfor  	

	freqs = [ string([150, 173, 228, 270, 298, 327, 408, 432, 445], format='(I3)')+' MHz' ]
	legend, freqs , $
			linestyle = intarr(n_elements(nrh_files)), $
			charsize=0.8, $
			color=colors, $
			box=0, $
			position=[0.62, 0.88], $
			/normal	


	if keyword_set(postscript) then device, /close
	set_plot, 'x'




END