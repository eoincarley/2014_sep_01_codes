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

pro volumes_Bfield, postscript=postscript

	;------------------------------------------------;
	;				Define constants
	;
	EM = 0.00022D49
	F = 1.02D54
	rsun = 6.9D10	; cm	
	L = 0.042*rsun
	Vth = 1e32	;(4./3.)*!pi*L^3.0
	Vpl = 1e30	;(4./3.)*!pi*(L)^3.0	;1.0*Vth		; N.B Assumes non-thermal volume is the same size as thermal volume.
	delta_thin = 3.3
	E_min = 9.3		; keV
	E_0 = 9.3
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
			test_B_nu, n_b, B_value=B_value

			perc_nontherm = fix(n_b/n0*100)			
			if perc_nontherm eq nth_cutoff_0 then begin;gt nth_cutoff_0-1.0 and perc_nontherm lt nth_cutoff_0+1.0 then begin
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

			mag_array[i, j] = B_value
		endfor
	endfor

	if keyword_set(postscript) then begin
		loadct, 1
		setup_ps, '~/volume_Bfield.eps'
	endif else begin
		loadct, 1
		!p.charsize=1.2
		window, 0, xs=400, ys=400
	endelse

	;---------------------------------------;
	;			Plot the array
	plot_image, mag_array, $
		xtickformat='(A1)', $
		ytickformat='(A1)', $
		xticklen=1e-6, $
		yticklen=1e-6, $
		position=[0.12, 0.12, 0.9, 0.9]

	;---------------------------------------;
	;		   Set all the axes	
	set_line_color
	Vth_arr = alog10(Vth_arr)
	n0_arr = alog10(n0_arr)
	indices = [closest(Vth_arr, 27), closest(Vth_arr, 28), closest(Vth_arr, 29), closest(Vth_arr, 30), closest(Vth_arr, 31), closest(Vth_arr, 32)]
	axis, xaxis=1, xrange=[0,99], xtickv=indices, xtickn=string(n0_arr[indices], format='(f4.2)'), xtitle='log(n!L0!N [cm!U-3!N])'
	axis, xaxis=0, xrange=Vth_range, xtitle='log(V!Lth!N [cm!U3!N])', xticklen = 1.0, xgridstyle = 1.0, xthick=2, color=1
	axis, xaxis=0, xrange=Vth_range, xtitle='log(V!Lth!N [cm!U3!N])'
	axis, yaxis=0, yrange=Vpl_range, ytitle='log(V!Lnth!N [cm!U3!N])', yticklen = 1.0, ygridstyle = 1.0, ythick=2, color=1
	axis, yaxis=0, yrange=Vpl_range, ytitle='log(V!Lnth!N [cm!U3!N])'

	;---------------------------------------;
	;		Mark the density cut-offs
	;	
	xlin_index = closest(Vth_arr, Vpl_range[0])
	ylin_index = closest(Vpl_arr, Vth_range[0])
	plots, [xlin_index, npoints-1], [ylin_index, npoints-1], color=1, linestyle=0, /data, thick=3
	plots, xcutoff0, ycutoff0, color=3, linestyle=2, /data, thick=3
	plots, xcutoff1, ycutoff1, color=3, linestyle=2, /data, thick=3
	plots, xcutoff2, ycutoff2, color=3, linestyle=2, /data, thick=3
	plots, xcutoff3, ycutoff3, color=3, linestyle=2, /data, thick=3


	xyouts, xcutoff0[n_elements(xcutoff0)-1]+1.0, $
			ycutoff0[n_elements(ycutoff0)-1]+8.0, $
			'N/n!L0!N', $
			/data, $
			color=3, $
			charsize=0.8

	xyouts, xcutoff0[n_elements(xcutoff0)-1]+1.0, $
			ycutoff0[n_elements(ycutoff0)-1]-4.0, $
			'0.1', $
			/data, $
			color=3, $
			charsize=0.8

	xyouts, xcutoff1[n_elements(xcutoff1)-1]+2.0, $
			ycutoff1[n_elements(ycutoff1)-1]-1.0, $
			'0.25', $
			/data, $
			color=3, $
			charsize=0.8
	
	xyouts, xcutoff2[n_elements(xcutoff2)-1]+2.0, $
			ycutoff2[n_elements(ycutoff2)-1]-1.0, $
			'0.5', $
			/data, $
			color=3, $
			charsize=0.8	

	xyouts, xcutoff3[n_elements(xcutoff3)-1]+1.0, $
			ycutoff3[n_elements(ycutoff3)-1]-1.0, $
			'1.0', $
			/data, $
			color=3, $
			charsize=0.8			

	;---------------------------------------;
	;			Plot contours
	;	
	CONTOUR, mag_array, LEVELS = [1, 5, 10, 14, 20, 30, 40, 50], $
		color=4, /overplot, $
		C_ANNOTATION = string([1, 5, 10, 14, 20, 30, 40, 50], $
		format='(I2)')+' G', $
		thick=2

	if keyword_set(postscript) then device, /close 
	set_plot, 'x'	

stop
END