function paulo_gyro, freqs, params ;Bfield, Del, ener2, Ang

	; Function to send the data to the gyrosynchrotron numerical model 
	; See Paulo & Simoes (2013) for a description of the numerical model
	
	;/////////////////////////////////
	; These expressions were put here by Eoin Carley. 
	; To reduce the dynamic range of fitting paramaters
	; nel = 10^nel   
	; np = 10^np
	; energy[1] = 10^energy[1]
	; angle=angle*10.0
	;/////////////////////////////////

	;rsun = 6.9e10	    ; cm
	;Lradio = 3.10500e+10 ; 0.45*rsun ;cm
	;size_arcsec = Lradio/727e5	; 427.098 
	;height_cm = Lradio
	;Emin=9.0	

	gyro, freqs, flux_model, $
			bmag=params[0], $
			nel=10^params[1], $
			np=10^params[2], $
			delta=params[3], $	
			ener=[9.0, 10^params[4]], $
			angle=45., $
			anor=7.8e30, $
			size=427.098, $
			hei=3.10500e+10, $
			/quiet

	return, alog10(flux_model)

END	

pro nrh_rstn_flux_spect_gyro_model_montec, postscript=postscript, out_file=out_file, progress_file=progress_file, $
									gyro_code=gyro_code, plot_png=plot_png

    ; Randomly generate fit procedure starting values from a normal distribution and fit
    ; the gyro spectrum. The results should show an independence of fit variables 
    ; (provided the fit coefficients are uncorrelated)

	; Apapdted fromt nrh_rstn_flux_spect_plot_20140901.pro
	; out_file (.sav): String file name for paramater averages from all Monte-Carlo runs 
	; progress_file (.txt): String file name for which gives percent complete and ETA of finish
	; gyro_code: Either 'A', 'B', 'C' or 'D'. Four different folders with the same gyro C++ code.
	;			 Four different threads (or more) have trouble using the same compiled procedure.
	
	; Example: 
	;   nrh_rstn_flux_spect_gyro_model_montec, progress_file='gyro_mc_process_status1.txt', out_file='gyro_mc_results_master_vtest_mc1.sav', gyro_code='A'
	;	nrh_rstn_flux_spect_gyro_model_montec, progress_file='gyro_mc_process_status2.txt', out_file='gyro_mc_results_master_vtest_mc2.sav', gyro_code='B'
	;	nrh_rstn_flux_spect_gyro_model_montec, progress_file='gyro_mc_process_status3.txt', out_file='gyro_mc_results_master_vtest_mc3.sav', gyro_code='C'
	;   nrh_rstn_flux_spect_gyro_model_montec, progress_file='gyro_mc_process_status3.txt', out_file='gyro_mc_results_master_vtest_mc4.sav', gyro_code='D'
	;	nrh_rstn_flux_spect_gyro_model_montec, progress_file='gyro_mc_process_status5.txt', out_file='gyro_mc_results_master_vtest_mc5.sav', gyro_code='E'
	;	nrh_rstn_flux_spect_gyro_model_montec, progress_file='gyro_mc_process_status6.txt', out_file='gyro_mc_results_master_vtest_mc6.sav', gyro_code='F'
	; In the v2 version here the model is fit to the average flux density spectrum, start params are iterated, then the model fit again.

	;!p.multi=[0,1,2]
	;window, 0, xs=500, ys=700, retain=2
	restore, '~/Data/2014_sep_01/radio/mean_flux_density_sectrum.sav'
	flux = flux_mean
	err = flux_err_mean 
	weights=flux ; for the fit
	freq = 10^freq
	anor=7.8966100e+30		; Normalisation constant of total number of electrons
	freq_model=10^interpol(alog10([0.01,20]*1e9),50)
	freq_model = alog10(freq_model)
	rsun = 6.9e10	    ; Solar radius in cm
	saving = 0
	monte_end = 200.		; Number of Monte-Carlo test fits, 5 seperate computational threads -> 1000 results.
	cd,'~/idl/gyro/'+gyro_code
	
	;//////////////////////////////////////
	;
	;   Set fit parameter restrictions.
	;
	pi = replicate({value:0.D, step:0.D, fixed:0, limited:[0,0], $
		                      limits:[0.D,0]}, 5)	

	;Large step sizes in solution space for some of these params.
	pi[1].limited(0) = 1
	pi[1].limits(0) = 7.0
	pi[0].step = 0.4
	;pi[1].step = 0.5
	pi[2].step = 0.3
	pi[3].step = 0.1
	pi[4].step = 0.3
	;pi[5].step = 1
	;pi[5].limited(0) = 1
	;pi[5].limits(0) = 10.0	


	;//////////////////////////////////////
	;	 Generation of random starting 
	;  values from a Uniform distribution
	GET_UTC, UTC
	loop_start_t = anytim(UTC, /utim)
	B_uniform = 3.0+3.0*RANDOMU(loop_start_t, monte_end)	; Uniform dist of B between 2 and 11 with a mean of 5.3
	wait, 1.5	; Need to wait for UTC to become a new seed value.
	GET_UTC, UTC
	seed = anytim(UTC, /utim)
	Nel_uniform = alog10( 2.0e7+1.0e7*RANDOMU(seed, monte_end) )
	wait, 1.5
	GET_UTC, UTC
	seed = anytim(UTC, /utim)
	Np_uniform = alog10( 1.0e8+2.0e8*RANDOMU(seed, monte_end) )
	wait, 1.5
	GET_UTC, UTC
	seed = anytim(UTC, /utim)
	delta_uniform = 3.3+0.3*RANDOMU(seed, monte_end)
	wait, 1.5
	GET_UTC, UTC
	seed = anytim(UTC, /utim)
	E_uniform = 3.6+0.3*RANDOMU(seed, monte_end)
	wait, 1.5

	init_start_values = [ transpose(B_uniform), $
						  transpose(Nel_uniform), $
						  transpose(Np_uniform), $
						  transpose(delta_uniform), $
						  transpose(E_uniform) ]

	for k=0, monte_end-1 do begin

		;--------------------------------------;
		;			Do the model fit.
		;
		pi[*].value = init_start_values[*, k]
		p = mpfitfun('paulo_gyro', freq, $
						flux, $
						weights=weights, $
						parinfo=pi, $
						bestnorm=bestnorm, $
						dof=dof, $
						perror=perror, $
						errmsg=errmsg, $
						maxiter=30.)
		
		if keyword_set(plot_png) then begin
			plot_mean_gyro_spec_fit, parms=init_start_values[*, k]
			plot_mean_gyro_spec_fit, parms=p
		endif

		if p[0] ne init_start_values[0,k] then begin 
			; Some fits fail to converge and the 
			; start values are output for the fit values. 
			; This if statement excludes recording these values
		
			if saving eq 0 then begin
				parms_avgs = p 
				parms_err = perror
				start_values = pi[*].value
			endif else begin
				parms_avgs = [ [parms_avgs], [p]  ]
				parms_err = [ [parms_err], [perror]  ]
				start_values = [ [start_values], [pi[*].value] ]
			endelse
			saving = 1
		endif	

		;---------------------------------------------------;
		;	 Some things to predict ETA of procedure end.
		;
		percent_comp = ( (k+1) /monte_end)*100.0
		percent_comp_str = 'Monte-Carlo gyro fits '+string(percent_comp, format = '(f6.2)')+'% complete.'
		spawn, 'echo '+ percent_comp_str +' > ~/Data/2014_sep_01/radio/gyro_fits/'+progress_file
		spawn, 'echo Start values:'+ strjoin( string(init_start_values) ) +' >> ~/Data/2014_sep_01/radio/gyro_fits/'+progress_file
		GET_UTC, UTC
		elapsed_time = anytim(UTC, /utim) - loop_start_t
		eta_finish = anytim( anytim(UTC, /utim) + (elapsed_time/percent_comp)*100.0, /cc) ;For Central European Time
		spawn, 'echo Process finish ETA: '+ eta_finish +' Local >> ~/Data/2014_sep_01/radio/gyro_fits/'+progress_file
		
	endfor
	
	;save, parms_avgs, start_values, parms_err, filename='~/Data/2014_sep_01/radio/gyro_fits/'+out_file


END	