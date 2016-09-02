pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.5
   !p.thick=4
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=7, $
          ysize=7, $
          bits_per_pixel=16, $
          /encapsulate, $
          yoffset=5

end

pro plot_spex_fermi_gbm, postscript=postscript

	if keyword_set(postscript) then setup_ps, '~/fermi_gbm_flux.eps'

	;window, 10, xs=700, ys=700
	loadct, 0
	;!p.charsize=1.5
	;!p.thick=2
	pos=[0.20, 0.22, 0.98, 0.95]
	times = anytim('2014-09-1T10:54:00') + dindgen(400)
	yr = [1e-3, 500.0]


	;----------------------------------------------;
	;				FEMRI GBM
	;
	obj=ospex(/no_gui)
	obj-> set, $                                                                               
	spex_specfile= '~/Data/2014_sep_01/fermi/glg_cspec_n5_bn140901462_v00.pha'
	obj-> set, spex_accum_time= [' 1-Sep-2014 10:54:00.000', ' 1-Sep-2014 11:11:00.000']       
	obj-> set, spex_bk_time_interval=[' 1-Sep-2014 10:54:00.000', ' 1-Sep-2014 10:56:00.000']  
	obj-> set, spex_eband= [[4.5000000D, 10.000000D]];, $
	obj->plot, class='spex_bksub', spex_units='flux', color=1, yrange=yr, /ys, xstyle=1, position=pos, title=' ', xtitle='Time (UT)';, xtitle='Time (UT)', title=' '
	set_line_color
	obj-> set, spex_eband= [[10.000000D, 15.000000D]]
	obj->plot, class='spex_bksub', spex_units='flux', color=7, yrange=yr, /ys,  xstyle=1, /noerase, position=pos, ytickformat='(A1)', xtickformat='(A1)', xtitle=' ', ytitle=' ', title=' '
	obj-> set, spex_eband= [[15.000000D, 20.000000D]]
	obj->plot, class='spex_bksub', spex_units='flux', color=4, yrange=yr, /ys, xstyle=1, /noerase, position=pos, ytickformat='(A1)', xtickformat='(A1)', xtitle=' ', ytitle=' ', title=' '
	obj-> set, spex_eband= [[20.000000D, 30.000000D]]
	obj->plot, class='spex_bksub', spex_units='flux', color=10, yrange=yr, /ys, xstyle=1, /noerase, position=pos, ytickformat='(A1)', xtickformat='(A1)', xtitle=' ', ytitle=' ', title=' '
	obj-> set, spex_eband= [[30.000000D, 40.000000D]]
	obj->plot, class='spex_bksub', spex_units='flux', color=0, thick=5, yrange=yr, /ys, xstyle=1, /noerase, position=pos, ytickformat='(A1)', xtickformat='(A1)', xtitle=' ', ytitle=' ', title=' '
	obj->plot, class='spex_bksub', spex_units='flux', color=2, yrange=yr, /ys, xstyle=1, /noerase, position=pos, ytickformat='(A1)', xtickformat='(A1)', xtitle=' ', ytitle=' ', title=' '
	obj-> set, spex_eband= [[40.000000D, 50.000000D]]
	obj->plot, class='spex_bksub', spex_units='flux', color=3, yrange=yr, /ys, xstyle=1, /noerase, position=pos, ytickformat='(A1)', xtickformat='(A1)', xtitle=' ', ytitle=' ', title=' '


	;----------------------------------------------;
	;				Orfees flux plot
	;
	orfees_folder = '~/Data/2014_sep_01/radio/orfees/'
	restore, orfees_folder+'orf_20140901_bsubbed_minimum.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = reverse(orfees_struct.freq)
	index = closest(orf_freqs, 445.0)
	orf_frequency_str = string(round(orf_freqs[index]), format='(I03)')
	orfees_flux = smooth(orf_spec[*, index], 10)
	outplot, anytim(orf_time, /yoh), smooth(orfees_flux, 5)*40.0, color=5, psym=10


	if keyword_set(postscript) then device, /close

	set_plot, 'x'

STOP
END