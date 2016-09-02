pro real_app_speed

	window, 0, xs=500, ys=500
	!p.charsize=1.2

	angle = findgen(100)*(60.0)/99.0
	c = 2.9e5
	v_app = 0.7*c
	v_real = (c*v_app)/( c*cos(angle*!dtor) + v_app*cos(angle*!dtor)^2.0 )
	;print, 'Real speed: ' + string(v_real/c)

	v_real = v_real/c
	plot, angle, v_real, $
		/xs, $
		/ys, $
		xtitle='Angle to LOS (deg)', $
		ytitle='Real speed (c)'

	min_speed = min(v_real)
	min_angle = angle[ where(v_real eq min(v_real)) ] 

	print, 'Minimum speed possible (c): '+string(min_speed)	
	print, 'LOS angle at minimum speed: '+string(min_angle)	

STOP
END