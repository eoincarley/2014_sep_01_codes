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


function paulo_gyro, freqs, params ;Bfield, Del, ener2, Ang
	
	;/////////////////////////////////
	; These expressions were put here by Eoin Carley. 
	; To reduce the dynamic range of fitting paramaters
	;nel = 10^nel   
	;np = 10^np
	;energy[1] = 10^energy[1]
	;angle=angle*10.0
	;/////////////////////////////////

	f = 10^freqs
	gyro, f, flux_model, $
			bmag=params[0], $
			nel=10^params[1], $
			np=10^params[2], $
			delta=params[3], $	
			ener=[10., 10^params[4]], $
			angle=params[5], $
			anor=7.8e30, $
			size=200, $
			hei=2.07e10

	return, alog10(flux_model)

END	

pro nrh_rstn_flux_spect_gyro_model, postscript=postscript

	; Apapdted fromt nrh_rstn_flux_spect_plot_20140901.pro
	

	!p.charsize=1.5
	loadct, 39
	window, 10, xs=600, ys=600, xpos=1950, ypos=1000, retain=2
	restore, '~/Data/2014_sep_01/radio/rstn_flux_sh_20140901.sav', /verb	
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

	sv_rstn_times = nrh_rstn_flux.rstn_times
	sv_rstn_fluxes = nrh_rstn_flux.rstn_flux
	sv_rstn_freq = nrh_rstn_flux.rstn_freq

	sh_rstn_times = sh_rstn_flux.rstn_times
	sh_rstn_fluxes = sh_rstn_flux.rstn_flux
	sh_rstn_freq = sh_rstn_flux.rstn_freq


	start_index = 4		; Only choose frequencies > freq[4]
	colors = (findgen(150)*255)/(89.);[0, 50, 240];(findgen(3)*255)/(2.)
	colors_index = 0

	if keyword_set(postscript) then setup_ps, '~/Data/2014_sep_01/radio/nrh_rstn_spectrum_TEST_20140901.eps'

	started=0
	anor=7.8966100e+30
	freq_model=10^interpol(alog10([0.01,20]*1e9),50)
	freq_model = alog10(freq_model)
	rsun = 6.9e10	    ; cm
	Lradio = 0.3*rsun
	cd,'~/idl/gyro/'

	for i=100, n_elements(nrh_times)-1, 10 do begin

		;/////////////////////////////////////////////////////////////////
		;					Arrange flux density values
		;
		freq = [nrh_freq, sh_rstn_freq]
		freq = freq[start_index:n_elements(freq)-1]
		nrh_time = nrh_times[i]

		if nrh_time gt anytim('2014-09-01T11:01:40', /utim)	and nrh_time lt anytim('2014-09-01T11:03:10', /utim) then begin

			nrh_flux = nrh_fluxes[i, *]	;step through time
			nrh_flux = transpose(nrh_flux)
			nrh_errs = 2.0*nrh_flux*stdevs/100.0 + nrh_flux*0.1 ; +20 percent for NRH instrument SFU uncertainty

			rstn_index = closest(sv_rstn_times, nrh_time)
			sv_rstn_time = sv_rstn_times[rstn_index]
			sv_rstn_flux = sv_rstn_fluxes[rstn_index, *]
			sv_rstn_flux = transpose(sv_rstn_flux)
			sv_rstn_errs = sv_rstn_flux*0.2

			rstn_index = closest(sh_rstn_times, nrh_time)
			sh_rstn_time = sh_rstn_times[rstn_index]
			sh_rstn_flux = sh_rstn_fluxes[rstn_index, *]
			sh_rstn_flux = transpose(sh_rstn_flux)
			sh_rstn_errs = sh_rstn_flux*0.2


		    rstn_fluxes = [sh_rstn_flux[0], $
						   mean( [sh_rstn_flux[1], sv_rstn_flux[0]] ), $	; Could use an average of the SV and SH sites, but SH background is highly variable.
						   mean( [sh_rstn_flux[2], sv_rstn_flux[1]] ), $	; SV is more reliable.
						   mean( [sh_rstn_flux[3], sv_rstn_flux[2]] ) ]


			flux = [nrh_flux, rstn_fluxes];, transpose(sh_rstn_flux)]
			err=[nrh_errs, sh_rstn_errs]  ;, transpose(sh_rstn_errs)]

			flux = flux[start_index:n_elements(flux)-1]
			err = err[start_index:n_elements(err)-1]


			; Work in log space

			loadct, 0, /silent
			PLOTSYM, 0
			plot, freq, flux, $
				/ys, $
				/xs, $
				/ylog, $
				/xlog, $
				psym=8, $
				yr = [1.0, 1e2], $
				xr=[1e2, 1e4], $
				title=anytim(nrh_time, /cc), $
				xtitle='Frequency (MHz)', $
				ytitle='Flux Density (SFU)', $
				;/noerase, $
				color=255 ;$
			;else oplot, freq, flux, psym=8, color = 255;colors[colors_index]

			oploterror, freq, flux, err, psym=8, color=255

			;-----------------------------------------------------------------;
			;			Switch to working with logged values so 
			;			fitting routines don't have to work with
			;			large dynamic ranges.
			;
			freq = alog10(freq*1e6)
			flux = alog10(flux)
			err = alog10(err)


			;/////////////////////////////////////////////////////////////////
			;
			;		 First perform a fit of the paramateric function
			;
			;start = double([30.0, 1000.0, 2.0, -2.0])
			;fit = '( p[0]*(x/p[1])^p[2] ) * ( 1.0 - exp( -1.0*(x/p[1])^(p[3]-p[2]) ) )'		
			;p = mpfitexpr(fit, freq, flux, err, yfit=yfit, start, bestnorm=bestnorm, dof=dof, perror=perror)	
			;freq_sim = (findgen(100)*(freq[n_elements(freq)-1] - freq[0])/99.) + freq[0]
			;flux_sim = ( p[0]*(freq_sim/p[1])^p[2] ) * ( 1.0 - exp( -1.0*(freq_sim/p[1])^(p[3]-p[2]) ) )		
			;loadct, 74, /silent
			;oplot, freq_sim, flux_sim, color = 255, thick=4

			;/////////////////////////////////////////////////////////
			;			Now introduce Paulo's gyro model 
			;
			;----------------------------------------------------;
			; These values provide a moderately good fit by eye. 
			; Razin supression. Source sizes VERY small.
			;bmag=14.0, $
			;size=25, $
			;hei=Lradio, $
			;nel=1e6, $
			;np=6.6e8, $
			;delta=3.2, $;,nel=4e4 $
			;ener=[30., 3500.0], $
			;anor=anor, $
			;angle=70.0, $
			;m=145, $
			;alpha=1.0

			;----------------------------------------------------;
			; These values provide a moderately good fit by eye.
			; No Razin supression.
			;bmag=3.6, $
			;size=200, $
			;hei=Lradio, $
			;nel=2.1e6, $
			;np=1.6e8, $
			;delta=3.1, $;,nel=4e4 $
			;ener=[10., 6500.0], $
			;anor=anor, $
			;angle=80.0;
			;----------------------------------------------------;


			;/////////////////////////////////////////////////////
			; 			Use the model to produce a fit
			;
			;if i eq 120 then start = [3.4, 6.28, 8.15, 3.1, 3.84, 78.0] else $
			start = [3.0, 6.28, 8.15, 3.1, 3.84, 78.0]	;[p[0], p[1], p[2], p[3], p[4], p[5]]

				;fit = 'paulo_gyro(x, p)'	
				;p = mpfitexpr(fit, freq*1e6, flux, err, yfit=yfit, start, bestnorm=bestnorm, dof=dof, perror=perror)	

			pi = replicate({value:0.D, step:0.D, fixed:0, limited:[0,0], $
	                      limits:[0.D,0]}, 6)	

			pi[*].value = start
			pi[0].step = 1	;Large step sizes in solution space for these params.
			;pi[1].step = 1
			pi[3].step = 1
			;pi[4].step = 1
			pi[5].step = 1
			pi[5].limited(0) = 1
			pi[5].limits(0) = 70.0

			p = mpfitfun('paulo_gyro', freq, flux, err, parinfo=pi, bestnorm=bestnorm, dof=dof, perror=perror, errmsg=errmsg)
	 
			gyro, 10^freq_model, flux_model, $
				bmag=p[0], $
				nel=10^p[1], $
				np=10^p[2], $
				delta=p[3], $	
				ener=[10., 10^p[4]], $
				angle=p[5], $
				anor=anor, $
				size=200, $
				hei=Lradio

			set_line_color
			oplot, (10^freq_model)/1e6, flux_model, thick=2, linestyle=3, color=4
		
			loadct, 0
			legend, ['B (G): '+string(p[0], format='(f7.2)'), $
					 'Nel (cm^-3): '+string(10^p[1], format='(e10.2)'), $
					 'Np (cm^-3): '+string(10^p[2], format='(e10.2)'), $
					 'delta: '+string(p[3], format='(f7.2)'), $
					 'Low energy (keV): '+ string([10], format='(f7.2)'), $
					 'High energy (keV): '+ string(10^p[4], format='(f7.2)'), $
					 'angle (deg): '+string(p[5], format='(f7.2)'), $
					 'Src size (Rsun): '+string(0.2, format='(f3.1)'), $
					 'Src depth (Rsun): '+string(0.3, format='(f3.1)') ], $
					 color=[replicate(255, 8)], $
					 box=0, $
					 /left, $
					 /top

			;////////////////////////////////////////////////////////


			;print, 'alpha_thick is: '+string(p[2], format='(f4.2)')+' +/- '+string(perror[2], format='(f4.2)')
			;print, 'alpha_thin is: '+string(p[3], format='(f5.2)')+' +/- '+string(perror[3], format='(f5.2)')

			;perror = perror*SQRT(bestnorm / dof) 

			if started eq 0 then begin
				parms = [ nrh_time, p ]
				errors = [ nrh_time, perror]
				started=1
			endif else begin
				parms = [ [parms], [nrh_time, p]  ]
				errors = [ [errors], [nrh_time, perror] ]
			endelse	

		endif
		;x2png, '~/Data/2014_sep_01/radio/gyro_fits/image_'+string(i, format='(I3)')+'.png'
		wait, 1.0
	endfor

	if keyword_set(postscript) then begin
		device, /close
		spawn,'open ~/Data/2014_sep_01/radio/'
		set_plot, 'x'
	endif	
STOP

END	