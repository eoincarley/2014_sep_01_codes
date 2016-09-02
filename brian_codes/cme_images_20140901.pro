pro cme_images_20140901
	
	window, 10

	folder = '~/Data/2014_sep_01/lasco/'
	cd, folder + 'C2'
	files = findfile('*.fts')

	mreadfits, files[0], hdr, data
	index2map, hdr, data, map
	map.data = (map.data - mean(map.data))/stdev(map.data)

	mask = lasco_get_mask(hdr)
	map.data = map.data*mask
	;print,''
	;print,'Merging c2 and c3 map'
	;c2c3map = merge_map(temporary(c2map), temporary(c3map), /add, use_min=0)
		 
	plot_map, map,  $
		dmin=-5, $
		dmax=5

	stop	
		  

END