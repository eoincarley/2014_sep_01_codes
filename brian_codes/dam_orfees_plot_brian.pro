pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.5
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=12, $
          ysize=4, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end

pro plot_spec, data, time, freqs, frange, scl0=scl0, scl1=scl1
	

	print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
			' to ' + $
			string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'

	;data = 10.0*alog10(data)
	data = transpose(data)
	data = reverse(data, 2)
	;data = data/max(data)
	;wset,0
	spectro_plot, sigrange(data), $;  > (scl0) < (scl1), $
  				time, $
  				reverse(freqs), $
  				/xs, $
  				/ys, $
  				/ylog, $
  				ytitle='Frequency (MHz)', $
  				title = 'Orfees and DAM', $
  				yr=[ frange[0], frange[1] ], $
  				xrange = '2014-Sep-01 '+['11:00:00', '11:30:00'], $
  				/noerase, $
  				position = [0.09, 0.1, 0.95, 0.95]
		
	;set_line_color	
  	;hline, 432.0, /data, color=3
  	
END

pro plot_spectra, data, freq, time

	data = transpose(data)
	data = reverse(data, 2)

	burst_time = anytim('2014-09-01T11:02:00', /utim)

	index_start = where(time gt burst_time)

	loadct, 0
	window, 1

	for i=index_start[0], n_elements(time)-1 do begin
		spectra = data[*, i]
		plot, reverse(freq), smooth(spectra, 10), $
				/xs, $
				/ys, $
				xtitle = 'Frequency (MHz)', $
				ytitle = 'Intensity (Arbitrary Units)', $
				title = anytim(time[i], /cc), $
				xrange=[150, 450], $
				yr=[-0.1, 0.2]

		wait, 1.0
	endfor		



END


pro dam_orfees_plot_brian, save_orfees = save_orfees, postscript=postscript


	; This v2 now puts the seperate dynamic spectra into one.

	;------------------------------------;
	;			Window params
	;
	if keyword_set(postscript) then begin 
		setup_ps, '~/Data/2014_sep_01/orfees.eps'
	endif else begin
		loadct, 0
		reverse_ct
		window, 0, xs=1500, ys=800, retain=2
		!p.charsize=1.5
		!p.thick=1
		!x.thick=1
		!y.thick=1
	endelse	

	freq0 = 8
	freq1 = 1000
	time0 = '20140901_103000'
	time1 = '20140901_113000'


	
	;***********************************;
	;		Read and process DAM		
	;***********************************;
	cd,'~/Data/2014_sep_01/nda'
	restore, 'NDA_20140901_1022_left.sav', /verb
	daml = spectro_l
	timl = tim_l
	
	restore, 'NDA_20140901_1052_left.sav', /verb
	daml = [daml, spectro_l]
	timl = [timl, tim_l]
	restore, 'NDA_20140901_1122_left.sav', /verb
	daml = [daml, spectro_l]
	timl = [timl, tim_l]


	
	restore, 'NDA_20140901_1022_right.sav', /verb
	damr = spectro_r
	restore, 'NDA_20140901_1052_right.sav', /verb
	damr = [damr, spectro_r]
	restore, 'NDA_20140901_1122_right.sav', /verb
	damr = [damr, spectro_r]

	
	dam_spec = damr + daml
	dam_tim = timl
	
	dam_tim0 = anytim(file2time(time0), /time_only, /trun, /yoh)
	dam_tim1 = anytim(file2time(time1), /time_only, /trun, /yoh)

	dam_spec = reverse(transpose(dam_spec))
	dam_spec = slide_backsub(dam_spec, dam_tim, 10.0*60.0, /average)	
	;dam_spec = constback
	

	;***********************************;
	;	   Read and process Orfees		
	;***********************************;	

	cd,'~/Data/2014_sep_01/'
	file = 'ext_orf140901_1000_1300.fts'
	if keyword_set(save_orfees) then begin
		null = mrdfits(file, 0, hdr0)
		fbands = mrdfits(file, 1, hdr1)
		freqs = [ fbands.FREQ_B1, $
				  fbands.FREQ_B2, $
				  fbands.FREQ_B3, $
				  fbands.FREQ_B4, $
				  fbands.FREQ_B5  ]
		nfreqs = n_elements(freqs)		
		
		null = mrdfits(file, 2, hdr_bg, row=0)
		tstart = anytim(file2time('20140901_100000'), /utim)
		
		;--------------------------------------------------;
		;				 Choose time range
		t0 = anytim(file2time(time0), /utim)
		t1 = anytim(file2time(time1), /utim)
		inc0 = (t0 - tstart)*10.0 				;Sampling time is 0.1 seconds
		inc1 = (t1 - tstart)*10.0 				;Sampling time is 0.1 seconds
		range = [inc0, inc1]
		data = mrdfits(file, 2, hdr2, range = range)
		
		
		tstart = anytim(file2time('20140901_000000'), /utim)
		time_b1 = tstart + data.TIME_B1/1000.0

		data = transpose([data.stokesi_b1, data.stokesi_b2, data.stokesi_b3, data.stokesi_b4, data.stokesi_b5])
		data = reverse(data, 2)

		data = reverse(transpose(data))

		data_bg = slide_backsub(data, time_b1, 10.0*60.0)	
		
		save, data_bg, filename = 'test_ofees.sav', $
			description='Data produced using sliding 5 minute background. Data is logged.'
	endif else begin
		;--------------------------------------------------;
		;				 Choose time range
		null = mrdfits(file, 2, hdr_bg, row=0)
		tstart = anytim(file2time('20140901_100000'), /utim)
		t0 = anytim(file2time(time0), /utim)
		t1 = anytim(file2time(time1), /utim)
		inc0 = (t0 - tstart)*10.0 ;Sampling time is 0.1 seconds
		inc1 = (t1 - tstart)*10.0 ;Sampling time is 0.1 seconds
		range = [inc0, inc1]
		data = mrdfits(file, 2, hdr2, range = range)
		
		
		tstart = anytim(file2time('20140901_000000'), /utim)
		time_b1 = tstart + data.TIME_B1/1000.0
		time_b2 = tstart + data.TIME_B2/1000.0 
		time_b3 = tstart + data.TIME_B3/1000.0 
		time_b4 = tstart + data.TIME_B4/1000.0 
		time_b5 = tstart + data.TIME_B5/1000.0 

		fbands = mrdfits(file, 1, hdr1)
		freqs = [ fbands.FREQ_B1, $
				  fbands.FREQ_B2, $
				  fbands.FREQ_B3, $
				  fbands.FREQ_B4, $
				  fbands.FREQ_B5  ]
		restore, 'test_ofees.sav', /verb
	endelse
	
	;***********************************;
	;			   PLOT
	;***********************************;	5
	loadct, 74
	reverse_ct
	scl_lwr = -0.4				;Lower intensity scale for the plots.
	
	plot_spec, dam_spec, dam_tim, reverse(freq), [freq0, freq1], scl0=-0.08, scl1=0.05

	plot_spec, data_bg, time_b1, freqs, [freq0, freq1], scl0=-0.3, scl1=0.05

	;plot_spectra, data_bg, freqs, time_b1
	

	if keyword_set(postscript) then begin 
		device, /close
		set_plot, 'x'
	endif	
	

END
