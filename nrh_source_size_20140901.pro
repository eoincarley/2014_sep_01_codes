function test_my2Dgauss, x, y, pars

	;This is for use in mpfit2dfun below

	;z = dblarr(n_elements(x),n_elements(y))

	;FOR i = 0, n_elements(x)-1.0 DO BEGIN
	;	FOR j=0, n_elements(y)-1.0 DO BEGIN
	;		T = pars[6]
	;		xp = (x[i]-pars[4])*cos(T) - (y[j]-pars[5])*sin(T)
	;		yp = (x[i]-pars[4])*sin(T) - (y[j]-pars[5])*cos(T)
	;		U = (xp/pars[2])^2.0 + (yp/pars[3])^2.0
	;		z[i,j] = pars[0] + pars[1]*exp(-U/2.0)
	;	ENDFOR
	;ENDFOR	

	xprime = (pars[2]-pars[4])*cos(pars[6]) - (pars[3]-pars[5])*sin(pars[6])
	yprime = (pars[2]-pars[4])*sin(pars[6]) + (pars[3]-pars[5])*cos(pars[6])
	;print, xprime
	;print, yprime

	return, [xprime, yprime]	;z

END

pro nrh_source_size_20140901

	nrh_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid/'	; Different date but it's just for getting cdelt from the header
	nrh_files = findfile(nrh_folder+'*src_properties.sav') 		; Created with nrh_choose_centroid.pro

	freq_index=5
	restore, nrh_files[freq_index], /verb
	times = anytim(XY_ARCS_STRUCT.times, /utim)

	x = dindgen(100)
	y = dindgen(100)

	cd, nrh_folder
		filenames = findfile('*.fts')
		tstart = anytim(file2time('20140901_110000'), /utim)
		t0str = anytim(tstart, /yoh, /trun, /time_only)

		read_nrh, filenames[freq_index], $
			nrh_hdr, $
			nrh_data, $
			hbeg=t0str	


	time0 = anytim(file2time('20140901_110130'), /utim)	;anytim(file2time('20140418_125000'), /utim)	;anytim(file2time('20140418_125546'), /utim)	;anytim(file2time('20140418_125310'), /utim)
	time1 =  anytim(file2time('20140901_110310'), /utim)		
	times = anytim(XY_ARCS_STRUCT.times , /utim)	
	indices = where(times gt time0 and times lt time1)	
	times = times[indices]
	gauss_params = XY_ARCS_STRUCT.gauss_params[*, indices]

	for i=0, n_elements(times)-1 do begin
		params = gauss_params[*, i]
		;if i eq 20 then stop
		resultx = 2.354*params[2] 
		resulty = 2.354*params[3]	;abs(test_my2Dgauss(x, y, params))
		result = sqrt(resultx^2.0 + resulty^2.0)

		source_size = result*nrh_hdr.cdelt1 	;arc_sec nrh_hdr.cdelt1
		source_size_rsun = (source_size*727.0)/6.95e5
		;print, source_size_rsun
		if i eq 0 then sizes = source_size_rsun else sizes = [sizes, source_size_rsun]

	endfor

	for i=0, n_elements(sizes)-1 do begin 
		if sizes[i] gt 1.5 then sizes[i]=sizes[i-1]
	endfor

	utplot, times, smooth(sizes, 10), ytitle='Source size (Rsun)', yr=[0.1, 1.5]

	print, 'Mean source size at '+string(nrh_hdr.freq)+':' +string(mean(sizes[where(sizes gt 0.0)]))+' Rsun'

	STOP


END