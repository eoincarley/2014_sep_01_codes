pro read_goes, goes_array
  
	file = '~/Data/2014_sep_01/goes/20140901_Gp_xr_1m.txt'

	readcol, file, y, m, d, hhmm, mjd, sod, short_channel, long_channel;, $
	      format = 'A, A, A, A, A, A, L, L'


	;-------- Time in correct format --------
	time  = strarr(n_elements(y))
	time[*] = string(y[*], format='(I04)') + string(m[*], format='(I02)') $
			  + string(d[*], format='(I02)') + '_' + string(hhmm[*], format='(I04)')
	time = anytim(file2time(time), /utim)

	;------- Build data array --------------

	goes_array = dblarr(3, n_elements(y))
	goes_array[0,*] = time
	goes_array[1,*] = long_channel
	goes_array[2,*] = short_channel
  
  
END  

pro plot_goes, time0, time1
	
	loadct, 0
	window, 0
	x0 = 0.07
	x1 = 0.95
	
	xstart = anytim(file2time( time0 ),/utim)
    xend = anytim(file2time( time1 ),/utim)

	read_goes, goes_data

	set_line_color
	utplot, goes_data[0,*], goes_data[1,*], $
		/ylog, $
		xr = [xstart, xend], $
		/xs, $
		thick = 4, $
		yrange = [1e-9, 1e-3], $
		xtitle='Start Time (2014-Sep-01 10:30:00 UT)', $
		position = [x0, 0.7, x1, 0.99], $
		color = 3


	xyouts, 0.03, 0.82, 'Watts m!U-2!N', /normal, orientation=90
	axis,yaxis=1,ytickname=[' ','A','B','C','M','X', ' ']

	oplot, goes_data[0,*], goes_data[2,*], $
	    color=5, $
	    thick=4

	t1 = anytim(file2time( time0 ), /utim)
	t2 = anytim(file2time( time1 ), /utim)
	indices = where(goes_data[0,*] gt t1 and goes_data[0,*] lt t2)
	plots, goes_data[0, indices], 1e-6, thick=1, color=0
	plots, goes_data[0, indices], 1e-5, thick=1, color=0
	plots, goes_data[0, indices], 1e-4, thick=1, color=0

	legend, ['GOES15 0.1-0.8 nm', 'GOES15 0.05-0.4 nm'],$
	    linestyle=[0,0], $
	    color=[3, 5], $
	    box=0, $
	    pos=[0.13, 0.99], $
	    /normal
	


END