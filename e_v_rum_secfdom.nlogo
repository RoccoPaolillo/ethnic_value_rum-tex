globals [
  percent-similar-eth
  percent-similar-val
]

patches-own [
  systemic_utility
]


to setup
  clear-all
  ask patches [set pcolor white
   if random 100 < density [sprout 1
     [

  if relative_size = "ethnic"   [   ifelse random 100 < %majority
      [set color blue
       set shape ifelse-value (random 100 < %liberal_maj) ["circle"]["square"]          ; attributes of agents
     ]

      [set color orange
       set shape ifelse-value (random 100 < %liberal_min) ["circle"]["square"]
     ]
        ]


  if relative_size = "value" [ ifelse random 100 < %majority
      [set color blue
       set shape ifelse-value (random 100 < %liberal_maj) ["circle"]["square"]          ; attributes of agents
      ]

      [set color orange
        set shape ifelse-value (random 100 < (100 - %liberal_maj)) ["circle"]["square"]
      ]
        ]




     ]
    ]
  ]
;  update-globals
  reset-ticks
 end




to go
  move-turtles       ; relocation decision of turtles
 ; update-globals
tick
end


to move-turtles          ; here the relocation decision, with the beta distribution

  ask  turtles [

    let dom ifelse-value (dominant_distribution = "global") [dominant]
    [ifelse-value (dominant_distribution = "by-value")
      [
        ifelse-value (shape = "square") [con_eth][lib_val]
      ][
        ifelse-value (shape = "square")
        [ ifelse-value (color = blue) [eth_con_maj][eth_con_min]]
        [ ifelse-value (color = blue) [val_lib_maj][val_lib_min]]
      ]
    ]

    let sec ifelse-value (secondary_distribution = "global") [secondary]
    [ifelse-value (secondary_distribution = "by-value")
      [
        ifelse-value (shape = "square") [con_val][lib_eth]
      ][
    ifelse-value (shape = "square")
        [ifelse-value (color =  blue) [val_con_maj][val_con_min]]
        [ifelse-value (color = blue) [eth_lib_maj][eth_lib_min]]
      ]

    ]


    let beta-ie ifelse-value (shape = "square") [dom][dom * sec]
    let beta-iv ifelse-value (shape = "square") [dom * sec][dom]

   let color-myself color
   let shape-myself shape
   let alternative one-of patches with [not any? turtles-here]   ; one empty cell is selected as alternative
   let trial random-float 1.00  ; random number to compare to probability to move to alternative

    let options (patch-set patch-here alternative)   ; the basket choice made of current patch and alternative: at this point, it is just to not rewrite utility attribution for
                                                     ; current patch and alternative

    ask options [

      let xe count (turtles-on neighbors) with [color = color-myself]
      let xv count (turtles-on neighbors) with [ shape = shape-myself]

      let n count (turtles-on neighbors)

      let uti-eth  utility xe n    ; value utility and ethnic utility of each option
      let uti-val  utility xv n

      set systemic_utility ((beta-ie * uti-eth) + (beta-iv * uti-val)) ; just to simplify and not repeat for each option
    ]

    let proba (1 / (1 + exp([systemic_utility] of patch-here - [systemic_utility] of alternative))) ; Kenneth Train (2009) p.39 shows how this is the binary logit as simplification of
                                                                                                  ; softmax function (exp(beta*U)/Sum(exp(beta*U)) for 2 options (as probability to move to alternative)
                                                                                                  ; (https://eml.berkeley.edu/books/choice2nd/Ch03_p34-75.pdf)

    if trial <  proba [move-to alternative] ; if probability calculated is higher than trial number [0,1], then the agent relocates  to alternative

  ]

end


to-report utility [sim tot]  ; utility function: sim = number similar (neighborhood moore); tot = total number agents in Moore distance

 report ifelse-value (tot = 0) [0]     ; utility 0 for not any turtle on neighbor
   [ precision (sim / tot) 3 ]        ; utility is computed as fraction (1 is max)

 end

;to update-globals
;  let similar-eth sum [ count (turtles-on neighbors) with [color = [color] of myself] ] of turtles
;  let similar-val sum [ count (turtles-on neighbors) with [shape = [shape] of myself] ] of turtles
;  let total-neighbors sum [ count (turtles-on neighbors)  ] of turtles
;  set percent-similar-eth (similar-eth / total-neighbors)
;  set percent-similar-val (similar-val / total-neighbors)
;end

to-report	et_gl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]	end
to-report	et_sq	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square"]	end
to-report	et_cl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle"]	end
to-report	et_bl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = blue]	end
to-report	et_or	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = orange]	end
to-report	et_sq_bl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square" and color = blue]	end
to-report	et_cl_bl	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle" and color = blue]	end
to-report	et_sq_or	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square" and color = orange]	end
to-report	et_cl_or	report	mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle" and color = orange]	end


to-report	vl_gl	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1]	end
to-report	vl_sq	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square"]	end
to-report	vl_cl	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle"]	end
to-report	vl_bl	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = blue]	end
to-report	vl_or	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and color = orange]	end
to-report	vl_sq_bl	report	mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square" and color = blue]	end
to-report	vl_cl_bl	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "circle" and color = blue]	end
to-report	vl_sq_or	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = "square" and color = orange]	end
to-report	vl_cl_or	report	mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and  shape = "circle" and color = orange]	end

to-report	den_gl	report	mean [count (turtles-on neighbors)] of turtles / 8	end
to-report	den_sq	report	mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8	end
to-report	den_cl	report	mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8	end
to-report	den_bl	report	mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8	end
to-report	den_or	report	mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8	end
to-report	den_sq_bl	report	mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8	end
to-report	den_sq_or	report	mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8	end
to-report	den_cl_bl	report	mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8	end
to-report	den_cl_or	report	mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8	end

to-report	cls_et_sq_bl	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) >= 1]	end
to-report	cls_et_cl_bl	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) >= 1]	end
to-report	cls_et_sq_or	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) >= 1]	end
to-report	cls_et_cl_or	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) >= 1]	end
to-report	cls_et_bl	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) >= 1]	end
to-report	cls_et_or	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) >= 1]	end
to-report	cls_et_sq	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) >= 1]	end
to-report	cls_et_cl	report	mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) >= 1]	end

to-report	cls_vl_sq_bl	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) >= 1]	end
to-report	cls_vl_cl_bl	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) >= 1]	end
to-report	cls_vl_sq_or	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) >= 1]	end
to-report	cls_vl_cl_or	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) >= 1]	end
to-report	cls_vl_bl	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) >= 1]	end
to-report	cls_vl_or	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) >= 1]	end
to-report	cls_vl_sq	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) >= 1]	end
to-report	cls_vl_cl	report	mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) >= 1]	end

to-report	cls_den_sq_bl	report	((mean [ count (turtles-on neighbors)] of turtles with [ color = blue and shape = "square"] / 8 ) / (count turtles /  count patches))	end
to-report	cls_den_cl_bl	report	((mean [ count (turtles-on neighbors)] of turtles with [ color = blue and shape = "circle"] / 8 ) / (count turtles /  count patches))	end
to-report	cls_den_sq_or	report	((mean [ count (turtles-on neighbors)] of turtles with [ color = orange and shape = "square"] / 8 ) / (count turtles /  count patches))	end
to-report	cls_den_cl_or	report	((mean [ count (turtles-on neighbors)] of turtles with [ color = orange and shape = "circle"] / 8 ) / (count turtles /  count patches))	end
to-report	cls_den_bl	report	((mean [ count (turtles-on neighbors)] of turtles with [ color = blue] / 8 ) / (count turtles /  count patches))	end
to-report	cls_den_or	report	((mean [ count (turtles-on neighbors)] of turtles with [ color = orange] / 8 ) / (count turtles /  count patches))	end
to-report	cls_den_sq	report	((mean [ count (turtles-on neighbors)] of turtles with [ shape = "square"] / 8 ) / (count turtles /  count patches))	end
to-report	cls_den_cl	report	((mean [ count (turtles-on neighbors)] of turtles with [ shape = "circle"] / 8 ) / (count turtles /  count patches))	end
@#$#@#$#@
GRAPHICS-WINDOW
325
10
800
486
-1
-1
9.16
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

SLIDER
117
10
215
43
density
density
0
99
70.0
1
1
NIL
HORIZONTAL

SLIDER
218
11
320
44
%majority
%majority
50
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
668
491
731
524
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
735
491
798
524
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
118
47
215
80
%liberal_maj
%liberal_maj
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
219
48
318
81
%liberal_min
%liberal_min
0
100
20.0
1
1
NIL
HORIZONTAL

MONITOR
1005
475
1084
520
% lib maj
count turtles with [shape = \"circle\" and color = blue] / count turtles
2
1
11

MONITOR
1005
525
1083
570
% con maj
count turtles with [shape = \"square\" and color = blue] / count turtles
2
1
11

MONITOR
1092
476
1173
521
% lib min
count turtles with [shape = \"circle\" and color = orange] / count turtles
2
1
11

MONITOR
1091
524
1173
569
% con min
count turtles with [shape = \"square\" and color = orange] / count turtles
2
1
11

MONITOR
909
473
995
518
%liberal
count turtles with [shape = \"circle\"] / count turtles
2
1
11

SLIDER
97
368
198
401
eth_con_maj
eth_con_maj
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
95
471
194
504
val_lib_maj
val_lib_maj
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
96
508
193
541
eth_lib_maj
eth_lib_maj
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
97
407
197
440
val_con_maj
val_con_maj
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
222
371
317
404
eth_con_min
eth_con_min
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
219
507
317
540
eth_lib_min
eth_lib_min
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
221
471
316
504
val_lib_min
val_lib_min
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
221
407
318
440
val_con_min
val_con_min
0
1
0.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
127
342
170
360
majority
11
0.0
1

TEXTBOX
252
340
291
358
minority
11
0.0
1

TEXTBOX
79
447
329
465
-------------------------------------------------------------
10
0.0
1

TEXTBOX
208
331
223
558
|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|
7
0.0
1

TEXTBOX
19
420
82
438
conservatives
10
0.0
1

TEXTBOX
26
502
63
520
liberals
10
0.0
1

SLIDER
96
167
188
200
dominant
dominant
0
20
16.0
1
1
NIL
HORIZONTAL

CHOOSER
18
98
161
143
dominant_distribution
dominant_distribution
"global" "by-value" "group-type"
0

SLIDER
125
232
217
265
con_eth
con_eth
0
20
7.0
1
1
NIL
HORIZONTAL

SLIDER
226
271
318
304
lib_eth
lib_eth
0
1
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
125
271
217
304
con_val
con_val
0
1
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
226
233
318
266
lib_val
lib_val
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
204
167
296
200
secondary
secondary
0
1
0.6
0.1
1
NIL
HORIZONTAL

PLOT
812
26
1088
201
conservative local
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = blue]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = \"square\" and count (turtles-on neighbors) >= 1]\n]"
"value" 1.0 0 -10899396 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = blue]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = \"square\" and count (turtles-on neighbors) >= 1]\n]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\"  and color = blue] / 8"

PLOT
1088
26
1342
201
conservative minority
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "if visualize = \"exposure\"[\nplot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = orange]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = \"square\" and count (turtles-on neighbors) >= 1]\n]"
"value" 1.0 0 -10899396 true "" "if visualize = \"exposure\"[\nplot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = orange]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = \"square\" and count (turtles-on neighbors) >= 1]\n]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\"  and color = orange] / 8"

PLOT
812
202
1087
371
liberal local
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = blue]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = \"circle\" and count (turtles-on neighbors) >= 1]\n]"
"value" 1.0 0 -10899396 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = blue]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = \"circle\" and count (turtles-on neighbors) >= 1]\n]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\"  and color = blue] / 8"

PLOT
1088
204
1340
372
liberal minority
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = orange]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = \"circle\" and count (turtles-on neighbors) >= 1]\n]"
"value" 1.0 0 -10899396 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = orange]\n]\nif visualize = \"spatial sorting\" [\nplot mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = \"circle\" and count (turtles-on neighbors) >= 1]\n]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\"  and color = orange] / 8"

CHOOSER
818
377
959
422
visualize
visualize
"exposure" "spatial clustering"
0

TEXTBOX
12
10
101
55
Initialization demographics
11
0.0
1

TEXTBOX
23
163
90
198
beta global distribution
11
0.0
1

TEXTBOX
21
244
106
293
beta value-orientation distribution
11
0.0
1

TEXTBOX
19
329
93
375
beta group-type distribution
11
0.0
1

TEXTBOX
21
214
327
232
--------------------------------------------------------------------------------------------------------------------------------------------------------
6
0.0
1

TEXTBOX
13
308
318
326
--------------------------------------------------------------------------------------------------------------------------------------------------------
6
0.0
1

CHOOSER
167
97
317
142
secondary_distribution
secondary_distribution
"global" "by-value" "group-type"
0

CHOOSER
350
494
488
539
relative_size
relative_size
"ethnic" "value"
1

MONITOR
1005
423
1085
468
%majority
count turtles with [color = blue] / count turtles
2
1
11

MONITOR
1091
425
1174
470
%minority
count turtles with [color = orange] / count turtles
2
1
11

MONITOR
908
522
994
567
%conservative
count turtles with [shape = \"square\"] / count turtles
2
1
11

@#$#@#$#@
# What is new

secondary preference is a dependent function of dominant preference:

Secondary preference = *ß dominant * s*

with s [0,1]

Example: 
s = 0: Secondary preference is 0
s = 1: Secondary preference is as equal as dominant preference
s = 0.5: Secondary preference = (dominant preference / 2)

# How to use it


* beta_distribution chooser: for distribution of dominant preference globally, by value-orientation or by group-type (value orientation X ethnicity)

* For each selection: top parameter: ß dominant, bottom parameter: s seconadary

** Experiment secfdom
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="ethnicsize" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_gl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_gl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relative_size">
      <value value="&quot;ethnic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary_distribution">
      <value value="&quot;group-type&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualize">
      <value value="&quot;exposure&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="valuesize" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_gl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_gl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relative_size">
      <value value="&quot;value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary_distribution">
      <value value="&quot;group-type&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualize">
      <value value="&quot;exposure&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="basic" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_gl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_gl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relative_size">
      <value value="&quot;ethnic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualize">
      <value value="&quot;exposure&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_lib" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_gl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_gl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relative_size">
      <value value="&quot;ethnic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="con_eth" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualize">
      <value value="&quot;exposure&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_con" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_gl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_gl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relative_size">
      <value value="&quot;ethnic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
      <value value="20"/>
    </enumeratedValueSet>
    <steppedValueSet variable="lib_val" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualize">
      <value value="&quot;exposure&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="basic_libeth" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_gl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_gl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relative_size">
      <value value="&quot;ethnic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="lib_eth" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualize">
      <value value="&quot;exposure&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="basic_conval" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>et_gl</metric>
    <metric>et_sq</metric>
    <metric>et_cl</metric>
    <metric>et_bl</metric>
    <metric>et_or</metric>
    <metric>et_sq_bl</metric>
    <metric>et_cl_bl</metric>
    <metric>et_sq_or</metric>
    <metric>et_cl_or</metric>
    <metric>vl_gl</metric>
    <metric>vl_sq</metric>
    <metric>vl_cl</metric>
    <metric>vl_bl</metric>
    <metric>vl_or</metric>
    <metric>vl_sq_bl</metric>
    <metric>vl_cl_bl</metric>
    <metric>vl_sq_or</metric>
    <metric>vl_cl_or</metric>
    <metric>den_gl</metric>
    <metric>den_sq</metric>
    <metric>den_cl</metric>
    <metric>den_bl</metric>
    <metric>den_or</metric>
    <metric>den_sq_bl</metric>
    <metric>den_sq_or</metric>
    <metric>den_cl_bl</metric>
    <metric>den_cl_or</metric>
    <metric>cls_et_sq_bl</metric>
    <metric>cls_et_cl_bl</metric>
    <metric>cls_et_sq_or</metric>
    <metric>cls_et_cl_or</metric>
    <metric>cls_et_bl</metric>
    <metric>cls_et_or</metric>
    <metric>cls_et_sq</metric>
    <metric>cls_et_cl</metric>
    <metric>cls_vl_sq_bl</metric>
    <metric>cls_vl_cl_bl</metric>
    <metric>cls_vl_sq_or</metric>
    <metric>cls_vl_cl_or</metric>
    <metric>cls_vl_bl</metric>
    <metric>cls_vl_or</metric>
    <metric>cls_vl_sq</metric>
    <metric>cls_vl_cl</metric>
    <metric>cls_den_sq_bl</metric>
    <metric>cls_den_cl_bl</metric>
    <metric>cls_den_sq_or</metric>
    <metric>cls_den_cl_or</metric>
    <metric>cls_den_bl</metric>
    <metric>cls_den_or</metric>
    <metric>cls_den_sq</metric>
    <metric>cls_den_cl</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="relative_size">
      <value value="&quot;ethnic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="con_val" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualize">
      <value value="&quot;exposure&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
