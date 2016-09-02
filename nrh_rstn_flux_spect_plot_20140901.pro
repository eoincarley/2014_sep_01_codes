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

pro nrh_rstn_flux_spect_plot_20140901, postscript=postscript

	; Code to plot the flux density spectrum of NRH and RSTN then fit the data.
	; The flux density values are produced by nrh_rstn_flux_spect_20140901.pro
	

	!p.charsize=1.5
	loadct, 39
	window, 10, xs=600, ys=600
	restore, '~/Data/2014_sep_01/radio/nrh_rstn_flux_20140901.sav', /verb
	restore,'~/Data/2014_sep_01/radio/nrh/clean_wresid/nrh_residual_errors.sav', /verb
	resid_errs = resid_errs.nrh_resid_params
	stdevs = transpose(resid_errs[1, *, *])	; Standard deviation of the residuals (%) calculated in nrh_residual_errors.pro
											; Generally, during our period of interest (11:02-11:05 UT) the residuals are
											; within 1 standard deviation of the smoothed profile

	started=0

	nrh_times = nrh_rstn_flux.nrh_times
	nrh_fluxes = nrh_rstn_flux.nrh_flux
	nrh_freq = nrh_rstn_flux.nrh_freq

	rstn_times = nrh_rstn_flux.rstn_times
	rstn_fluxes = nrh_rstn_flux.rstn_flux
	rstn_freq = nrh_rstn_flux.rstn_freq

	start_index = 4
	freq = [nrh_freq, rstn_freq]
	freq = freq[start_index:n_elements(freq)-1]
	colors = (findgen(150)*255)/(89.);[0, 50, 240];(findgen(3)*255)/(2.)
	colors_index = 0

	if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/nrh_rstn_spectrum_TEST_20140901.eps'

	for i=0, n_elements(nrh_times)-1 do begin

		nrh_time = nrh_times[i]
		nrh_flux = nrh_fluxes[i, *]	;step through time
		nrh_errs = 2.0*nrh_flux*stdevs/100.0 + nrh_flux*0.2 ; +20 percent for NRH instrument SFU uncertainty

		rstn_index = closest(rstn_times, nrh_time)
		rstn_time = rstn_times[rstn_index]
		rstn_flux = rstn_fluxes[rstn_index, *]
		rstn_errs = rstn_flux*0.2

		flux = [transpose(nrh_flux), transpose(rstn_flux)]
		err=[transpose(nrh_errs), transpose(rstn_errs)]

		flux = flux[start_index:n_elements(flux)-1]
		err = err[start_index:n_elements(err)-1]

		;if nrh_time gt anytim('2014-09-01T11:04:00', /utim) then begin
			
			start = double([30.0, 1000.0, 2.0, -2.0])
			fit = '( p[0]*(x/p[1])^p[2] ) * ( 1.0 - exp( -1.0*(x/p[1])^(p[3]-p[2]) ) )'		
			; p[0] is peak flux
			; p[1] is peak frequency	
			; p[2] is alpha_thick
			; p[3] is alpha_thin

			;pi = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]}, 2)
			;pi(0).limited(0) = 1
			;pi(0).limits(0) = 0.0
			;pi(1).limited(0) = 1
			;pi(1).limits(0) = 40
			;pi(2).limited(0) = 1
			;pi(2).limits(0) = 40
			;pi(3).limited(0) = 1
			;pi(3).limits(0) = 2.0


			p = mpfitexpr(fit, freq, flux, err, yfit=yfit, start, bestnorm=bestnorm, dof=dof, perror=perror)	

			freq_sim = (findgen(100)*(freq[n_elements(freq)-1] - freq[0])/99.) + freq[0]

			flux_sim = ( p[0]*(freq_sim/p[1])^p[2] ) * ( 1.0 - exp( -1.0*(freq_sim/p[1])^(p[3]-p[2]) ) )		
			;if p[2] ge 1.5 and p[2] le 4.0 and p[3] ge -4.0 and nrh_time lt anytim('2014-09-01T11:04:00', /utim)  $
			;if p[2] le 3.0 and flux[n_elements(flux)-1] gt 1.5 and nrh_time lt anytim('2014-09-01T11:03:20', /utim) then begin
			if nrh_time gt anytim('2014-09-01T11:01:40', /utim)	and nrh_time lt anytim('2014-09-01T11:03:10', /utim) then begin

			;if nrh_time eq anytim('2014-09-01T11:01:40.040', /utim) or $
			 ;  nrh_time eq anytim('2014-09-01T11:02:20.540', /utim) or $
			  ; nrh_time eq anytim('2014-09-01T11:02:55.640', /utim) then begin
					print, anytim(nrh_time, /cc)

					loadct, 0, /silent
					PLOTSYM, 0
					if started eq 0 then $
					plot, freq, flux, $
						/ys, $
						/xs, $
						/ylog, $
						/xlog, $
						psym=8, $
						yr = [1.0, 1e3], $
						xr=[1e1, 1e4], $
						;title=anytim(nrh_time, /cc), $
						xtitle='Frequency (MHz)', $
						ytitle='Flux Density (SFU)', $
						/noerase $
					else oplot, freq, flux, psym=8, color = colors[colors_index]

					loadct, 74, /silent
					;oplot, freq, flux, linestyle=2, color = colors[colors_index], thick=4

					oploterror, freq, flux, err, psym=8
					;
					oplot, freq_sim, flux_sim, color = colors[colors_index], thick=4s

					print, flux[n_elements(flux)-1]

					;print, 'alpha_thick is: '+string(p[2], format='(f4.2)')+' +/- '+string(perror[2], format='(f4.2)')
					;print, 'alpha_thin is: '+string(p[3], format='(f5.2)')+' +/- '+string(perror[3], format='(f5.2)')

					perror = perror*SQRT(bestnorm / dof) 

					if started eq 0 then begin
						peak_freq = p[1] 
						alpha_thick = p[2]
						alpha_thin = p[3]
						alpha_thin_times = nrh_time

						alpha_thick_err = perror[2]
						alpha_thin_err = perror[3]
					endif else begin
						peak_freq = [peak_freq, p[1]] 
						alpha_thick = [alpha_thick, p[2]] 
						alpha_thin = [alpha_thin, p[3]] 
						alpha_thin_times = [alpha_thin_times, nrh_time]

						alpha_thick_err = [alpha_thick_err, perror[2]] 
						alpha_thin_err = [alpha_thin_err, perror[3]] 
					endelse	
				

					started = 1
					colors_index = colors_index+1
	
			endif	


	endfor
	;window, 20, xs=600, ys=600
	;plothist_new, alpha_thick, /auto, color=4
	print, string(mean(alpha_thick))+' +/- '+string(mean(alpha_thick_err))
	print, string(mean(alpha_thin))+' +/- '+string(mean(alpha_thin_err))

	scaled_errs = alpha_thin_err
	save, alpha_thin, scaled_errs, alpha_thin_times, filename='/Users/eoincarley/data/2014_sep_01/fermi/e_spec_index_radio.sav'
	if keyword_set(postscript) then begin
		device, /close
		spawn,'open ~/Data/2014_sep_01/radio/'
		set_plot, 'x'
	endif	
STOP

END	