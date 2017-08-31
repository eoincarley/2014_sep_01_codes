pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.3
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=7.5, $
          ysize=7.5, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end

pro volumes_Bfield, postscript=postscript

	;------------------------------------------------;
	;				Define constants
	;
	EM = 2.0D45 ;0.00022D49
	F = 7.2D53 ;1.02D54
	rsun = 6.9D10	; cm	
	L = 0.042*rsun
	Vth = 1e32	;(4./3.)*!pi*L^3.0
	Vpl = 1e30	;(4./3.)*!pi*(L)^3.0	;1.0*Vth		; N.B Assumes non-thermal volume is the same size as thermal volume.
	delta_thin = 2.9
	E_min = 9.0		; keV
	E_0 = 9.0
	e_mass = 0.511e3	;keV/c 
	;grams

	npoints = 500
	Vth_range = [27, 32]
	Vth_arr = 10.^interpol(Vth_range, npoints)
	Vpl_range = [27, 32]
	Vpl_arr = 10.^interpol(Vpl_range, npoints)

	mag_array = dblarr(npoints, npoints)
	n0_arr = dblarr(npoints)
	nb_arr = dblarr(npoints)
	nth_cutoff_0 = 10.0	; Percent cutoff
	nth_cutoff_1 = 25.0	; Percent cutoff
	nth_cutoff_2 = 50.0	; Percent cutoff
	nth_cutoff_3 = 100.0	; Percent cutoff

	k=0 & l=0 & m=0 & o=0
	for i=0, npoints-1 do begin
		
		;------------------------------------------------;
		;		Calculate thermal electron density
		Vth = Vth_arr[i]
		n0 = sqrt(EM/Vth)
		n0_arr[i]=n0

		for j=0, npoints-1 do begin
			Vpl = Vpl_arr[j]
				
			;------------------------------------------------;
			;		Calculate non-thermal electron density
			n_b = (F/(n0*Vpl))* $
				( (delta_thin-1)/(delta_thin-0.5) )* $
				( E_min^(-0.5) )*$
				( sqrt(e_mass/2.0/3.0e10^2.0) )* $
				( E_0/E_min)^(delta_thin-1.0 )

			nb_arr[j]=n_b

			;----------------------------------------;
			;		Calculate B-field
			calc_B_from_nu, n_b, B_value=B_value

			perc_nontherm = fix(n_b/n0*100)			
			if perc_nontherm eq nth_cutoff_0 then begin
				if k eq 0 then xcutoff0 = i else xcutoff0 = [xcutoff0, i]
				if k eq 0 then ycutoff0 = j else ycutoff0 = [ycutoff0, j]
				k=1
			endif

			if perc_nontherm gt nth_cutoff_1-1.0 and perc_nontherm lt nth_cutoff_1+1.0 then begin
				if l eq 0 then xcutoff1 = i else xcutoff1 = [xcutoff1, i]
				if l eq 0 then ycutoff1 = j else ycutoff1 = [ycutoff1, j]
				l=1
			endif

			if perc_nontherm gt nth_cutoff_2-1.0 and perc_nontherm lt nth_cutoff_2+1.0 then begin
				if m eq 0 then xcutoff2 = i else xcutoff2 = [xcutoff2, i]
				if m eq 0 then ycutoff2 = j else ycutoff2 = [ycutoff2, j]
				m=1
			endif

			if perc_nontherm gt nth_cutoff_3-2.0 and perc_nontherm lt nth_cutoff_3+2.0 then begin
				if o eq 0 then xcutoff3 = i else xcutoff3 = [xcutoff3, i]
				if o eq 0 then ycutoff3 = j else ycutoff3 = [ycutoff3, j]
				o=1
			endif

			; For plotting the value from the gyro model fit
			if B_value gt 5.4 and B_value lt 5.6 and alog10(n0) gt 8.22 and alog10(n0) lt 8.27 then begin
				mag_point_x = i
				mag_point_y = j
			endif

			if B_value gt 7.3 and B_value lt 7.5 and alog10(n0) gt 8.22 and alog10(n0) lt 8.27 then begin
				mag_point_xerr1 = i
				mag_point_yerr1 = j
			endif

			if B_value gt 3.5 and B_value lt 3.7 and alog10(n0) gt 8.22 and alog10(n0) lt 8.27 then begin
				mag_point_xerr2 = i
				mag_point_yerr2 = j
			endif

			if alog10(n0) gt 8.22 and alog10(n0) lt 8.27 and alog10(n_b) gt 6.3 and alog10(n_b) lt 6.5 then begin
				mag_n0nbx = i
				mag_n0nby = j
			endif	



			mag_array[i, j] = B_value
		endfor
	endfor

	loadct, 0
	reverse_ct
	gamma_ct, 0.4
	if keyword_set(postscript) then begin
		setup_ps, '~/volume_Bfield.eps'
	endif else begin
		!p.charsize=1.4
		window, 0, xs=700, ys=700
	endelse

	;---------------------------------------;
	;
	;			Plot the array
	;
	plot_image, alog10(mag_array), $
		xtickformat='(A1)', $
		ytickformat='(A1)', $
		xticklen=1e-6, $
		yticklen=1e-6, $
		position=[0.1, 0.1, 0.85, 0.85], /nodata

	;---------------------------------------;
	;
	;		   Set all the axes	
	;
	set_line_color
	Vth_arr = alog10(Vth_arr)
	n0_arr = alog10(n0_arr)
	indices = [closest(Vth_arr, 27), closest(Vth_arr, 28), closest(Vth_arr, 29), closest(Vth_arr, 30), closest(Vth_arr, 31), closest(Vth_arr, 32)]

	loadct, 0
	axis, xaxis=1, xrange=[ n0_arr[closest(Vth_arr, 27)], n0_arr[closest(Vth_arr, 32)] ], /xs, xticklen = 1.0, xgridstyle = 2.0, xthick=2.0, color=140
	xyouts, 0.4, 0.9, 'log(n!L0!N [cm!U-3!N])', /normal
		;xtickv=50.0, xtickn=string(1., format='(f4.2)'), xtitle='log(n!L0!N [cm!U-3!N])'
	set_line_color
	axis, xaxis=1, xrange=[ n0_arr[closest(Vth_arr, 27)], n0_arr[closest(Vth_arr, 32)] ], /xs, xtitle=' '
	axis, xaxis=0, xrange=Vth_range, xtitle='log(V!L0!N [cm!U3!N])', xticklen = 1.0, xgridstyle = 1.0, xthick=2, color=0
	axis, xaxis=0, xrange=Vth_range, xtitle='log(V!L0!N [cm!U3!N])'
	axis, yaxis=0, yrange=Vpl_range, ytitle='log(V!Lnth!N [cm!U3!N])', yticklen = 1.0, ygridstyle = 1.0, ythick=2, color=0
	axis, yaxis=0, yrange=Vpl_range, ytitle='log(V!Lnth!N [cm!U3!N])'

	;---------------------------------------;
	;
	;		Mark the density cut-offs
	;	
	xlin_index = closest(Vth_arr, Vpl_range[0])
	ylin_index = closest(Vpl_arr, Vth_range[0])
	plots, [xlin_index, npoints-1], [ylin_index, npoints-1], color=7, linestyle=0, /data, thick=8
	plots, xcutoff0, ycutoff0, color=3, linestyle=2, /data, thick=4
	plots, xcutoff1, ycutoff1, color=3, linestyle=2, /data, thick=4
	plots, xcutoff2, ycutoff2, color=3, linestyle=2, /data, thick=4
	plots, xcutoff3, ycutoff3, color=3, linestyle=2, /data, thick=4

	plotsym, 0, /fill
	;plots, mag_n0nbx, mag_n0nby, /data, psym=7, color=7, symsize=2
	plots,  [mag_point_xerr1, mag_point_xerr2],  [mag_point_yerr1, mag_point_yerr2], /data, color=0, thick=7
	plots,  [mag_point_xerr1, mag_point_xerr2],  [mag_point_yerr1, mag_point_yerr2], /data, color=10, thick=6
	plots, mag_point_x, mag_point_y, /data, psym=8, color=0, symsize=1.8
	plots, mag_point_x, mag_point_y, /data, psym=8, color=10, symsize=1.6


	xyouts, xcutoff0[n_elements(xcutoff0)-1]+2.5, $
			ycutoff0[n_elements(ycutoff0)-1]+11.5, $
			'N/n!L0!N', $
			/data, $
			color=3, $
			charsize=1.1

	xyouts, xcutoff0[n_elements(xcutoff0)-1]+2.5, $
			ycutoff0[n_elements(ycutoff0)-1]-4.0, $
			'0.1', $
			/data, $
			color=3, $
			charsize=1.1

	xyouts, xcutoff1[n_elements(xcutoff1)-1]+3.5, $
			ycutoff1[n_elements(ycutoff1)-1]-1.0, $
			'0.25', $
			/data, $
			color=3, $
			charsize=1.1
	
	xyouts, xcutoff2[n_elements(xcutoff2)-1]+3.5, $
			ycutoff2[n_elements(ycutoff2)-1]-1.0, $
			'0.5', $
			/data, $
			color=3, $
			charsize=1.1	

	xyouts, xcutoff3[n_elements(xcutoff3)-1]+2.5, $
			ycutoff3[n_elements(ycutoff3)-1]-1.0, $
			'1.0', $
			/data, $
			color=3, $
			charsize=1.1			

	;---------------------------------------;
	;
	;			Plot contours
	;	
	levs = [5, 10, 15, 20, 30, 40, 50]
	CONTOUR, mag_array, LEVELS = levs, $
		color=1, /overplot, $
		c_charsize = 1.3, $
		c_thick=6, $
		C_ANNOTATION = string(levs, format='(I2)')+' G'

	CONTOUR, mag_array, LEVELS = levs, $
		color=5, /overplot, $
		c_charsize = 1.3, $
		c_thick=5, $
		C_ANNOTATION = string(levs, format='(I2)')+' G'
	
	loadct, 0
	reverse_ct
	gamma_ct, 0.4
	
    cgcolorbar, range = [min(mag_array), max(mag_array)], $
            /vertical, $
            /right, $
            /normal, $
            color=0, $
            /ylog, $
            charsize=1.1, $
            pos = [0.91, 0.1, 0.92, 0.85], $
            title = ' ';, $
            ;FORMAT = '(e10.1)'            
    xyouts, 0.961, 0.63, 'Magentic Field Strength (G)', /normal, orient=270                  

    ;--------------------------------------;
    ;
    index_value = where(mag_array eq 5.0)


	if keyword_set(postscript) then device, /close 
	set_plot, 'x'	

stop
END