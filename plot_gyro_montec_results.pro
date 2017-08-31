pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.0
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=5, $
          ysize=10, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end

pro plot_gyro_montec_results, postscript=postscript

	; Plot the results of the Monte Carlo fits to the gyrosynchrotron spectrum

	folder = '~/Data/2014_sep_01/radio/gyro_fits/'
	;file1 = 'gyro_mc_results_master_1000.sav'
	;restore, folder+file1, /verb
	;params_total = PARMS_AVGS

	file1 = 'gyro_mc_results_master_vtest_mc1.sav'
	file2 = 'gyro_mc_results_master_vtest_mc2.sav'
	file3 = 'gyro_mc_results_master_vtest_mc3.sav'
	file4 = 'gyro_mc_results_master_vtest_mc4.sav'
	file5 = 'gyro_mc_results_master_vtest_mc5.sav'
	file6 = 'gyro_mc_results_master_vtest_mc6.sav'

	restore, folder+file1, /verb
	params_total = PARMS_AVGS
	params_start = START_VALUES
	restore, folder+file2, /verb
	params_total = [ [params_total], [PARMS_AVGS] ]
	params_start = [ [params_start], [START_VALUES] ]
	restore, folder+file3, /verb
	params_total = [ [params_total], [PARMS_AVGS] ]
	params_start = [ [params_start], [START_VALUES] ]
	restore, folder+file4, /verb
	params_total = [ [params_total], [PARMS_AVGS] ]
	params_start = [ [params_start], [START_VALUES] ]
	restore, folder+file5, /verb
	params_total = [ [params_total], [PARMS_AVGS] ]
	params_start = [ [params_start], [START_VALUES] ]
	restore, folder+file6, /verb
	params_total = [ [params_total], [PARMS_AVGS] ]
	params_start = [ [params_start], [START_VALUES] ]


	B = params_total[0, *]		; Gauss
	Ehigh = 10^params_total[4, *]	;
	Nel = 10^params_total[1, *]			; cm^-3
	Np = 10^params_total[2, *]
	indices = where(B le 18.0 and Ehigh lt 14000 and Nel lt 1e8)

	B = params_total[0, indices]		; Gauss
	Nel = 10^params_total[1, indices]	; cm^-3
	Np = 10^params_total[2, indices]	; cm^-3
	delta = params_total[3, indices]
	Ehigh = 10^params_total[4, indices]	; keV
	;angle = params_total[5, indices]	; degrees

	;params_start = START_VALUES
	B_start = params_start[0, indices]			; Gauss
	Nel_start = 10^params_start[1,indices]		; cm^-3
	Np_start = 10^params_start[2, indices]	    ; cm^-3
	delta_start = params_start[3, indices]
	Ehigh_start = 10^params_start[4, indices]	; keV
	;angle_start = params_start[5, indices]		; degrees


	!p.multi=[0, 3, 1]
	!p.charsize=2.5
	set_line_color
	window, 0, xs=400*(3/1.), ys=400

	;--------------------------------------;
	;			Histogram B
	plothist_new, B, bin=0.9, xr=[0.5, 10.0], color=0, $
		xtitle='Magnetic field strength (G)', $
		ytitle='Number of results'

	xyouts, 0.06, 0.90, 'Mean: '+string(mean(B), format='(f4.2)')+' G', color=3, /normal, charsize=1.5
	xyouts, 0.06, 0.87, 'Sdev: '+string(stdev(B), format='(f4.2)')+' G', color=3, /normal, charsize=1.5

	;--------------------------------------;
	;		Histogram non-thermal electrons density
	plothist_new, Nel, bin=1e7, xr=[1e6, 1e8], color=0, $
		xtitle='Non-thermal electron densitu (cm!U-3!N)', $
		ytitle='Number of results'

	xyouts, 0.40, 0.90, 'Mean: '+string(mean(Nel), format='(e8.1)')+' cm!U-3!N', color=3, /normal, charsize=1.5
	xyouts, 0.40, 0.87, 'Sdev: '+string(stdev(Nel), format='(e8.1)')+' cm!U-3!N', color=3, /normal, charsize=1.5

	;--------------------------------------;
	;		Histogram delta	
	plothist_new, delta, bin=0.1, xr=[2.0, 4.0], color=0, $
		xtitle='Electron spectral index', $
		ytitle='Number of results'

	xyouts, 0.73, 0.90, 'Mean: '+string(mean(delta), format='(f4.2)'), color=3, /normal, charsize=1.5
	xyouts, 0.73, 0.87, 'Sdev: '+string(stdev(delta), format='(f4.2)'), color=3, /normal, charsize=1.5
	

	;----------------------------------------------------;	
	;plothist_new, Np, bin=0.5e7, xr=[1e8, 2e8], color=0, $
	;	xtitle='Thermal electron densitu (cm!U-3!N)', $
	;	ytitle='Number of results'

	;xyouts, 0.76, 0.93, 'Mean: '+string(mean(Np), format='(e8.1)')+' cm!U-3!N', color=3, /normal, charsize=1.5
	;xyouts, 0.76, 0.91, 'Sdev: '+string(stdev(Np), format='(e8.1)')+' cm!U-3!N', color=3, /normal, charsize=1.5
	
	;----------------------------------------------------;	
	;plothist_new, delta, bin=0.019, xr=[3.0, 3.2], color=0, $
	;	xtitle='Electron spectral index', $
	;	ytitle='Number of results'

	;xyouts, 0.09, 0.43, 'Mean: '+string(mean(delta), format='(f4.2)'), color=3, /normal, charsize=1.5
	;xyouts, 0.09, 0.41, 'Sdev: '+string(stdev(delta), format='(f4.2)'), color=3, /normal, charsize=1.5
	
	;----------------------------------------------------;
	;plothist_new, Ehigh, bin=1e2, xr=[6e3, 7e3], color=0, $
	;	xtitle='High energy cut-off (keV)', $
	;	ytitle='Number of results'

	;xyouts, 0.42, 0.43, 'Mean: '+string(mean(Ehigh), format='(e8.1)')+' keV', color=3, /normal, charsize=1.5
	;xyouts, 0.42, 0.41, 'Sdev: '+string(stdev(Ehigh), format='(e8.1)')+' keV', color=3, /normal, charsize=1.5
	
	;----------------------------------------------------;	
	;plothist_new, angle, bin=1, xr=[70, 85], color=0, $
	;	xtitle='LOS angle (degrees)', $
	;	ytitle='Number of results'		

	;xyouts, 0.76, 0.43, 'Mean: '+string(mean(angle), format='(f4.1)')+' deg', color=3, /normal, charsize=1.5
	;xyouts, 0.76, 0.41, 'Sdev: '+string(stdev(angle), format='(f4.1)')+' deg', color=3, /normal, charsize=1.5
				




	;///////////////////////////////////////////////////////////////////////////;
	;
	;				Compare start values to fit values
	;
	!p.multi=[0, 1, 2]
	!p.charsize=1.2
	if keyword_set(postscript) then begin
		setup_ps, '~/Data/2014_sep_01/radio/gyro_fits/gyro_fits_20140901.eps'
	endif else begin
		window, 10, xs=300*(1/1.), ys=300*(2/1.), xp=1950, yp=1000
	endelse	
	set_line_color

	range = [2,8]
	cgHistoplot, B_start, BINSIZE=0.4, xr=range, yr=[0, 125], xtitle='B-field strength (G)', /fillpoly
	set_line_color
	cgHistoplot, B, BINSIZE=0.45, /oplot, color=5, POLYCOLOR='sky blue', /LINE_FILL, orientation=-45.


	plot, range, range, /nodata, $
		color=0, xtitle='Initial B-field (G)', ytitle='Fit B-field (G)', $
		/xs, /ys

	plots, range, [mean(B), mean(B)], color=0, thick=4
	plots, range, [mean(B)+stdev(B), mean(B)+stdev(B)], color=0, thick=4, linestyle=1
	plots, range, [mean(B)-stdev(B), mean(B)-stdev(B)], color=0, thick=4, linestyle=1	

	plotsym, 0
	oplot, B_start, B, $;xtitle='B field start (G)', ytitle='B field fit (G)', $
			psym=1, $
			;yr=[2.5, 5.0], $
			;xr=[1, 6], $
			color=5, $
			symsize=0.3

	if keyword_set(postscript) then begin
		device, /close
		spawn,'open ~/Data/2014_sep_01/radio/gyro_fits/'
		set_plot, 'x'
	endif				


	;///////////////////////////////////////////////
	;///////////////////////////////////////////////
	;///////////////////////////////////////////////
	;

	;window, 11, xs=300*(1/1.), ys=300*(2/1.), xp=1850, yp=1000
	;cgHistoplot, Np_start, yr = [1e6, 1e11]
	;cgHistoplot, Np, /oplot, POLYCOLOR='sky blue'

	;plot, [1e6, 2e11], [1e6, 2e11], /nodata, $
	;		color=0, $
	;		/xs, /ys
		
	;oplot, Np, Np_start, $;xtitle='B field start (G)', ytitle='B field fit (G)', $
	;		psym=8, $
			;yr=[2.5, 5.0], $
			;xr=[1, 6], $
	;		color=5	

	;B = B[where(B gt 3.5)]
	;B_start = B_start[where(B gt 3.5)]		
	


	;///////////////////////////////////////////////
	;  Calculate and plot the covariance matrix
	;
	cov_matrix = fltarr(n_elements(params_start[*,0]), n_elements(params_total[*,0]))
	for i=0, n_elements(cov_matrix[*, 0])-1 do begin
		for j=0, n_elements(cov_matrix[0, *])-1 do begin
			
			rsquared = correlate(params_start[i, *], params_total[j, *])^2.0
			cov_matrix[i, j] = round(rsquared*100.0)/100.0
		
		endfor

	endfor

	;///////////////////////////////////////////////
	;  			 Output for Latex
	;
	par_name = ['$B_f$', '$N_f$', '$n_{0,f}$', '$\delta_f$', '$E_{1,f}$']
	for i=0, n_elements(cov_matrix[*, 0])-1 do begin
		print,  par_name[i]+' & '+string(cov_matrix[0, i], format='(f5.2)') + $
				' & '+string(cov_matrix[1, i], format='(f5.2)') + $
				' & '+string(cov_matrix[2, i], format='(f5.2)') + $
				' & '+string(cov_matrix[3, i], format='(f5.2)') + $
				' & '+string(cov_matrix[4, i], format='(f5.2)')+'\\'; + $
				;' & '+string(cov_matrix[5, i], format='(f5.2)') + '\\'


	endfor




STOP
END