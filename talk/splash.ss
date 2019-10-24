#lang at-exp slideshow

;; TODO speaking
;; - explain MAP DOTS when appear
;; - "not trying to decide what's correct, looking for semantic properties that help us compare"

;; Slides for OOPSLA 2019

;; NOTES
;; - color picker https://image-color.com/
;; - pict-abbrevs, additions
;;    mouse-icon
;;    target ?
;;    ....

;; split takeaways into 3 slides?

(require
  file/glob
  "lightbulb.rkt"
  pict pict/convert pict/balloon pict/face
  (prefix-in pict: pict/shadow)
  pict-abbrevs pict-abbrevs/slideshow gtp-pict
  ppict/2
  racket/draw
  racket/list
  racket/string
  racket/format
  scribble-abbrevs/pict
  slideshow/code
  plot/no-gui (except-in plot/utils min* max*)
  (only-in images/icons/symbol check-icon x-icon)
  images/icons/style
  ;images/icons/arrow images/icons/control images/icons/misc images/icons/symbol images/icons/style
)

(define slide-top 4/100)
(define slide-left 2/100)
(define slide-right (- 1 slide-left))
(define slide-bottom 86/100)
(define heading-text-coord (coord slide-left slide-top 'lt))
(define slide-text-left (* 3 slide-left))
(define slide-text-right (- 1 slide-text-left))
(define slide-text-top (* 4 slide-top))
(define slide-text-bottom slide-bottom)
(define slide-text-coord (coord slide-text-left slide-text-top 'lt))
(define slide-text-coord-right (coord slide-text-right slide-text-top 'rt))
(define center-coord (coord 1/2 1/2 'cc))
(define illustration-text-coord (coord 1/2 18/100 'ct))
(define illustration-pict-y 40/100)
(define illustration-pict-coord (coord 1/2 illustration-pict-y 'ct))
(define big-landscape-coord (coord 1/2 slide-text-top 'ct))

(define turn revolution)

(define pico-x-sep (w%->pixels 1/100))
(define tiny-x-sep (w%->pixels 2/100))
(define small-x-sep (w%->pixels 5/100))

(define pico-y-sep (h%->pixels 1/100))
(define tiny-y-sep (h%->pixels 2/100))
(define small-y-sep (h%->pixels 5/100))
(define med-y-sep (h%->pixels 10/100))

;; COLOR
(define racket-red  (hex-triplet->color% #x9F1D20))
(define racket-blue (hex-triplet->color% #x3E5BA9))
(define legend-tan  (hex-triplet->color% #xDBCABB))
(define legend-border-color (hex-triplet->color% #x777777))
(define legend-light-tan (hex-triplet->color% #xFDECDD))
(define land-color (hex-triplet->color% #xFBF6E2))
(define typed-color   (hex-triplet->color% #xF19C4D)) ;; orange
;; #xE59650 #xEF9036
(define untyped-color (hex-triplet->color% #x697F4D)) ;; dark green
;; #x72875C #x708E6D
(define flag-border-color legend-border-color)
(define flag-bg-alpha 0.8)
(define typed-flag-color (hex-triplet->color% #xFFAA5B))
;; #;(color%-update-alpha typed-color flag-bg-alpha)
(define untyped-flag-color (color%-update-alpha untyped-color flag-bg-alpha))
(define program-color (hex-triplet->color% #xABC9CF)) ;; gray/blue
(define sat-color   (color%-update-alpha racket-red 0.1))
(define unsat-color (color%-update-alpha racket-blue 0.1))
(define black (string->color% "black"))
(define q-black (hex-triplet->color% #x333333))
(define white (string->color% "white"))
(define fog-color (color%-update-alpha (hex-triplet->color% #x222222) 0.5))
(define ice-color (hex-triplet->color% #xF3F1F2))
(define transparent (color%-update-alpha white 0))
(define ribbon-color (hex-triplet->color% #xF16F72) #;(color%-update-alpha racket-red 0.65))
(define code-highlight-color racket-blue)
(define code-callout-color (hex-triplet->color% #x8FACFA))
(define flagpole-color (string->color% "Burlywood"))
(define flagpole-border-color (string->color% "Brown"))
(define region-A-color (string->color% "Orchid"))
(define region-B-color (string->color% "Lime"))
(define region-C-color (string->color% "Sky Blue"))
(define region-D-color ribbon-color)
(define optional-color region-A-color)
(define erasure-color optional-color)
(define tag-sound-color region-B-color)
(define full-sound-color region-C-color)
(define complete-monitoring-color region-D-color)
(define bsbc-color (hex-triplet->color% #x95825F))
(define landscape-color (string->color% "LightGoldenrodYellow"))
(define icfp-blue (hex-triplet->color% #x6CBEE4))
(define city-color (hex-triplet->color% #x302E22))
;#xABC9CF ;lite-blue

(define racket-logo.png (build-path "src" "racket-logo2.png"))

(define region-border-width 5)

(define watermark-alpha 0.4)
(define title-font
  #;"ArtNoveauDecadente" #;(fantasy)
  #;"Treasure Map Deadhand" #;(+10 pt ... no too small, only for decorations not for reading)
  #;"Kentucky Fireplace" #;(cute ... very handwriting)
  #;"Copperplate"
  #;"Primitive" #;(damn capitals ... maybe good for T / U)
  #;"Weibei SC" #;ok
  "FHA Modernized Ideal ClassicNC"
  #;"FHA Condensed French NC"
  #;"Plantagenet Cherokee" #;ok
  #;"Lao MN")
(define body-font "Tsukushi A Round Gothic")
(define subtitle-font body-font)
(define subsubtitle-font
  #;"Apple Chancery"
  "Libian SC"
  #;"Tsukushi A Round Gothic"
  #;"Plantagenet Cherokee"
  #;"Roboto Condensed"
  #;"Treasure Map Deadhand")
(define code-font "Inconsolata")
(define lang-font code-font)
(define tu-font title-font)
(define decoration-font title-font)

(define title-size 60)
(define subtitle-size 44) ;;?
(define subsubtitle-size 48)
(define body-size 40)
(define caption-size 40)
(define code-size 28)
(define code-line-sep 4)
(define tu-size 72)
(define big-node-size 120)

(define ((make-string->text #:font font #:size size #:color color) str)
  (colorize (text str font size) color))

(define (make-string->title #:size [size title-size] #:color [color black])
  (make-string->text #:font title-font #:size size #:color color))

(define (make-string->subtitle #:size [size subtitle-size] #:color [color black])
  (make-string->text #:font subtitle-font #:size size #:color color))

(define (make-string->subsubtitle #:size [size subsubtitle-size] #:color [color black])
  (make-string->text #:font subsubtitle-font #:size size #:color color))

(define (make-string->body #:size [size body-size] #:color [color black])
  (make-string->text #:font body-font #:size size #:color color))

(define (make-string->code #:size [size code-size] #:color [color black])
  (make-string->text #:font code-font #:size size #:color color))

(define titlet (make-string->title))
(define small-titlet (make-string->title #:size 42))
(define st (make-string->subtitle))
(define st-blue (make-string->subtitle #:color racket-blue))
(define sbt (make-string->text #:font (cons 'bold subtitle-font) #:size subtitle-size #:color black))
(define sst (make-string->subtitle))
(define sst2 (make-string->subsubtitle #:size (- subsubtitle-size 10)))
(define t (make-string->body))
(define it (make-string->text #:font (cons 'italic body-font) #:size body-size #:color black))
(define bt (make-string->text #:font (cons 'bold body-font) #:size body-size #:color black))
(define ct (make-string->code))
(define bigct (make-string->code #:size (- body-size 4)))
(define cbt (make-string->text #:font (cons 'bold code-font) #:size code-size #:color black))
(define ckwdt cbt)
(define ctypet ct) ;; TODO pict type color (make-string->text #:font (cons 'bold code-font) #:size code-size #:color racket-blue))
(define tcodesize (make-string->body #:size code-size))
(define tsmaller (make-string->body #:size (- body-size 4)))
(define lang-text (make-string->code #:size 32))
(define blang-text (make-string->text #:font (cons 'bold code-font) #:size 32 #:color black))
(define captiont (make-string->body #:size caption-size #:color black))
(define (ownership-text str #:color [color black]) ((make-string->text #:font "PilGi" #:size 40 #:color color) str))

(define t-v-sep (* 3/4 (pict-height @t{ })))
(define t-h-sep (pict-width @t{ }))
(define t-v-sep-pict (blank 0 t-v-sep))
(define t-h-sep-pict (blank t-h-sep 0))

(define erasure-tag 'erasure)
(define erasure-missing-tag 'erasure-blanklabel)
(define natural-tag 'natural)
(define transient-tag 'transient)
(define amnesic-tag 'amnesic)
(define ts-tag 'TS)

(define table-row-tag 'table-row)

(define (blur pp h-rad [v-rad #f])
  (define old-tag (pict-tag pp))
  (define pp/b (pict:blur pp h-rad (or h-rad v-rad)))
  (if old-tag (tag-pict pp/b old-tag) pp/b))

(define (make-bullet) (disk 11))

(define icfp-summary-title @st{ICFP '18 : Three Semantics, Soundnesses})

(define (make-compass-pict wh #:color [color black] #:border-color [border-color black])
  (define (draw dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-brush (new brush% [style 'solid] [color color]))
    (send dc set-pen (new pen% [width 1] [color border-color]))
    ;; ---
    (define wh2 (* 1/2 wh))
    (define wh4 (* 35/100 wh))
    (define wh6 (* 65/100 wh))
    (for* ((a? (in-list '(#t #f)))
           (b? (in-list '(#t #f))))
      (define path (new dc-path%))
      (cond
        [(and a? b?)
         (send path move-to wh2 0)]
        [(and a? (not b?))
         (send path move-to wh2 wh)]
        [(and (not a?) b?)
         (send path move-to 0 wh2)]
        [else
         (send path move-to wh wh2)])
      (if a?
        (begin
          (send path line-to wh4 wh2)
          (send path line-to wh6 wh2))
        (begin
          (send path line-to wh2 wh4)
          (send path line-to wh2 wh6)))
      (send path close)
      (send dc draw-path path dx dy))
    ;; ---
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (dc draw wh wh))

(define (add-shadow-background pp #:x-margin [pre-x-margin #f] #:y-margin [pre-y-margin #f] #:color [shadow-color black] #:alpha [shadow-alpha 0.1])
  (define w (pict-width pp))
  (define h (pict-height pp))
  (define default-margin (* 5/100 (min w h)))
  (define x-margin (or pre-x-margin default-margin))
  (define y-margin (or pre-x-margin default-margin))
  (define shadow-pict (cellophane (filled-rectangle w h #:draw-border? #f #:color shadow-color) shadow-alpha))
  (lt-superimpose (ht-append (blank x-margin 0) (vl-append (blank 0 y-margin) shadow-pict)) pp))

(define (make-plt-watermark pre-w)
  (define w (* 4/5 pre-w))
  (scale-to-fit (cellophane (bitmap racket-logo.png) watermark-alpha) w w))

(define code-underline-size 5)

(define (make-code-underline pp tag)
  (pin-code-line pp (find-tag pp tag) lb-find (find-tag pp tag) rb-find))

(define (pin-code-line pp src find-src tgt find-tgt #:label [label (blank)] #:color [pre-color #f])
  (pin-line pp src find-src tgt find-tgt #:line-width code-underline-size #:color (or pre-color code-highlight-color) #:label label))

(define (make-code-callout pp #:frame-color [fc #f] #:background-color [bg-color #f] #:x-margin [pre-x-margin #f] #:y-margin [pre-y-margin #f])
  (define x-margin (or pre-x-margin pico-x-sep))
  (define y-margin (or pre-y-margin pico-y-sep))
  (add-rounded-border
    #:radius 4 #:x-margin 0 #:y-margin 0 #:frame-width 0 #:background-color white
    (add-rounded-border #:radius 4 #:x-margin x-margin #:y-margin y-margin #:frame-width 3 #:frame-color (or fc code-callout-color) #:background-color (or bg-color white) pp)))

(define (make-program-pict pp #:radius [pre-radius #f] #:bg-color [bg-color #f] #:frame-color [frame-color #f] #:x-margin [pre-x #f] #:y-margin [pre-y #f])
  (define radius (or pre-radius 12))
  (define x-m (or pre-x (w%->pixels 5/100)))
  (define y-m (or pre-y med-y-sep))
  (add-rectangle-background
    #:radius radius #:color (if (eq? bg-color transparent) transparent white)
    (add-rounded-border
      pp
      #:radius radius
      #:background-color (or bg-color (color%-update-alpha program-color 0.85))
      #:frame-width 3
      #:frame-color (or frame-color program-color)
      #:x-margin x-m
      #:y-margin y-m)))

(define (make-module-pict pp #:radius radius #:bg-color [bg-color #false] #:x-margin [pre-x #f] #:y-margin [pre-y #f])
  (add-rounded-border
    pp
    #:radius radius
    #:background-color bg-color
    #:frame-width 2
    #:x-margin (or pre-x pico-x-sep)
    #:y-margin (or pre-y pico-y-sep)))

(define (make-typed-pict pp #:x-margin [x #f] #:y-margin [y #f])
  (make-module-pict pp #:radius 37 #:bg-color typed-color #:x-margin x #:y-margin y))

(define (make-untyped-pict pp #:x-margin [x #f] #:y-margin [y #f])
  (make-module-pict pp #:radius 4 #:bg-color untyped-color #:x-margin x #:y-margin y))

(define (make-tu-icon str #:font-size [pre-font-size #f] #:width [pre-w #f] #:height [pre-h #f])
  (define font-size (or pre-font-size tu-size))
  (define w (or pre-w 70))
  (define h (or pre-h 70))
  (define str-pict (clip-descent (text str `(bold . ,tu-font) font-size)))
  (cc-superimpose (blank w h) str-pict))

(define (make-typed-icon #:font-size [font-size #f] #:width [w #f] #:height [h #f])
  (make-tu-icon "T" #:font-size font-size #:width w #:height h))

(define (make-untyped-icon  #:font-size [font-size #f] #:width [w #f] #:height [h #f])
  (make-tu-icon "U" #:font-size font-size #:width w #:height h))

(define (make-cloud pp #:color [pre-color #f] #:x-margin [pre-x-margin #f] #:y-margin [pre-y-margin #f] #:style [pre-style #f])
  (define x-margin (or pre-x-margin pico-x-sep))
  (define y-margin (or pre-y-margin pico-y-sep))
  (cc-superimpose
    (cloud (+ x-margin (pict-width pp)) (+ y-margin (pict-height pp)) (or pre-color "gray") #:style (or pre-style '(square wide)))
    pp))

(define (make-cloud-trail pp #:color [pre-color #f] #:flip? [flip? #f])
  (define w (pict-width pp))
  (define h (* 4/10 (pict-height pp)))
  (define cc (or pre-color "gray"))
  (define cw (* 20/100 w))
  (define ch (* 30/100 h))
  (define little-cloud (cloud cw ch cc))
  (define trail-pict
    (ppict-do
      (blank w h)
      #:go (coord 1/2 5/100 'ct)
      little-cloud
      #:go (coord (if flip? 65/100 35/100) 38/100 'ct)
      little-cloud
      #:go (coord (if flip? 89/100 11/100) 60/100 'ct)
      little-cloud))
  (vl-append pp trail-pict))

(define (make-tu-lang host lang)
  (define txt-pict
    (if (and host lang)
      (hc-append
        (lang-text host)
        (lang-text " + ")
        (lang-text lang))
      (blank 40 20)))
  (define x-margin tiny-x-sep)
  (define y-margin tiny-y-sep)
  ;; TODO maybe still want a gradient for this
  (make-flag txt-pict #:x-margin x-margin #:y-margin y-margin))

(define (make-flag pp #:x-margin [pre-x-margin #f] #:y-margin [pre-y-margin #f])
  (define x-margin (or pre-x-margin tiny-x-sep))
  (define y-margin (or pre-y-margin tiny-y-sep))
  (define w
    (let ((pw (pict-width pp)))
      (+ pw (* 5/100 pw) (* 2 x-margin))))
  (define h
    (+ (pict-height pp) (* 2 y-margin)))
  (define h/2 (* 1/2 h))
  (define w/offset (* 92/100 w))
  (define (draw-flag dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-pen (new pen% [width 5] [color untyped-color]))
    (for ((brush (in-list
                   (list
                     (new brush% [style 'solid] [color white])
                     (new brush% [style 'crossdiag-hatch #;solid] [color typed-flag-color])))))
      (send dc set-brush brush)
      (define path (new dc-path%))
      (send path move-to w 0)
      (send path line-to 0 0)
      (send path line-to 0 h)
      (send path line-to w h)
      (send path line-to w/offset h/2)
      (send path line-to w 0)
      (send path close)
      (send dc draw-path path dx dy))
    ;; --
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (lc-superimpose
    (dc draw-flag w h)
    (ht-append (* 3/4 x-margin) (blank) pp)))

(define (make-legend #:x-margin [x-margin #f] #:y-margin [y-margin #f] . pp*)
  (make-legend* (apply vc-append tiny-y-sep pp*) #:x-margin x-margin #:y-margin y-margin))

(define (make-legend* txt-pict #:x-margin [pre-x-margin #f] #:y-margin [pre-y-margin #f])
  (define x-margin (or pre-x-margin (w%->pixels 4/100)))
  (define y-margin (or pre-y-margin (h%->pixels 4/100)))
  (add-shadow-background
    #:alpha 0.4
    (cc-superimpose
      (legend-rectangle
        (+ (pict-width txt-pict) x-margin)
        (+ (pict-height txt-pict) y-margin))
      txt-pict)))

(define (legend-rectangle w h)
  (define (draw dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-brush
          (new brush%
               [gradient
                (new linear-gradient%
                     [x0 dx] [y0 dy]
                     [x1 (+ dx w)] [y1 dy]
                     [stops (list (list 0 legend-tan)
                                  (list 15/100 legend-light-tan)
                                  (list 85/100 legend-light-tan)
                                  (list 1 legend-tan))])]))
    (send dc set-pen (new pen% [width 1] [color legend-border-color]))
    (define path (new dc-path%))
    (send path rectangle 0 0 w h)
    (send dc draw-path path dx dy)
    ;; --
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (dc draw w h))

(define (add-fog pp)
  (define w (pict-width pp))
  (define h (pict-height pp))
  (define ((draw-fog x0% y0% x1% y1%) dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-pen (new pen% [width 1] [color fog-color]))
    (send dc set-brush
          (new brush%
               [gradient
                 (new linear-gradient%
                      [x0 (+ dx (* x0% w))] [y0 (+ dy (* y0% h))]
                      [x1 (+ dx (* x1% w))] [y1 (+ dy (* y1% h))]
                      [stops
                        (list
                          (list 0 fog-color)
                          (list 5/100 fog-color)
                          (list 35/100 transparent)
                          (list 65/100 transparent)
                          (list 95/100 fog-color)
                          (list 1 fog-color))])]))
    (define path (new dc-path%))
    (send path rectangle 0 0 w h)
    (send dc draw-path path dx dy)
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (cc-superimpose
    pp
    (dc (draw-fog 0 0 1 1) w h)
    (dc (draw-fog 0 1 1 0) w h)
    ))

(define (make-flag-text . str*)
  (make-flag-text* str*))

(define (make-flag-text* str*)
  (define base (apply vl-append small-y-sep (map t str*)))
  (ppict-do base #:go (coord 2/10 1/2 'cc) @t{+}))

(define (make-illustration-text . pp*)
  (make-illustration-text* pp*))

(define (make-illustration-text* pp*)
  (apply vc-append tiny-y-sep pp*))

(define (make-typed-codeblock #:title [title #f] #:x-margin [x #f] #:y-margin [y #f] . pp*)
  (make-typed-codeblock* pp* #:title title #:x-margin x #:y-margin y))

(define (make-untyped-codeblock #:title [title #f] #:x-margin [x #f] #:y-margin [y #f] . pp*)
  (make-untyped-codeblock* pp* #:title title #:x-margin x #:y-margin y))

(define codeblock-label-scale 0.65)

(define (make-typed-codeblock* pp* #:title [title #f] #:x-margin [x #f] #:y-margin [y #f])
  (make-codeblock pp* #:title title #:label (scale T-node codeblock-label-scale) #:bg-color typed-color #:x-margin x #:y-margin y))

(define (make-untyped-codeblock* pp* #:title [title #f] #:x-margin [x #f] #:y-margin [y #f])
  (make-codeblock pp* #:title title #:label (scale U-node codeblock-label-scale) #:bg-color untyped-color #:x-margin x #:y-margin y))

(define (make-codeblock pp* #:title [title #f] #:label [label #f] #:bg-color [pre-bg-color #f] #:x-margin [pre-x-margin #f] #:y-margin [pre-y-margin #f])
  (define bg-c (or pre-bg-color (string->color% "lightgray")))
  (define label-margin (if label (* 50/100 (pict-height label)) 0))
  (define (add-label-margin pp [extra 0]) (vl-append (+ extra label-margin) (blank) pp))
  (let* ((block-pict
          (make-program-pict
            #:frame-color bg-c
            #:bg-color (color%-update-alpha bg-c 0.4)
            #:x-margin pre-x-margin
            #:y-margin pre-y-margin
            #:radius 4
            (add-label-margin (apply vl-append (h%->pixels 2/100) pp*))))
         (title-pict (and title (tcodesize title))))
    (if label
      (let ((block-pict (add-label-margin block-pict 2)))
        (ppict-do (if title-pict (lt-superimpose block-pict (ht-append 4 (blank) title-pict)) block-pict)
          #:go (coord 1/2 0 'ct) label))
      (if title-pict (vl-append 0 title-pict block-pict) block-pict))))

(define (pict->square pp)
  (define w (pict-width pp))
  (define h (pict-height pp))
  (cc-superimpose (blank (max w h)) pp))

(define (add-island-q? pp)
  (define q-pict
    (add-rounded-border
      #:radius 20 #:background-color q-black #:frame-color q-black #:frame-width 1 #:x-margin tiny-x-sep #:y-margin pico-x-sep
      ((make-string->text #:font (cons 'bold code-font) #:color white #:size code-size) "?")))
  (define h (* 7/100 (pict-height pp)))
  (ppict-do pp #:go (at-find-pict island-tag cc-find 'cc) (scale-to-fit q-pict h h)))

(define (add-focus pp x% y%)
  (define w (pict-width pp))
  (define h (pict-height pp))
  (define color (color%-update-alpha black 0.6))
  (define radius (* 45/100 h))
  (define (draw-focus dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-brush (new brush% [style 'solid] [color color]))
    (send dc set-pen (new pen% [width 1] [color color]))
    (let ((r0 (new region%))
          (r1 (new region%)))
      (send r0 set-rectangle dx dy (+ dx w) (+ dy h))
      (send r1 set-ellipse (+ dx (* x% w)) (+ dy (* y% h)) radius radius)
      (send r0 subtract r1)
      (send dc set-clipping-region r0))
    (send dc draw-rectangle dx dy w h)
    (send dc set-clipping-region #f)
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (cc-superimpose pp (dc draw-focus w h)))

(define (make-ribbon pp #:color [color #f] #:background-color [bg #f] #:y-margin [pre-y-margin #f])
  (define rw (* 3/2 client-w))
  (define rh (+ (pict-height pp) (or pre-y-margin med-y-sep)))
  (define fg-color (add-region-alpha (or color ribbon-color)))
  (define bg-color (or bg color legend-border-color))
  (cc-superimpose
    (filled-rectangle rw rh #:color white #:draw-border? #false)
    (filled-rectangle rw rh #:color fg-color #:draw-border? #true #:border-width 1 #:border-color bg-color)
    pp))

(define (make-landscape w #:title [title #true] #:blur [pre-blur #f] #:fog? [add-fog? #true] #:focus [focus-coord #f])
  (define blur-val (or pre-blur 2))
  (define w-scale 46/100)
  (define land-pict
    #;(blur island-pict blur-val)
    (tag-pict (filled-rectangle (pict-width island-pict) (pict-height island-pict) #:color landscape-color #:draw-border? #f) island-tag))
  (let* ((map-pict (scale-to-fit land-pict w (* w w-scale) #:mode 'distort))
         (map-pict (if add-fog? (add-fog map-pict) map-pict))
         (map-pict (if focus-coord (add-focus map-pict (car focus-coord) (cdr focus-coord)) map-pict))
         (map-pict (make-legend #:x-margin (h%->pixels 6/100) #:y-margin (w%->pixels 4/100) (frame #:line-width 1 #:color legend-border-color map-pict))))
    (if title
      (vl-append pico-y-sep @sst3{Mixed-typed landscape} map-pict)
      map-pict)))

(define med-landscape-size 400)
(define big-landscape-size 560)
(define huge-landscape-size 840)

(define (make-mouse-icon w h #:color [color black])
  (rotate
    (ppict-do
      (blank w h)
      #:go (coord 1/2 0 'ct)
      (colorize (arrowhead (min w h) (* turn 1/4)) color)
      #:go (coord 1/2 42/100 'ct)
      (filled-rectangle (* 17/100 w) (* 1/2 h) #:color color))
    (* 1/14 turn))
  #;#;(define (draw dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-brush (new brush% [style 'solid] [color color]))
    (send dc set-pen (new pen% [width 1] [color color]))
    (define path (new dc-path%))
    ;; ---
    (send path move-to 0 0)
    (send path line-to (*  5/100 w) (* 80/100 h))
    (send path line-to (* 32/100 w) (* 62/100 h))
    (send path line-to (* 40/100 w) h)
    (send path line-to (* 56/100 w) (* 98/100 h))
    (send path line-to (* 60/100 w) (* 58/100 h))
    (send path line-to w            (* 64/100 h))
    (send path line-to 0 0)
    ;; ---
    (send path close)
    (send dc draw-path path dx dy)
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (dc draw w h))

(define (make-plot-pointer w h)
  (make-mouse-icon (* 5/100 w) (* 12/100 h)))

(define (make-plot-dingbat w h)
  ;; TODO colors
  (jack-o-lantern (* 24/100 (min w h))))

(define (make-plot t [w 600] [h 400])
  ;; t = time step
  (define base-plot
    (parameterize (#;[plot-decorations? #f]
                   [plot-tick-size 12]
                   ;[plot-foreground-alpha 0]
                   ;[plot-background-alpha 0]
                   [line-width 25]
                   [plot-x-tick-labels? #f]
                   [plot-y-tick-labels? #f]
                   [plot-x-label #f]
                   [plot-y-label #f]
                   [plot-title #f])
      (plot-pict
        (function sin #:color racket-blue #:width 6 #:alpha 0.9)
        #:x-min (* 1/2 turn) #:x-max (* 3/2 turn) #:y-min -3/2 #:y-max 3/2 #:width w #:height h)))
  (define-values [click-pict align]
    (case t
      ((0) (values (blank) 'cc))
      ((1) (values (make-plot-pointer w h) 'lt))
      ((2) (values (make-plot-dingbat w h) 'cc))
      (else (raise-argument-error 'make-plot "(or/c 0 1 2)" t))))
  (ppict-do (add-rounded-border base-plot #:radius 2 #:frame-width 2)
            #:go (coord 48/100 48/100 align) click-pict))

(define cm-check-width (w%->pixels (- 1/2 (* 2 slide-left))))
(define cm-check-height (h%->pixels 26/100))
(define cm-check-y 30/100)
(define cm-check-margin (h%->pixels slide-left))

(define (natural->owner-color i)
  ;; TODO find better colors than from plot?
  (color%-update-alpha (rgb-triplet->color% (->pen-color i)) 0.3))

(define (sst3 str)
  (clip-ascent (clip-descent (sst2 str))))

(define ell-pict
  (ownership-text "l"))

(define (natural->owner-label i)
  (define i-pict (ownership-text (number->string i)))
  (ht-append ell-pict (vl-append (* 36/100 (pict-height i-pict)) (blank) i-pict)))

(define (add-ownership pp i #:draw-label? [draw-label? #true] #:x-margin [pre-x-margin #f] #:y-margin [pre-y-margin #f])
  (define color (natural->owner-color i))
  (define x-margin (or pre-x-margin (* 1/2 (pict-width pp))))
  (define y-margin (or pre-y-margin (pict-height pp)))
  (define base-pict
    (add-spotlight-background
      #:border-color color #:x-margin x-margin #:y-margin y-margin
      pp))
  (if draw-label?
    (ppict-do
      base-pict
      #:go (coord 1 0 'rc)
      (natural->owner-label i))
    base-pict))

(define (add-ownership* pp oid* #:draw-label? [draw-label? #true])
  (define x% 30/100)
  (define y% 30/100)
  (define last-i (- (length oid*) 1))
  (unless (< 0 last-i)
    (raise-argument-error 'add-ownership* "list of 2 or more integers" 1 pp oid* '#:draw-label? draw-label?))
  (for/fold ((acc (add-ownership pp (car oid*) #:draw-label? #f)))
            ((lbl (in-list (cdr oid*)))
             (i (in-naturals)))
    (add-ownership acc lbl
                   #:draw-label? (and draw-label? (= i last-i))
                   #:x-margin (* (- x% (* 4/100 i)) (pict-width acc))
                   #:y-margin (* (- y% (* 4/100 i)) (pict-height acc)))))

(define tau-str "τ")
(define (tagof str)
  (string-append "⌊" str "⌋"))

(define U-sound-str "Uni sound")
(define tag-sound-str (string-append (tagof "T") " sound"))
(define full-sound-str "T sound")
(define complete-monitoring-str "Complete monitoring")
(define unknown-sound-str "???")

(define Natural-str "Natural")
(define Transient-str "Transient")
(define Amnesic-str "Amnesic")
(define Natural-pict (t Natural-str))
(define Transient-pict (t Transient-str))
(define Amnesic-pict (t Amnesic-str))

(define N-str "N")
(define T-str "T")
(define A-str "A")
(define N-pict (t N-str))
(define T-pict (t T-str))
(define A-pict (t A-str))

(define (tr-append a b)
  ;; "table row" append
  (vl-append pico-y-sep a b))

(define (make-table-rectangle w h #:color c #:border-color [bc #f])
  (filled-rounded-rectangle
    w h 2
    #:draw-border? #true
    #:border-width 1
    #:border-color (or bc c)
    #:color (color%-update-alpha c 3/10)))

(define (make-result-table p*)
  (define title* (list @t{ }(tag-pict  Natural-pict natural-tag) (tag-pict Transient-pict transient-tag) (tag-pict Amnesic-pict amnesic-tag)))
  (define y-sep tiny-y-sep)
  (define x-sep tiny-x-sep)
  (define tbl
    (table 4 (append title* p*) (cons lc-superimpose cc-superimpose) cc-superimpose (w%->pixels 6/100) (h%->pixels 6/100)))
  (define base
    (cc-superimpose (blank (+ (* 2 x-sep) (pict-width tbl)) (+ (* 2 y-sep) (pict-height tbl))) tbl))
  (define bg-h (pict-height base))
  (define r-w (pict-width base))
  (cc-superimpose
    (ppict-do
      base
      #:set
      (for/fold ((acc ppict-do-state))
                ((tgt (in-list p*))
                 #:when (eq? (pict-tag tgt) table-row-tag))
        (define r-h (+ small-y-sep (pict-height tgt)))
        (ppict-do
          acc
          #:go (at-find-pict tgt lc-find 'lc #:abs-x (- x-sep))
          (make-table-rectangle r-w r-h #:color white)))
      #:set
      (for/fold ((acc ppict-do-state))
                ((tgt (in-list (cdr title*)))
                 (clr (in-list (list complete-monitoring-color tag-sound-color full-sound-color))))
        (define bg-w (+ small-x-sep (pict-width tgt)))
        (ppict-do
          acc
          #:go (at-find-pict tgt ct-find 'ct #:abs-y (- y-sep))
          (make-table-rectangle bg-w bg-h #:color clr))))
    tbl))

(define (hide pp)
  (blank (pict-width pp) (pict-height pp)))

(define U-node (make-untyped-pict (make-untyped-icon)))
(define T-node (make-typed-pict (make-typed-icon)))

(define big-node-blank (blank 160))

(define (make-big-typed-node pp)
  (make-typed-pict (cc-superimpose big-node-blank pp)))

(define (make-big-untyped-node pp)
  (make-untyped-pict (cc-superimpose big-node-blank pp)))

(define (make-big-tu-pict tp up)
  (combine-big-nodes (make-big-untyped-node up) 'lt (make-big-typed-node tp) 'rb))

(define (make-big-ut-pict up tp)
  (combine-big-nodes (make-big-typed-node tp) 'lt (make-big-untyped-node up) 'rb))

(define (combine-big-nodes bottom-pict bottom-placer top-pict top-placer)
  (define w (+ (pict-width bottom-pict) (pict-width top-pict)))
  (define h (+ (pict-height bottom-pict) (pict-height top-pict)))
  (define x-offset (* 1/10 w))
  (define y-offset (* 1/10 h))
  (define-values [x-b-sign y-b-sign] (placer->signs bottom-placer))
  (define-values [x-t-sign y-t-sign] (placer->signs top-placer))
  (ppict-do (blank (- w (* 2 x-offset)) (- h (* 2 y-offset)))
    #:go (coord 1/2 1/2 bottom-placer #:abs-x (* x-b-sign x-offset) #:abs-y (* y-b-sign y-offset)) bottom-pict
    #:go (coord 1/2 1/2 top-placer #:abs-x (* x-t-sign x-offset) #:abs-y (* y-t-sign y-offset)) top-pict))

(define (placer->signs sym)
  (case sym
    ((lt) (values -1 -1))
    ((rt) (values 1 -1))
    ((lb) (values -1 1))
    ((rb) (values 1 1))
    (else (error 'placer->signs))))

(define (tag-append . x*)
  (string->symbol (string-join (map ~a x*) "-")))

(define (add-hubs pp tag)
  (define io-margin 8)
  (define node-padding 6)
  (define h-blank (blank 0 io-margin))
  (define v-blank (blank io-margin 0))
  (vc-append
    node-padding
    (tag-pict v-blank (tag-append tag 'N))
    (hc-append
      node-padding
      (tag-pict h-blank (tag-append tag 'W)) (tag-pict pp tag) (tag-pict h-blank (tag-append tag 'E)))
    (tag-pict v-blank (tag-append tag 'S))))

(define (make-tree w h tu-code* #:arrows? [draw-arrows? #false] #:owners? [draw-owners? #false] #:labels? [labels? #true])
  (define node-sym* '(A B C D E))
  (define node*
    (for/fold ((acc (blank w h)))
              ((pos (in-list (list (coord 0 0 'lt)
                                   (coord 52/100 25/100 'ct)
                                   (coord 1 1/100 'rt)
                                   (coord 12/100 1 'lb)
                                   (coord 95/100 95/100 'rb))))
               (bool (in-list tu-code*))
               (tag (in-list node-sym*))
               (i (in-naturals)))
      (define node (add-hubs (if bool T-node U-node) tag))
      (ppict-do acc #:go pos (if draw-owners? (add-ownership node i #:draw-label? labels?) node))))
  (define node*/arrows
    (cond
      [draw-arrows?
       (define arr*
         (list
           (program-arrow 'D-E rt-find 'E-W lt-find (* 1/10 turn) (* 9/10 turn) 60/100 1/4 black)
           (program-arrow 'E-N rt-find 'C-S rb-find (* 18/100 turn) (* 29/100 turn) 1/4 1/4 black)
           ;; --
           (program-arrow 'C-W lt-find 'A-E lt-find (* 36/100 turn) (* 64/100 turn) 1/4 1/4 black)
           (program-arrow 'A-E rb-find 'B-W lt-find 0 0 1/2 1/2 black)
           (program-arrow 'B-W lb-find 'D-N rt-find (* 1/2 turn) (* 3/4 turn) 1/4 1/4 black)
           (program-arrow 'B-S rb-find 'E-N lt-find (* 3/4 turn) (* 3/4 turn) 1/8 1/8 black)
           (program-arrow 'C-W lb-find 'B-N rt-find (* 1/2 turn) (* 3/4 turn) 1/2 1/3 black)
           (program-arrow 'D-N lt-find 'A-S lb-find (* 1/4 turn) (* 1/4 turn) 1/4 1/4 black)
           (program-arrow 'E-W lb-find 'D-E rb-find (* 60/100 turn) (* 45/100 turn) 1/4 1/4 black)
           (program-arrow 'E-S lb-find 'B-S lb-find (* 70/100 turn) (* 20/100 turn) 5/10 1/4 black)))
       (cond
         [(eq? draw-arrows? 'path)
          (define path-idx 2)
          (define short-arrow* (take arr* path-idx))
          (define val-tag 'end-val)
          (define node/path
            (for/fold ((acc node*))
                      ((a (in-list short-arrow*)))
              (add-program-arrow acc a)))
          (define node/path+
            (add-program-arrow node/path (list-ref arr* path-idx) #:style 'transparent #:hide? #true #:label (tag-pict (blank) val-tag)))
          (ppict-do
            node/path+
            #:go (at-find-pict val-tag cc-find 'cc #:abs-y (* -3/2 (pict-height ownership-v-pict)))
            (add-hubs (add-ownership* ownership-v-pict (decode-lbl* short-arrow*) #:draw-label? #f) 'V)
            #:set (add-program-arrow ppict-do-state (program-arrow 'C-W lt-find 'V-E rb-find (* 36/100 turn) (* 44/100 turn) 1/4 1/4 black)))]
         [else
          (for/fold ((acc node*))
                    ((a (in-list arr*)))
            (add-program-arrow acc a))])]
      [else
       node*]))
  node*/arrows)

(define (decode-lbl* pa*)
  ;; HACK get integers from the tags in pa*
  (remove-duplicates
    (apply append (for/list ((a (in-list pa*))) (list (decode-lbl (program-arrow-src-tag a)) (decode-lbl (program-arrow-tgt-tag a)))))))

(define (decode-lbl sym)
  ;; HACK
  (define str (symbol->string sym))
  (unless (< 0 (string-length str))
    (raise-argument-error 'decode-lbl "symbol? with +0 characters"))
  (- (char->integer (string-ref str 0)) (char->integer #\A)))

(struct program-arrow [src-tag src-find tgt-tag tgt-find start-angle end-angle start-pull end-pull color] #:transparent)

(define (add-landscape-line pp arrow)
  (add-program-arrow pp arrow #:hide? #true #:style 'solid #:line-width 4))

(define (add-program-arrow pp arrow #:arrow-size [arrow-size 12] #:line-width [pre-line-width #f] #:style [style 'short-dash] #:label [label (blank)] #:hide? [hide? #false])
  (define line-width (or pre-line-width 3))
  (pin-arrow-line
    arrow-size pp
    (find-tag pp (program-arrow-src-tag arrow))
    (program-arrow-src-find arrow)
    (find-tag pp (program-arrow-tgt-tag arrow))
    (program-arrow-tgt-find arrow)
    #:line-width line-width
    #:label label
    #:hide-arrowhead? hide?
    #:style style
    #:start-angle (program-arrow-start-angle arrow)
    #:end-angle (program-arrow-end-angle arrow)
    #:start-pull (program-arrow-start-pull arrow)
    #:end-pull (program-arrow-end-pull arrow)
    #:color (program-arrow-color arrow)))

(define caption-margin small-y-sep)

(define (add-caption str pp)
  (vc-append caption-margin pp (captiont str)))

(define big-program-w (w%->pixels 45/100))
(define big-program-h (h%->pixels 55/100))

(define big-program-x 4/100)
(define big-program-y 15/100)
(define big-program-coord (coord 1/2 big-program-y 'ct))
(define big-program-coord-left (coord big-program-x big-program-y 'lt))
(define big-program-coord-right (coord (- 1 big-program-x) big-program-y 'rt))

(define untyped-program-code* '(#f #f #f #f #f))
(define mixed-program-code* '(#f #t #f #f #t))

(define program-w (w%->pixels 35/100))
(define program-h (h%->pixels 45/100))

(define (make-migration-arrow)
  ;; TODO use a dc, draw more of a triangle with border?
  (colorize (arrowhead (w%->pixels 5/100) 0) (hex-triplet->color% #x333333)))

(define u-name* (list "JavaScript" "PHP" "Racket" "Python"))

(define u-lang-tag* (map string->symbol u-name*))

(define tu-lang*
  (for/list ((u-name (in-list u-name*))
             (u-tag (in-list u-lang-tag*))
             (t-name (in-list (list "TypeScript" "Hack" "Typed Racket" "Reticulated"))))
    (tag-pict (make-tu-lang u-name t-name) u-tag)))

(define (make-cloud-trail-pict flip?)
  (let ((cloud-scale 44/100))
    (make-cloud-trail
      #:color program-color
      #:flip? flip?
      (make-cloud
        #:color program-color #:x-margin (w%->pixels 4/100) #:y-margin (h%->pixels 4/100)
        (make-program-pict
          #:bg-color program-color #:x-margin pico-x-sep #:y-margin pico-y-sep
          (make-tree (* cloud-scale big-program-w) (* cloud-scale big-program-h) mixed-program-code* #:arrows? #false))))))

(define lang-cloud-pict (make-cloud-trail-pict #f))

(define (add-island-line* pp tag*)
  (for/fold ((acc pp))
            ((src-tag (in-list tag*)))
    (pin-line
      acc
      (find-tag acc src-tag) rb-find
      (find-tag acc island-tag) cc-find
      #:line-width 3 #:color flagpole-border-color)))

(define (make-small-flag)
  (make-large-flag (blank 37 0)))

(define (make-large-flag pp #:pole-height% [pre-length% #f])
  (define flag (make-flag (vl-append 2 pp (blank)) #:x-margin 10))
  (define h (* 2 (pict-height flag)))
  (define pole (filled-rounded-rectangle 5 (* h (or pre-length% 1))  2 #:color flagpole-border-color #:border-color flagpole-border-color #:border-width 1))
  (lt-superimpose (ht-append 4 (blank) pole) (vl-append 7 (blank) flag)))

(define (make-flag-landscape . pp*)
  (make-flag-landscape* pp*))

(define (make-flag-landscape* extra-pict*)
  (define base-pict (make-landscape big-landscape-size #:fog? #f))
  (define base/region
    (for/fold ((acc base-pict))
              ((ep (in-list extra-pict*)))
      (ppict-do acc #:go (coord (car ep) (cadr ep) 'cc) (caddr ep))))
  (let ((f-pict (make-small-flag)))
    ;; TODO draw flags from ICFP (need more N flags)
    (for/fold ((acc base/region))
              ((xy (in-list '((11/100 15/100) (25/100 18/100) (20/100 30/100) (8/100 25/100)
                              (80/100 17/100)
                              (46/100 55/100) (66/100 46/100) (76/100 51/100)))))
      (ppict-do acc #:go (coord (car xy) (cadr xy) 'lt) f-pict))))

(define (make-landscape-legend w h)
  (add-rounded-border
    #:radius 4
    #:background-color white
    #:frame-width 1
    #:x-margin tiny-x-sep
    #:y-margin tiny-y-sep
    (scale
      (table 2 (list (make-city-dot) @t{ = "like" semantics} (make-small-flag) @t{ = other model/lang.})
        (cons cc-superimpose lc-superimpose) cc-superimpose 0 20)
      0.6)))

(define (make-city-dot)
  (disk 16 #:draw-border? #f #:color city-color))

(define (make-optional-region w h label-str)
  (define c optional-color)
  (define (draw-erasure-region dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-pen (new pen% [width region-border-width] [color c]))
    (for ((brush (in-list
                   (list
                     (new brush% [style 'solid] [color land-color])
                     (new brush% [style 'bdiagonal-hatch] [color (add-region-alpha c)])))))
      (send dc set-brush brush)
      (define path (new dc-path%))
      (send path move-to w 0)
      (send path line-to 0 0)
      (send path line-to 0 h)
      (send path curve-to w h w h w 0)
      (send path close)
      (send dc draw-path path dx dy))
    ;; --
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (ppict-do
    (dc draw-erasure-region w h)
    #:go (coord 56/100 83/100 'cc)
    (if label-str (make-region-label label-str) (blank))))

(define (make-tag-sound-region w h)
  (define c tag-sound-color)
  (define (draw-tag-region dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-pen (new pen% [width region-border-width] [color c]))
    (for ((brush (in-list
                   (list
                     (new brush% [style 'solid] [color land-color])
                     (new brush% [style 'vertical-hatch] [color (add-region-alpha c)])))))
      (send dc set-brush brush)
      (define path (new dc-path%))
      (send path rectangle 0 0 w h)
      (send dc draw-path path dx dy))
    ;; --
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (ppict-do
    (dc draw-tag-region w h)
    #:go (coord 77/100 78/100 'cc)
    (make-region-label tag-sound-str)))

(define (make-type-sound-region w h)
  (define c full-sound-color)
  (define (draw-ts-region dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-pen (new pen% [width region-border-width] [color c]))
    (for ((brush (in-list
                   (list
                     (new brush% [style 'solid] [color land-color])
                     (new brush% [style 'horizontal-hatch] [color (add-region-alpha c)])))))
      (send dc set-brush brush)
      (define path (new dc-path%))
      (send path move-to w 0)
      (send path line-to w h)
      (send path line-to (* 20/100 w) h)
      (send path curve-to (* 30/100 w) (* 60/100 h) (* 5/100 w) (* 3/10 h) (* 16/100 w) 0)
      (send path line-to w 0)
      (send path close)
      (send dc draw-path path dx dy))
    ;; --
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (ppict-do
    (dc draw-ts-region w h)
    #:go (coord 40/100 80/100 'cc)
    (make-region-label full-sound-str)))

(define (make-complete-monitoring-region w h cm-label)
  (define c complete-monitoring-color)
  (define (draw-cm-region dc dx dy)
    (define old-brush (send dc get-brush))
    (define old-pen (send dc get-pen))
    (send dc set-pen (new pen% [width region-border-width] [color c]))
    (for ((brush (in-list
                   (list
                     (new brush% [style 'solid] [color land-color])
                     (new brush% [style 'solid] [color (add-region-alpha c)])))))
      (send dc set-brush brush)
      (define path (new dc-path%))
      (send path move-to w 0)
      (send path line-to w h)
      (send path line-to (* 15/100 w) h)
      (send path curve-to 0 h 0 h 0 (* 25/100 h))
      (send path curve-to 0 0 0 0 (* 25/100 w) 0)
      ; (send path curve-to (* 14/100 w) (* 9/10 h) (* 6/100 w) (* 6/10 h) 0 (* 4/100 h))
      ; (send path line-to 0 0)
      (send path line-to w 0)
      (send path close)
      (send dc draw-path path dx dy))
    ;; --
    (send dc set-brush old-brush)
    (send dc set-pen old-pen))
  (ppict-do
    (dc draw-cm-region w h)
    #:go (coord 57/100 80/100 'cc)
    (make-region-label (or cm-label complete-monitoring-str))))

(define (make-region-label str)
  (add-rounded-border
    #:radius 10
    #:x-margin tiny-x-sep
    #:y-margin tiny-y-sep
    #:background-color land-color
    #:frame-width 2 #:frame-color black
    (tcodesize str)))

(define (make-land-rectangle w h)
  (filled-rectangle w h #:color land-color #:draw-border? #true #:border-width 1 #:border-color legend-border-color))

(define (make-big-landscape #:theorem [draw-theorem? #t] #:model [draw-model? #t] #:cm-label [cm-label #f])
  (define draw-legend? #f #;draw-model?) ;; 2019-10-23 : no more legend, don't want to confuse
  (define bg-w (* 9/10 client-w))
  (define bg-h (* 7/10 client-h))
  (define land-width (* 90/100 bg-w))
  (define land-height (* 86/100 bg-h))
  (define l-w (* 2/10 bg-w))
  (define l-h (* 2/10 bg-h))
  (define bg-pict
    (legend-rectangle bg-w bg-h))
  (define land-pict
    (let* ((land-pict
             (make-land-rectangle land-width land-height))
           (land-pict
             (ppict-do land-pict
               #:go (coord 0 0 'lt) (if (memq draw-theorem? (list #t ts-tag)) (make-tag-sound-region (* 60/100 land-width) land-height) (blank))
               #:go (coord 0 0 'lt) (if draw-theorem?
                                      (let ((w (* 44/100 land-width))
                                            (h (* 55/100 land-height))
                                            (lbl (cond
                                                   [(eq? draw-theorem? erasure-tag) #f]
                                                   [(eq? draw-theorem? erasure-missing-tag) unknown-sound-str]
                                                   [else U-sound-str])))
                                        (make-optional-region w h lbl))
                                      (blank))
               #:go (coord 1 0 'rt) (if (memq draw-theorem? (list #t ts-tag)) (make-type-sound-region (* 55/100 land-width) land-height) (blank))
               #:go (coord 1 0 'rt) (if (eq? draw-theorem? #t) (make-complete-monitoring-region 360 190 cm-label) (blank))))
           (land-pict
             (let ((city-dot (make-city-dot)))
               (ppict-do land-pict
                 #:go (coord 15/100 27/100 'cc) (tag-pict city-dot erasure-tag)
                 #:go (coord 78/100 17/100 'cc) (tag-pict city-dot natural-tag)
                 #:go (coord 38/100 59/100 'cc) (tag-pict city-dot transient-tag)
                 #:go (coord 67/100 63/100 'cc) (tag-pict city-dot amnesic-tag))))
           (land-pict
             (if draw-model?
               (ppict-do land-pict
                 #:go (at-find-pict erasure-tag rb-find 'lt) @tcodesize{Erasure}
                 #:go (at-find-pict natural-tag rb-find 'lt) @tcodesize{Natural}
                 #:go (at-find-pict transient-tag rb-find 'lt) @tcodesize{Transient}
                 #:go (at-find-pict amnesic-tag rb-find 'lt) (if (eq? draw-model? ts-tag) (blank) @tcodesize{Amnesic}))
               land-pict))
           (land-pict
             (let ((flag (make-small-flag)))
               (ppict-do land-pict
                 ;; erasure
                 #:go (coord 5/100 5/100 'lt) flag
                 #:go (coord 1/100 20/100 'lt) flag
                 #:go (coord 20/100 4/100 'lt) flag
                 #:go (coord 35/100 2/100 'lt) flag
                 #:go (coord 27/100 14/100 'lt) flag
                 ;; natural
                 #:go (coord 89/100 3/100 'lt) flag
                 #:go (coord 70/100 2/100 'lt) flag
                 ;; transient
                 #:go (coord 45/100 45/100 'lt) flag
                 ;; amnesic
                 #:go (coord 61/100 46/100 'lt) flag
                 #:go (coord 79/100 48/100 'lt) flag
                 )))
           #;())
      (if draw-legend?
        (ppict-do land-pict #:go (coord 0 1 'lb #:abs-x 8 #:abs-y -8) (make-landscape-legend l-w l-h))
        land-pict)))
  (cc-superimpose bg-pict land-pict))

(define (make-little-landscape amnesic?)
  (let* ((bg-w (* 9/10 client-w))
         (bg-h (* 25/100 client-h))
         (bg-pict (legend-rectangle bg-w bg-h))
         (land-width (* 90/100 bg-w))
         (land-height (* 86/100 bg-h))
         (city-dot (make-city-dot))
         (dot-y 25/100))
    (cc-superimpose
      bg-pict
      (let* ((land-pict
               (ppict-do
                 (make-land-rectangle land-width land-height)
                 #:go (coord 0 0 'lt) (make-tag-sound-region (* 48/100 land-width) land-height)
                 #:go (coord 1 0 'rt) (make-type-sound-region (* 68/100 land-width) land-height)
                 #:go (coord 15/100 dot-y 'cc) (tag-pict city-dot transient-tag)
                 #:go (coord 85/100 dot-y 'cc) (tag-pict city-dot natural-tag)
                 #:go (at-find-pict natural-tag rb-find 'lt) @tcodesize{Natural}
                 #:go (at-find-pict transient-tag rb-find 'lt) @tcodesize{Transient}))
             (land-pict
               (if amnesic?
                 (let ((flag (make-small-flag)))
                   (ppict-do
                     land-pict
                     #:go (coord 43/100 9/100 'lc) flag
                     #:go (coord 66/100 50/100 'lb) flag))
                 land-pict))
             (land-pict
               (if (eq? amnesic-tag amnesic?)
                 (ppict-do
                   land-pict
                   #:go (coord 50/100 dot-y 'cc) (if amnesic? (tag-pict city-dot amnesic-tag) (blank))
                   #:go (at-find-pict amnesic-tag rb-find 'lt) (if amnesic? @tcodesize{Amnesic} (blank)))
                 land-pict)))
        land-pict))))

(define (add-region-alpha c)
  (color%-update-alpha c 4/10))

(define (make-region-ellipse w h c)
  (filled-ellipse w h #:draw-border? #true #:border-color legend-border-color #:border-width 1 #:color (add-region-alpha c)))

(define region-A-pict
  (make-region-ellipse 200 100 region-A-color))

(define region-A-code
  (list 23/100 36/100 (add-hubs region-A-pict 'RA)))

(define region-B-pict
  (make-region-ellipse 290 90 region-B-color))

(define region-B-code
  (list 65/100 66/100 (add-hubs region-B-pict 'RB)))

(define region-C-pict
  (make-region-ellipse 140 160 region-C-color))

(define region-C-code
  (list 81/100 47/100 (add-hubs region-C-pict 'RC)))

(define region-D-pict
  (make-region-ellipse 140 50 region-D-color))

(define region-D-code
  (list 82/100 30/100 (add-hubs region-D-pict 'RD)))

(define check-pict
  (bitmap (check-icon #:height 32)))

(define halt-pict
  (bitmap (x-icon #:height 32)))

;; may want check / x marks
(define yes-no-size 45)
(define yes-pict (bitmap (check-icon #:material metal-icon-material #:height yes-no-size)))
(define no-pict (bitmap (x-icon #:material metal-icon-material #:height yes-no-size)))

;; =============================================================================

;; /Users/ben/code/racket/gtp/shallow/gf-icfp-2018/talk/simple.ss

(define (do-show)
  (set-page-numbers-visible! #false)
  (set-spotlight-style! #:size 50 #:color (color%-update-alpha highlight-brush-color 0.6))
  ;; --
  (sec:title)
  (parameterize ([current-slide-assembler (slide-assembler/background (current-slide-assembler) #:color ice-color)])
    (void)
    (sec:migration)
    (sec:TS)
    (sec:plot)
    (sec:CM)
    (sec:BSBC)
    (sec:takeaways)
    (sec:extra)
    (void)))

;; -----------------------------------------------------------------------------
;; title

(define neu 'Northeastern)
(define nwu 'Northwestern)

(define PLT-pict
  (vl-append 2 (bitmap "src/racket-small.png") (blank)))

(define neu-pict
  (bitmap "src/neu-small.png"))

(define nwu-pict
  (hc-append 41 (blank) (bitmap "src/nwu-small.png")))

(define island-tag 'island)

(define island-pict (tag-pict (bitmap (build-path "src" "island.png")) island-tag))

(define map-bg-pict (cellophane island-pict 0.15))

(define the-title-pict
  (tag-pict
    (vl-append
      (h%->pixels 4/100)
      @titlet[@string-upcase{Complete Monitors}]
      @titlet[@string-upcase{for Gradual Types}]) 'title))

(define authors-pict
  (let ()
    ;; TODO actual NEU NWU fonts?
    (define base
      (ht-append
        pico-x-sep
        (vl-append (w%->pixels 12/1000) (blank) (make-compass-pict 24))
        (vl-append
          (h%->pixels 8/100)
          (tag-pict @sst{Ben Greenman} 'ben)
          (tag-pict @sst{Matthias Felleisen} 'matthias)
          (tag-pict @sst{Christos Dimoulas} 'christos))))
    (for/fold ((acc base))
              ((name (in-list '(ben matthias christos)))
               (uni (in-list (list neu-pict neu-pict nwu-pict))))
      (ppict-do acc
                #:go (at-find-pict name lb-find 'lt #:abs-x pico-x-sep)
                (tag-pict (hb-append PLT-pict ((make-string->body #:size (- body-size 4)) " at ")) 'aff)
                #:go (at-find-pict 'aff rc-find 'lc #:abs-x -36 #:abs-y 2) uni))))

(define (sec:title)
  (let ((the-y 46/100))
  (pslide
    #:go center-coord map-bg-pict
    #:go (coord slide-text-left 18/100 'lt) the-title-pict
    #:go (coord slide-text-right the-y 'rt) authors-pict
    #:next
    #:go (coord 7/100 the-y 'lt)
    (make-legend
      @small-titlet{a careful analysis}
      @small-titlet{of the mixed-typed}
      @small-titlet{design space})))
  (void))

;; -----------------------------------------------------------------------------
;; migration

(define program-blank (blank program-w program-h))
(define u-tag 'L)
(define t-tag 'R)
(define macro-L
  (add-caption
    "Untyped only"
    (tag-pict (make-program-pict #:bg-color transparent #:frame-color transparent program-blank) u-tag)))
(define macro-R
  (add-caption
    "Untyped/Typed mix"
    (tag-pict (make-program-pict #:bg-color white #:frame-color black program-blank) t-tag)))
(define abstract-L
  (make-untyped-icon #:font-size big-node-size #:width program-w #:height program-h))
(define abstract-R
  (hc-append
    (make-untyped-icon #:font-size big-node-size)
    (make-tu-icon "+" #:font-size big-node-size)
    (make-typed-icon #:font-size big-node-size)))
(define concrete-L
  (make-tree program-w program-h untyped-program-code* #:arrows? #false))
(define concrete-R
  (make-program-pict #:bg-color white #:frame-color black (make-tree program-w program-h mixed-program-code* #:arrows? #true)))

(define sample-mixed-program
  (make-program-pict #:bg-color white #:frame-color black (make-tree program-w program-h mixed-program-code* #:arrows? #true)))

(define scripting-pict
  (make-big-ut-pict
    (lightbulb
      #:border-width 1
      #:bulb-radius 45
      #:stem-width-radians (* 1/10 turn)
      #:stem-height 12)
    (bitmap "src/parthenon-logo.png")))

(define ocaml-tag 'ocaml)
(define ocaml-pict (bitmap "src/ocaml-logo-small.png"))

(define reuse-pict
  (make-big-tu-pict
    (tag-pict ocaml-pict ocaml-tag)
    (bitmap "src/opengl-logo-small.png")))

(define (make-x-line angl [w #f] [h #f])
  (filled-rounded-rectangle w h 2 #:color "red" #:angle angl #:draw-border? #f))

(define big-X
  (let* ((x-w (* 5/100 client-w))
         (x-h (* 80/100 client-h)))
    (ppict-do
      (blank (w%->pixels 15/100) x-h)
      #:go (coord 1/2 1/2 'cc) (make-x-line (* -20/100 turn) x-h x-w)
      #:go (coord 1/2 1/2 'cc) (make-x-line (* 20/100 turn) x-h x-w))))

(define (sec:migration)
  (let ((star-tag 'addstar))
    (pslide
      ;; what to say is one question, what to write here is certain to change tho
      ;; furthermore tech. framework prove blame better
      ;#:go heading-text-coord @st{Thesis}
      #:go (coord 1/2 slide-top 'ct #:sep tiny-y-sep)
      (make-ribbon
        #:color full-sound-color
        (make-illustration-text
          (hb-append @t{Type soundness is not enough})))
      (make-ribbon
        #:color complete-monitoring-color
        (make-illustration-text
          (hb-append (tag-pict @t{Complete monitoring } star-tag) (blank 2 0) @t{ is crucial})
          (hb-append @t{for } @bt{meaningful} @t{ gradual types})))
      (make-ribbon
        #:color bsbc-color
        (make-illustration-text
          (hb-append @t{"Incomplete" monitoring provides a way to})
          (hb-append @bt{measure} @t{ the quality of blame errors})))
      #:go (coord slide-right slide-bottom 'rb) @t{*from ESOP 2012}
      #:go (at-find-pict star-tag  rb-find 'rb #:abs-x -3 #:abs-y -2) @t{*}))
  (pslide
    #:go heading-text-coord
    @st{Mixed-Typed Code}
    #:next
    #:go big-program-coord-right (add-caption "Untyped/Typed mix" sample-mixed-program)
    #:go slide-text-coord
    (vl-append
      med-y-sep
      (vl-append small-y-sep (blank) (hc-append tiny-x-sep U-node @t{= untyped code}))
      (hc-append tiny-x-sep T-node (hc-append @t{= } (tag-pict @t{simply-typed} 't-line)))
      (vl-append small-y-sep (blank) @t{(no 'Dynamic' type)}))
    #:go (at-find-pict 't-line lb-find 'lt #:abs-y pico-y-sep) @t{code})
  (let* ((motivation-x-l 22/100)
         (motivation-x-r 78/100)
         (motivation-y 18/100))
    (pslide
      #:go heading-text-coord
      @st{A Few Motivations}
      #:go (coord 1/2 20/100 'ct)
      (filled-rectangle 1 client-h #:color black #:draw-border? #f)
      #:go (coord 1/2 13/100 'ct)
      (scale sample-mixed-program 0.64)
      #:next
      #:go (coord motivation-x-l motivation-y 'ct #:sep small-y-sep)
      @t{Prototyping}
      #:next
      scripting-pict
      (make-illustration-text
        @t{write untyped code,}
        @t{rely on types})
      #:next
      #:go (coord motivation-x-r motivation-y 'ct #:sep small-y-sep)
      @t{Re-Use}
      #:next
      reuse-pict
      (make-illustration-text
        @t{write typed code,}
        @t{use old libraries})))
  (let* ((m-pict @st{Many}))
    (pslide
      #:go heading-text-coord (hb-append m-pict @st{ Implementations ...})
      #:go (at-underline m-pict #:abs-y -3) (make-underline m-pict #:color black)
      #:go (coord slide-left 85/100 'lc) (shear (legend-rectangle (* 8/10 client-w) (* 12/100 client-h)) 0.5 0)
      #:go (coord slide-text-left 3/10 'lt) (make-large-flag (make-flag-text "JavaScript" "Flow") #:pole-height% 132/100)
      #:go (coord 3/10 24/100 'lt) (make-large-flag (make-flag-text "Racket" "Typed Racket") #:pole-height% 150/100)
      #:go (coord 15/100 54/100 'lt) (make-large-flag (make-flag-text "Python" "Reticulated") #:pole-height% 80/100)
      #:go (coord 77/100 40/100 'lt) (make-large-flag (make-flag-text "Python" "Mypy") #:pole-height% 115/100)
      #:go (coord 64/100 50/100 'lt) (make-large-flag (make-flag-text "PHP" "Hack") #:pole-height% 82/100)
      #:go (coord 40/100 49/100 'lt) (make-large-flag (make-flag-text "JavaScript" "TypeScript") #:pole-height% 95/100)
      #:next
      #:go (at-find-pict m-pict rb-find 'lt #:abs-x 0 #:abs-y tiny-y-sep) @st{... difficult to compare}
      #:go (coord 85/100 4/100 'rt) lang-cloud-pict)
    (pslide
      #:go heading-text-coord (hb-append m-pict @st{ Models, too})
      #:go (coord slide-right 85/100 'rc) (shear (legend-rectangle (* 6/10 client-w) (* 12/100 client-h)) 0.5 0)
      #:go (coord 40/100 49/100 'lt) (make-large-flag (t "GTLC") #:pole-height% 190/100)
      #:go (coord 72/100 43/100 'lt) (make-large-flag (t "AGT") #:pole-height% 210/100)
      #:go (coord 54/100 64/100 'lt) (make-large-flag (t "λH ") #:pole-height% 100/100)
      #:go (coord 68/100 59/100 'lt) (make-large-flag (tag-pict (t "λ* ") 'retic) #:pole-height% 138/100)
      #:go (at-find-pict 'retic cc-find 'lt) @tcodesize{→}
      #:go (coord 12/100 22/100 'lt) (make-cloud-trail-pict #true)
    ))
  (pslide
    #:go heading-text-coord @st{Goal: Characterize the Landscape}
    #:go big-landscape-coord (make-big-landscape #:theorem #f #:model #f))
  (pslide
    #:go heading-text-coord (hb-append @sbt{Non-Goal} @st{: Restrict Landscape})
    #:go big-landscape-coord
    (let* ((ls-pict (make-big-landscape #:theorem #f #:model #f))
           (w 100)
           (h (* 3/4 w))
           (dot (make-city-dot)))
      (ppict-do (cc-superimpose ls-pict (filled-rectangle (pict-width ls-pict) (pict-height ls-pict) #:color (color%-update-alpha black 0.8)))
        #:go (at-find-pict natural-tag cc-find 'cc)
        (cc-superimpose (legend-rectangle w h) (make-land-rectangle (- w 25) (- h 25)) dot)))
    #:go center-coord big-X)
  (pslide
    #:go big-landscape-coord (make-big-landscape #:theorem #f #:model #f)
    #:set
    (for/fold ((acc ppict-do-state))
              ((tag (in-list (list erasure-tag natural-tag transient-tag amnesic-tag))))
      (ppict-do acc #:go (at-find-pict tag rt-find 'lb #:abs-x (- pico-x-sep) #:abs-y pico-y-sep) yes-pict)))
  (void))

;; -----------------------------------------------------------------------------

(define optional-program (make-program-pict (make-tree program-w program-h mixed-program-code* #:arrows? #false)))

(define-values [optional-compile optional-run]
  (apply values
    (for/list ((b (in-list '(#f #t))))
      (make-program-pict (make-tree program-w program-h untyped-program-code* #:arrows? b)))))

(define (ts-txt-append . x*)
  (ts-txt-append* x*))

(define (ts-txt-append* x*)
  (apply vl-append tiny-y-sep x*))

(define (make-cite str)
  (hb-append 10 (make-small-flag) (tcodesize str)))

(define e-ts-txt
  (ts-txt-append
    (tag-pict (hb-append @bt{Erasure} @t{ semantics}) 'E)
    (hb-append @t{-  types predict nothing})))

(define t-ts-txt
  (ts-txt-append
    (tag-pict (hb-append @bt{Transient} @t{ semantics}) 'T)
    (hb-append @t{- types predict the top-level shape of values})
    (hb-append @t{- enforced by } @bt{tag checks})))

(define n-ts-txt
  (ts-txt-append
    (tag-pict (hb-append @bt{Natural} @t{ semantics}) 'N)
    (hb-append @t{- types predict the full behavior of values})
    (hb-append @t{- enforced by higher-order } @bt{wrappers})))

(define a-ts-txt
  (ts-txt-append
    (tag-pict (hb-append @bt{Amnesic} @t{ semantics}) 'A)
    (hb-append @t{- enforce } @bt{tag checks} @t{  } (t (tagof "T")))
    (hb-append @t{   with } @t{higher-order } @bt{wrappers})))

(define uhoh-circle
  (circle 100 #:border-color racket-red #:border-width 16))

(define (sec:TS)
  (pslide
    #:go heading-text-coord
    @st{Warmup: Optional Typing / Erasure}
    #:go big-landscape-coord
    (make-big-landscape #:theorem erasure-tag #:model #f))
  (pslide
    #:go heading-text-coord
    @st{Example: Optional Typing}
    #:go (coord 30/100 big-program-y 'ct)
    (make-typed-codeblock
      (hc-append @ckwdt{function} @ct|{ f (x : }| @ctypet{[N,N]} @ct|{) {}|)
      ;; @ct|{  // x can refer to ANY value}|
      (hc-append @ct|{  ... }| (tag-pict @ct{fst x} pair-tag) @ct|{ ...}|)
      @ct|{}}|)
    #:next
    #:go (coord 70/100 big-program-y 'ct)
    (make-untyped-codeblock
      @ct|{f(9)        }|)
    #:next
    #:set
    (let* ((pp (add-code-underline ppict-do-state pair-tag))
           (txt-pict
            (make-code-callout
              #:background-color (add-region-alpha erasure-color)
              #:frame-color erasure-color
              #:x-margin tiny-x-sep #:y-margin tiny-y-sep
              (vl-append
                pico-y-sep
                (hb-append @t{Error:} (bigct " 9 ") @t{is not a pair}))))
           (x-sep (* -3/10 (pict-width txt-pict)))
           (y-sep (* 1/10 (pict-height txt-pict))))
      (ppict-do pp #:go (at-find-pict pair-tag cb-find 'lt #:abs-x x-sep #:abs-y y-sep) txt-pict))
    #:next
    #:go (coord 1/2 53/100 'ct)
    (make-illustration-text
      (hc-append @t{types are } @bt{meaningless} @t{ at run-time})
      (hc-append @bt{cannot help} @t{ debug a faulty program})))
  (pslide
    #:go heading-text-coord
    (hc-append (make-optional-region 100 50 #f) @st{ = Does Not Preserve Types})
    #:go big-landscape-coord
    (make-big-landscape #:theorem 'erasure+label #:model #f)
    #:next
    #:go (at-find-pict transient-tag lc-find 'lc #:abs-x -4 #:abs-y -1)
    (scale (make-region-label "\"type\" sound") 3/2))
  (pslide
    ;; is there a useful heading besides "spectrum"?
    #:go heading-text-coord
    @st{ICFP '18}
    #:go (coord 1/2 1/2 'cc)
    (scale-to-fit (bitmap "src/icfp-bubble.png") client-w client-h))
  (let* ((txt-coord (coord slide-text-left 18/100 'lt #:sep small-y-sep))
         (y-sep (h%->pixels 3/100)))
    (pslide
      #:go heading-text-coord icfp-summary-title
      #:go txt-coord
      #:next e-ts-txt #:next t-ts-txt #:next n-ts-txt
      #:next
      #:set
      (for/fold ((acc ppict-do-state))
                ((tag (in-list '(E T N)))
                 (str (in-list (list U-sound-str tag-sound-str full-sound-str)))
                 (h (in-list '(100 150 150)))
                 (color (in-list (list erasure-color tag-sound-color full-sound-color))))
        (ppict-do acc
          #:go (at-find-pict tag rt-find 'ct #:abs-x 10 #:abs-y -16)
          (make-ribbon #:y-margin y-sep #:color color (blank 0 h))
          #:go (at-find-pict tag rt-find 'lt #:abs-x 20 #:abs-y -10) (make-region-label str)))
      #:go txt-coord e-ts-txt t-ts-txt n-ts-txt))
  (pslide
    #:go heading-text-coord
    @st{ICFP '18: A Spectrum of Type Soundness}
    #:go big-landscape-coord (make-big-landscape #:theorem 'erasure+label #:model #f)
    #:next
    #:go big-landscape-coord (make-big-landscape #:theorem ts-tag #:model ts-tag))
  (pslide
    #:go big-landscape-coord (make-big-landscape #:theorem ts-tag #:model ts-tag)
    #:go (at-find-pict amnesic-tag cc-find 'cc) uhoh-circle)
  (let ((txt-coord (coord slide-text-left 35/100 'lt #:sep small-y-sep))
        (y-sep (h%->pixels 3/100)))
    (pslide
      #:go (coord 1/2 slide-top 'ct)
      (make-little-landscape #false)
      #:next
      #:go txt-coord t-ts-txt n-ts-txt
      #:set
      (for/fold ((acc ppict-do-state))
                ((tag (in-list '(T N)))
                 (str (in-list (list tag-sound-str full-sound-str)))
                 (h (in-list '(150 150)))
                 (color (in-list (list tag-sound-color full-sound-color))))
        (ppict-do acc
          #:go (at-find-pict tag rt-find 'ct #:abs-x 10 #:abs-y -16)
          (make-ribbon #:y-margin y-sep #:color color (blank 0 h))
          #:go (at-find-pict tag rt-find 'lt #:abs-x 20 #:abs-y -10) (make-region-label str)))
      #:go txt-coord t-ts-txt n-ts-txt))
  (pslide
    #:go (coord 1/2 slide-top 'ct)
    #:alt [(make-little-landscape #false)]
    (make-little-landscape amnesic-tag)
    #:go (coord slide-text-left 38/100 'lt #:sep small-y-sep)
    a-ts-txt
    @t{- same behavior as Transient}
    @t{- same type soundness as Natural}
    #:go (at-find-pict 'A lt-find 'lb #:abs-y -10 #:abs-x -30)
    (little-tag @tcodesize{OOPSLA '19} #:color "Yellow")
    #:go (coord 1/2 slide-bottom 'ct)
    (hc-append 60 (make-cite "Greenberg  POPL '15") (make-cite "Castagna, Lanvin  ICFP '17")))
  (pslide
    #:go heading-text-coord
    @st{Type Soundness is NOT ENOUGH}
    #:go big-landscape-coord (make-big-landscape #:theorem #t #:model #t #:cm-label unknown-sound-str))
  (void))

;; -----------------------------------------------------------------------------
;; plot example

(define plot-heading-pict @st{Example: interactive plot})
(define plot-code-x-margin (w%->pixels 4/100))
(define plot-code-y-margin (h%->pixels 4/100))
(define plot-lib-tag 'lib)
(define plot-api-tag 'api)
(define plot-client-tag 'client)
(define cm-program-y (+ big-program-y 2/100))

(define onClick-tag 'onClick)
(define badtype-tag 'bad-type)
(define ME-tag 'MouseEvent)
(define pair-tag 'pair-use)
(define handler-tag 'handler)
(define h-tag 'function-h)
(define end-tag 'function-end)
(define trace-tag 'call-trace)
(define trace2-tag 'call-trace2)

(define plot-library-x 824/1000)
(define plot-library-coord (coord plot-library-x big-program-y 'ct))

(define plot-library-code*
  (list
    (hc-append @ckwdt{class} @ct|{ ClickPlot {}|)
    (hc-append @ct|{ }| @ckwdt{constructor} @ct|{(}|)
    (hc-append @ct|{  }| (tag-pict @ct{onClick} onClick-tag) @ct|{){...}}|)
    @ct|{ }|
    @ct|{ mouseHandler(evt){}|
    (hc-append @ct|{  i = }| (tag-pict @ct|{onClick(evt)}| handler-tag))
    @ct|{  // draw i }|
    @ct|{ }}|
    @ct|{ }|
    @ct|{ show(){...}}|
    @ct|{}}|))

(define plot-api-x 497/1000)
(define plot-api-coord (coord plot-api-x big-program-y 'ct))

(define plot-api-code*
  (list
    (hc-append @ckwdt{type} @ct|{ ClickPlot {}|)
    (hc-append @ct{ } @ckwdt{constructor} @ct|{(}|)
    (hc-append @ct|{  }| (tag-pict @ctypet{([N,N]) => Image} badtype-tag) @ct|{)}|)
    ;; Note that 'Image' is a little funny ... people would expect "Void"
    @ct|{ }|
    @ct|{ mouseHandler :}|
    (hc-append @ct|{  }| @ctypet|{(}| (tag-pict @ctypet{MouseEvt} ME-tag) @ctypet|{) => Void}|)
    @ct|{ }|
    @ct|{ }|
    @ct|{ }|
    (hc-append @ct|{ show : }| @ctypet|{() => Void}|)
    @ct|{}}|))

(define plot-client-x 178/1000)
(define plot-client-coord (coord plot-client-x big-program-y 'ct))

(define plot-client-code*
  (list
    (hc-append (tag-pict (hc-append @ckwdt{function} @ct|{ h(x)}|) h-tag) @ct|{ {}|)
    (hc-append @ct|{  }| @ckwdt{if} @ct|{ (0 < }| (tag-pict @ct|{fst x}| pair-tag) @ct|{): }|)
    (hc-append @ct|{    pumpkin}|)
    (hc-append @ct|{  }| @ckwdt|{else}| @ct{:})
    (hc-append @ct|{    fish}|)
    (tag-pict @ct|{}}| end-tag)
    @ct|{ }|
    @ct|{p = ClickPlot(h)}|
    @ct|{ }|
    @ct|{p.show()}|
    @ct|{// click}|))

(define (make-plot-codeblocks lib api usr)
  (values
    (make-untyped-codeblock* lib #:title "Library" #:x-margin plot-code-x-margin #:y-margin plot-code-y-margin)
    (make-typed-codeblock* api #:title "API" #:x-margin plot-code-x-margin #:y-margin plot-code-y-margin)
    (make-untyped-codeblock* usr #:title "Client" #:x-margin plot-code-x-margin #:y-margin plot-code-y-margin)))

(define-values [plot-library-code plot-api-code plot-client-code]
  (make-plot-codeblocks plot-library-code* plot-api-code* plot-client-code*))

(define (make-empty-code-line pp*)
  (define-values [w h] (for/fold ((w 0) (h 0)) ((pp (in-list pp*))) (values (max w (pict-width pp)) (max h (pict-height pp)))))
  (blank w h))

(define (make-empty-code pp*)
  (define empty-code-line (make-empty-code-line pp*))
  (for/list ((_pp (in-list pp*)))
    empty-code-line))

(define-values [plot-library-empty plot-api-empty plot-client-empty]
  (make-plot-codeblocks (make-empty-code plot-library-code*) (make-empty-code plot-api-code*) (make-empty-code plot-client-code*)))

(define example-steps-pict
  (vl-append
    small-y-sep
    @t{1. plot data}
    @t{2. listen for a click}
    @t{3. draw an image}))

(define example-plot-w 440)
(define example-plot-h (* 3/4 example-plot-w))

(define (add-code-underline pp . tag*)
  (add-code-underline* pp tag*))

(define (add-code-underline* pp tag*)
  (for/fold ((acc pp))
            ((tag (in-list tag*)))
    (make-code-underline acc tag)))

(define small-error-txt*
  (list (hb-append @t{Error:} (bigct " MouseEvt "))
        (hb-append @t{ is not a pair})))

(define main-error-txt*
  (list (hb-append @t{Error: expected} (bigct " [N,N] "))
        (hb-append @t{ got} (bigct " MouseEvt "))
        (hb-append @t{ blaming } @bt{Library})
        (hb-append @t{ assuming the } @bt{API} @t{ types})
        @t{ are correct}))

(define (add-main-error pp #:small? [small? #true] #:label? [label? #f])
  (define txt*
    (let ((txt0 (if small? small-error-txt* main-error-txt*)))
      (if label? (cons (hb-append @t{A. No, } @tsmaller{Natural}) '()) txt0)))
  (define txt-pict
    (make-code-callout
      #:x-margin tiny-x-sep #:y-margin (* 2 tiny-y-sep) #:background-color (add-region-alpha complete-monitoring-color) #:frame-color complete-monitoring-color
      (apply vl-append pico-y-sep txt*)))
  (define sep (* 1/10 (pict-height txt-pict)))
  (ppict-do pp #:go (at-find-pict trace-tag lc-find 'rt #:abs-x sep #:abs-y (- sep)) txt-pict))

(define (add-amnesic-error pp #:label? [label? #f])
  (define txt*
    (let ((base-txt
            (list (hb-append @t{Error:} (bigct " <obj> "))
                  @t{   is not a pair})))
      (if label? (cons (hb-append @t{A. Yes, } @tsmaller{Trans/Amns}) '()) base-txt)))
  (define txt-pict
    (make-code-callout
      #:x-margin tiny-x-sep #:y-margin (* 2 tiny-y-sep)
      #:frame-color full-sound-color
      #:background-color (add-region-alpha full-sound-color)
      (apply vl-append pico-y-sep txt*)))
  (define sep (h%->pixels 15/100))
  (ppict-do pp #:go (at-find-pict pair-tag rb-find 'rt #:abs-x sep #:abs-y pico-y-sep) txt-pict))

(define (make-plot-callout pp)
  (make-code-callout pp #:x-margin tiny-x-sep #:y-margin (* 2 tiny-y-sep)))

(define (sec:plot)
  (let ((the-y 2/10))
    (pslide
      #:go heading-text-coord
      @st{Example: Transient/Amnesic vs. Natural}
      #:next
      #:go (coord plot-client-x the-y 'ct #:sep small-y-sep)
      @t{Prototyping}
      scripting-pict
      #:next
      #:go (coord plot-library-x the-y 'ct #:sep small-y-sep)
      @t{Library Re-Use}
      reuse-pict
      #:next
      #:go (coord 1/2 35/100 'ct)
      (add-rounded-border
        #:radius 2 #:x-margin small-x-sep #:y-margin small-y-sep #:frame-width 6
        (make-illustration-text
          @t{Combine:}
          @t{  untyped script   +   typed API   +   untyped library}
          @t{via a higher-order value})))
    (for ((i (in-range 3)))
      (pslide
        #:go heading-text-coord
        @st{Example: Transient/Amnesic vs. Natural}
        #:go (coord slide-text-left 30/100 'lt #:sep small-y-sep)
        example-steps-pict
        #:go (coord 70/100 the-y 'ct #:sep small-y-sep)
        @t{Clickable Plot}
        (ppict-do
          (make-plot i example-plot-w example-plot-h)
          #:go (coord 5/100 5/100 'lt)
          (let ((num-pict (sbt (number->string (add1 i)))))
            (ct-superimpose
              (circle (* 5/4 (pict-height num-pict)) #:border-color black #:border-width 4)
              num-pict))))))
  ;; introduce code
  (for ((i (in-range 3)))
    (pslide
      #:go heading-text-coord plot-heading-pict
      #:go plot-client-coord (if (< 0 i) plot-client-code plot-client-empty)
      #:go plot-library-coord (if (< 1 i) plot-library-code plot-library-empty)
      #:go plot-api-coord plot-api-empty))
  (pslide
    #:go heading-text-coord plot-heading-pict
    #:go plot-library-coord plot-library-code
    #:go plot-api-coord plot-api-code
    #:go plot-client-coord plot-client-code
    #:next
    #:alt
    [#:set (add-code-underline ppict-do-state badtype-tag)
     #:alt [#:set (add-code-underline ppict-do-state onClick-tag)]
     #:go (at-find-pict badtype-tag cb-find 'ct #:abs-y tiny-y-sep)
     (make-plot-callout
       @t{Promises a pair of numbers})
     #:next
     #:set (add-code-underline ppict-do-state h-tag)
     #:next
     #:go (at-find-pict h-tag lb-find 'lt #:abs-x (- small-x-sep) #:abs-y tiny-y-sep)
     (make-plot-callout
       @t{Expects a pair of numbers})]
    #:next
    #:alt
    [#:set (add-code-underline ppict-do-state handler-tag ME-tag)
     #:next
     #:go (at-find-pict handler-tag rb-find 'rt #:abs-y tiny-y-sep)
     (make-plot-callout
       (hb-append @t{Sends } @bigct{MouseEvt} @t{ value}))
     #:next
     #:set (add-code-underline ppict-do-state badtype-tag)
     #:go (at-find-pict badtype-tag cb-find 'ct #:abs-x 0 #:abs-y tiny-y-sep)
     (make-plot-callout
       (hb-append @bigct{[N,N]} @bigct{ != } @bigct{MouseEvt}))
     #:next
     #:go (at-find-pict end-tag lb-find 'lt #:abs-y tiny-y-sep)
     (make-plot-callout
       (ts-txt-append
         (hb-append @t{Q. Does } @bigct{h} @t{ receive})
         (hb-append @t{     bad input?})))]
  #:go (at-find-pict end-tag lb-find 'lt #:abs-y tiny-y-sep)
  (make-plot-callout
    (ts-txt-append
      (hb-append @t{Q. Does } @bigct{h} @t{ receive})
      (hb-append @t{     bad input?})))
  #:next
  #:set
  (let* ((pp (add-code-underline ppict-do-state pair-tag))
         (pp (pin-code-line pp (find-tag pp handler-tag) lb-find (find-tag pp pair-tag) rb-find)))
    (add-amnesic-error pp #:label? #t))
  #:set
  (let* ((pp (add-code-underline ppict-do-state handler-tag badtype-tag))
         (pp (pin-code-line pp (find-tag pp handler-tag) lb-find (find-tag pp badtype-tag) rb-find #:label (tag-pict (blank) trace-tag))))
    (add-main-error pp #:label? #t)))
  ;; for the programmer: do you want
  ;;  error in terms of the api, or
  ;;  silent failures that maybe detected later
  (void))

;; -----------------------------------------------------------------------------
;; complete monitoring

(define ownership-abs-y (* -57/100 (pict-height U-node)))

(define (midpt x0 x1)
  (+ x0 (/ (- x1 x0) 2)))

(define (make-ownership-anchor tag)
  (tag-pict (blank 84 50) tag))

(define ownership-v-pict
  (let ((v-pict (bigct "v")))
    (cc-superimpose (blank (* 2 (pict-width v-pict)) 0) v-pict)))

(define cm-check-pict
  (bitmap (check-icon #:material metal-icon-material #:height 55)))

(define cm-x-pict
  (bitmap (x-icon #:material metal-icon-material #:height 50)))

(define cm-proof-text
  (vl-append
    (h%->pixels 7/100)
    (vl-append
      tiny-y-sep
      @t{1. enrich the syntax with ownership labels,}
      @t{    may only drop labels after a basic check})
    (vl-append
      tiny-y-sep
      @t{2. run the program, show that every value}
      @t{    has exactly one label})))

(define hyper-arrow-pict (blank 5 35))

(define cm-basic-arrow*
  (list
    (program-arrow 'L-E rt-find 'C-W lt-find (* 1/8 turn) (* 7/8 turn) 1/4 1/4 black)
    (program-arrow 'C-E rt-find 'R-W lt-find (* 1/8 turn) (* 7/8 turn) 1/4 1/4 black)
    (program-arrow 'R-W lb-find 'L-E rb-find (* 5/8 turn) (* 3/8 turn) 1/4 1/4 black)))

(define cm-basic-arrow-lbl*
  (list (tag-pict hyper-arrow-pict 'aa) (tag-pict hyper-arrow-pict 'bb) (tag-pict (blank 320 0) 'X)))

(define cm-basic-arrow-width* '(#f #f 4))

(define cm-hyper-main*
  (list
    (program-arrow 'aa ct-find 'cc ct-find #f #f 0 0 black)
    (program-arrow 'bb ct-find 'dd ct-find #f #f 0 0 black)))

(define cm-hyper-side*
  (list
    (program-arrow 'aa lt-find 'cc lt-find #f #f 0 0 black)
    (program-arrow 'bb rt-find 'dd rt-find #f #f 0 0 black)
    (program-arrow 'aa rt-find 'cc rt-find #f #f 0 0 black)
    (program-arrow 'bb lt-find 'dd lt-find #f #f 0 0 black)))

(define cm-ts-ribbon
  (make-ribbon
    #:color (color%-update-alpha code-highlight-color 0.4)
    (make-illustration-text
      @st{A1. No, because type soundness does not}
      @st{require protection for untyped code})))

(define cm-cm-ribbon
  (make-ribbon
    #:color region-D-color
    (make-illustration-text
      ;; TODO this is the central claim of the paper
      ;; property from contracts, been ignored by half of the GT community
      ;; who assume types are correct and prove "cant be blamed"
      @st{A2. Yes, if type soundness is strengthened}
      (hc-append @st{with } @sbt{complete monitoring}))))

(define (little-tag pp #:color c)
  (scale (add-rounded-border pp #:radius 15 #:x-margin tiny-x-sep #:y-margin tiny-y-sep #:background-color c) 0.8))

(define (add-cm-arrow* pp sty*)
  (for/fold ((acc pp))
            ((lw (in-list cm-basic-arrow-width*))
             (lbl (in-list cm-basic-arrow-lbl*))
             (arr (in-list cm-basic-arrow*))
             (sty sty*))
    (add-program-arrow acc arr #:line-width lw #:label lbl #:style sty)))

(define a-cm-txt
  (make-illustration-text
    (hb-append @bt{Transient} @t{/} @bt{Amnesic} @t{: no, because the channel})
    @t{   is between two untyped components}))

(define n-cm-txt
  (make-illustration-text
    (hb-append @bt{Natural} @t{: yes, because the channel})
    (hb-append @t{   was created via} @t{ typed code})))

(define implies-pict
  ((make-string->body #:size 70) "⇒"))

(define (sec:CM)
  (pslide
    #:go (coord plot-client-x cm-program-y 'ct) (add-hubs U-node 'L)
    #:go (coord plot-api-x cm-program-y 'ct) (add-hubs T-node 'C)
    #:go (coord plot-library-x cm-program-y 'ct) (add-hubs U-node 'R)
    #:next
    #:alt
    [#:set (add-cm-arrow* ppict-do-state '(solid))
     #:go (at-find-pict 'aa lt-find 'lb)
     @bigct{h}]
    #:alt
    [#:set (add-cm-arrow* ppict-do-state '(short-dash solid))
     #:go (at-find-pict 'bb lt-find 'lb)
     @bigct{h}]
    #:set
    (let* ((pp (add-cm-arrow* ppict-do-state '(short-dash short-dash solid))))
      (ppict-do
        pp
        #:go (at-find-pict 'X cb-find 'ct #:abs-x 0 #:abs-y 91) @bigct{h(evt)}
        #:go (at-find-pict 'X lb-find 'cc #:abs-x 1/2 #:abs-y 60) (tag-pict (blank 4 16) 'cc)
        #:go (at-find-pict 'X rb-find 'cc #:abs-x -2 #:abs-y 60) (tag-pict (blank 4 21) 'dd)
        #:set
        (for/fold ((acc (for/fold ((acc ppict-do-state))
                                  ((arr (in-list cm-hyper-main*)))
                          (add-program-arrow acc arr #:arrow-size 18 #:style 'transparent #:hide? #false))))
                  ((arr (in-list cm-hyper-side*)))
          (add-program-arrow acc arr #:style 'solid #:line-width 2 #:hide? #true))))
    #:go heading-text-coord
    (hc-append @st{Q. Do types guard the } @sbt{callback} @st{ channel?})
    #:next
    #:go (coord 1/2 43/100 'ct #:sep tiny-y-sep)
    #:alt
    [(make-ribbon
       #:color full-sound-color #:y-margin small-y-sep
       a-cm-txt)
     (make-ribbon
       #:color complete-monitoring-color #:y-margin small-y-sep
       n-cm-txt)]
    (make-ribbon
      #:color full-sound-color #:y-margin small-y-sep
      (cc-superimpose
        (blank 0 (pict-height a-cm-txt))
        (hc-append @bt{Type Soundness } (tag-pict implies-pict 'ts-implies)  @t{ maybe not})))
    (make-ribbon
      #:color complete-monitoring-color #:y-margin small-y-sep
      (cc-superimpose
        (blank 0 (pict-height n-cm-txt))
        (hc-append @bt{Complete Monitoring } implies-pict @t{ yes})))
    #:go (at-find-pict 'ts-implies cc-find 'cc)
    (make-x-line (* 40/100 turn) 10 80))
  (pslide
    #:go big-landscape-coord (make-big-landscape))
  (pslide
    #:go heading-text-coord
    #:alt
    [(make-result-table
       (list
         (tag-pict (tr-append @bt{type} @bt{soundness}) table-row-tag) @bigct{T} (bigct (tagof "T")) @bigct{T}
         (tag-pict (tr-append @bt{complete} @bt{monitoring}) table-row-tag) yes-pict no-pict no-pict
         (tag-pict (hide (tr-append @bt{blame} @bt{soundness})) table-row-tag)     (hide yes-pict) (hide no-pict) (hide yes-pict)
         (tag-pict (hide (tr-append @bt{blame} @bt{completeness})) table-row-tag)  (hide yes-pict) (hide no-pict) (hide yes-pict)))]
    (make-result-table
      (list
        (tag-pict (tr-append @bt{type} @bt{soundness}) table-row-tag) @bigct{T} (bigct (tagof "T")) @bigct{T}
        (tag-pict (tr-append @bt{complete} @bt{monitoring}) table-row-tag) yes-pict no-pict no-pict
        (tag-pict (tag-pict (hide (tr-append @bt{blame} @bt{soundness})) 'goblame) table-row-tag)     (hide yes-pict) (hide no-pict) (hide yes-pict)
        (tag-pict (hide (tr-append @bt{blame} @bt{completeness})) table-row-tag)  (hide yes-pict) (hide no-pict) (hide yes-pict)))
    #:go (at-find-pict 'goblame lc-find 'lt) @t{BLAME})
  (void))

;; -----------------------------------------------------------------------------
;; blame soundness blame completeness

(define bsbc-pict
  (scale (make-tree big-program-w big-program-h mixed-program-code* #:arrows? 'path #:owners? #true #:labels? #false) 0.9))

(define (sec:BSBC)
  #;(pslide
    #:go heading-text-coord
    @t{state-of-art = blame theorem}
    @t{ assumes types correct})
  (pslide
    #:go heading-text-coord @st{Natural, Blame}
    #:go plot-library-coord plot-library-code
    #:go plot-api-coord plot-api-code
    #:go plot-client-coord plot-client-code
    #:next
    #:set (add-code-underline ppict-do-state handler-tag badtype-tag)
    #:set (let ((pp ppict-do-state)) (pin-code-line pp (find-tag pp handler-tag) lb-find (find-tag pp badtype-tag) rb-find #:label (tag-pict (blank) trace-tag)))
    #:alt [#:set (add-main-error ppict-do-state #:small? #true)]
    #:set (add-main-error ppict-do-state #:small? #false))
  (pslide
    #:go heading-text-coord @st{Transient/Amnesic, Blame}
    #:go plot-library-coord plot-library-code
    #:go plot-api-coord plot-api-code
    #:go plot-client-coord plot-client-code
    #:next
    #:set (add-code-underline ppict-do-state pair-tag)
    #:go (at-find-pict pair-tag rb-find 'rt #:abs-x small-x-sep #:abs-y tiny-y-sep)
    (make-code-callout
      #:x-margin tiny-x-sep #:y-margin (* 2 tiny-y-sep)
      #:frame-color full-sound-color
      #:background-color (add-region-alpha full-sound-color)
      (vl-append
        pico-y-sep
        (hb-append @t{Error:} (bigct " <obj> "))
        @t{   is not a pair}
        (hb-append @t{   blaming: })
        (hb-append @t{     } @bt{Client} @t{ / } @bt{API})
        (hb-append @t{     } @bt{API} @t{ / } @bt{Library}))))
  (pslide
    #:go (coord slide-right 2/10 'rt)
    bsbc-pict
    #:go heading-text-coord
    @st{Blame Properties}
    #:go (coord slide-text-left 2/10 'lt)
    (vl-append
      med-y-sep
      (vl-append
        tiny-y-sep
        (tag-pict (hc-append @t{1. blame } @bt{only}) 'BST)
        (hb-append 50 (blank) @t{responsible edges}))
      (vl-append
        tiny-y-sep
        (tag-pict (hc-append @t{2. blame } @bt{all}) 'BCT)
        (hb-append 50 (blank) @t{responsible edges})))
    (blank 0 (h%->pixels 15/100))
    (vl-append
      tiny-y-sep
      (tag-pict (hc-append @t{3.} @t{ blame } @bt{exactly} @t{ the} @t{ responsible edges}) 'BSBCT))
    #:next
    #:set
    (for/fold ((acc ppict-do-state))
              ((tag (in-list '(BST BCT BSBCT)))
               (str (in-list '("Blame Soundness" "Blame Completeness" "B. Soundness + B. Completeness"))))
      (ppict-do acc #:go (at-find-pict tag lt-find 'lb #:abs-y (- pico-y-sep)) (make-region-label str))))
  (pslide
    #:go heading-text-coord
    #:alt
    [(make-result-table
       (list
         (tag-pict (tr-append @bt{type} @bt{soundness}) table-row-tag) @bigct{T} (bigct (tagof "T")) @bigct{T}
         (tag-pict (tr-append @bt{complete} @bt{monitoring}) table-row-tag) yes-pict no-pict no-pict
         (tag-pict (tr-append @bt{blame} @bt{soundness}) table-row-tag)     yes-pict (hide no-pict) (hide yes-pict)
         (tag-pict (tr-append @bt{blame} @bt{completeness}) table-row-tag)  yes-pict (hide no-pict) (hide yes-pict)))]
    (make-result-table
      (list
        (tag-pict (tr-append @bt{type} @bt{soundness}) table-row-tag) @bigct{T} (bigct (tagof "T")) @bigct{T}
        (tag-pict (tr-append @bt{complete} @bt{monitoring}) table-row-tag) yes-pict no-pict no-pict
        (tag-pict (tr-append @bt{blame} @bt{soundness}) table-row-tag)     yes-pict no-pict yes-pict
        (tag-pict (tr-append @bt{blame} @bt{completeness}) table-row-tag)  yes-pict no-pict yes-pict)))
  (void))

;; -----------------------------------------------------------------------------
;; in paper, Amnesic

(define (sec:in-paper)
  #;(pslide
  ;; TODO need this??
    ;; back to landscape, have id'd 3 points for CM BS BC
    #:go illustration-text-coord
    (make-illustration-text
      @st{Have CM, BS, BC}
      @st{The TS / CM gap explained by Amnesic})
    #:go illustration-pict-coord
    (make-landscape big-landscape-size #:fog? #f))
  #;(pslide
    #:go heading-text-coord
    (make-result-table
      (list
        (tag-pict (tr-append @bt{type} @bt{soundness}) table-row-tag) @bigct{T} (bigct (tagof "T")) @bigct{T}
        (tag-pict (tr-append @bt{complete} @bt{monitoring}) table-row-tag) yes-pict no-pict no-pict
        (tag-pict (tr-append @bt{blame} @bt{soundness}) table-row-tag)     yes-pict no-pict yes-pict
        (tag-pict (tr-append @bt{blame} @bt{completeness}) table-row-tag)  yes-pict no-pict yes-pict))
    #:next
    #:go (coord )
    (add-rounded-border
      #:radius 10 #:x-margin tiny-x-sep #:y-margin tiny-y-margin
      ((string->body #:size 60) "?")))
  (void))

;; -----------------------------------------------------------------------------
;; takeaways

(define (sec:takeaways)
  (pslide
    #:go heading-text-coord
    @st{Every Typed Language is Mixed-Typed}
    #:go (coord slide-text-left slide-text-top 'lt)
    reuse-pict
    #:go (coord 45/100 slide-text-top 'lt #:sep med-y-sep)
    (ts-txt-append
      @t{Many typed languages}
      (hb-append @bt{trust} @t{ untyped code}))
    #:next
    (ts-txt-append
      (hb-append @t{Gradual typing makes these})
      (hb-append @t{boundaries } @bt{visible} @t{ ...}))
    #:go (at-find-pict reuse-pict cc-find 'cc #:abs-x (- pico-x-sep) #:abs-y (+ pico-y-sep))
    (make-big-tu-pict
      (make-tu-icon "T")
      (make-tu-icon "U"))
    #:next
    #:go (coord slide-text-left 62/100 'lt)
    (ts-txt-append
      (hb-append @t{... and } @bt{challenges} @t{ our notions of } @t{types} @t{ and})
      @t{      what types mean})
    )
  (pslide
    #:go (coord 1/2 2/10 'ct #:sep small-y-sep)
    (make-ribbon
      #:color racket-blue
      (make-illustration-text
        (hb-append @t{Complete monitoring } (blank 3 0) @bt{strengthens} @t{ type soundness})
        (hb-append @t{for programs that } @bt{compose} @t{ typed and untyped})
        @t{ }
        (hb-append @t{and } @bt{enables} @t{ precise statements about})
        (hb-append @t{the quality of blame}))))
  (void))

;; -----------------------------------------------------------------------------

(define (url-t str)
  (hyperlinkize (text str "Triplicate T4s" (current-font-size))))

(define (sec:extra)
  (pslide
    #:go (coord 1/2 40/100 'ct)
    (tag-pict @url-t{github.com/nuprl/gfd-oopsla-2019} 'url)
    #:go (at-find-pict 'url lt-find 'lb #:abs-x (- tiny-x-sep) #:abs-y (- small-y-sep))
    @t{Code + Proofs:})
  (pslide
    #:go heading-text-coord
    (make-result-table
      (list
        (tag-pict (tr-append @bt{type} @bt{soundness}) table-row-tag) @bigct{T} (bigct (tagof "T")) @bigct{T}
        (tag-pict (tr-append @bt{complete} @bt{monitoring*}) table-row-tag) yes-pict no-pict no-pict
        (tag-pict (tr-append @bt{blame} @bt{soundness*}) table-row-tag)     yes-pict no-pict yes-pict
        (tag-pict (tr-append @bt{blame} @bt{completeness*}) table-row-tag)  yes-pict no-pict yes-pict)))
  (pslide
    (make-big-landscape))
  (void))

;; -----------------------------------------------------------------------------
;; drawing proxies & communication AGAIN lol

(define (sec:CM-proxy-viz)
  (pslide
    ;; TOOD need better visual for proxy
    ;;  "for HO channel send some knd of proxy, details unimportant"
    #:go heading-text-coord
    (hb-append @st{Idea: } (tag-pict @t{a semantics satisfies complete monitoring} 'idea-txt))
    #:go (at-find-pict 'idea-txt lb-find 'lt #:abs-y (h%->pixels 2/100))
    (vl-append
      (h%->pixels 2/100)
      @t{if every value that crosses a boundary}
      @t{meets the type obligations})
    #:go (coord slide-left 28/100 'lt)
    (make-boundary-check-pict
      cm-check-width cm-check-height
      @t{N}
      @t{num?})
    #:go (coord (+ 1/2 slide-left) 28/100 'lt)
    (make-boundary-check-pict
      cm-check-width cm-check-height
      @t{[N,N]}
      (vc-append
        (h%->pixels 1/100)
        @t{pair of}
        @t{num?}))
    #:go (coord (+ 1/2 slide-left) 60/100 'ct)
    (make-boundary-check-pict
      (* 3/2 cm-check-width) cm-check-height
      @t{(N) => N}
      @t{fun?}))
  (void))

;; -----------------------------------------------------------------------------
;; outline

(define-values [blank-body-pict sta-body-pict dyn-body-pict]
  (apply values (pict-bbox-sup (blank) (small-tau-icon) (small-lambda-icon))))
(define d-pict (make-component-pict/dyn #:body dyn-body-pict))
(define s-pict (make-component-pict/sta #:body sta-body-pict))
(define untyped-tree
  (ppict-do
    (blank (* 3/4 client-w) (* 3/4 client-h))
    #:go (coord 1/2 1/10 'cc) d-pict
    #:go (coord 1/2 4/10 'cc) (hc-append 200 d-pict d-pict)
    #:go (coord 1/2 7/10 'cc) (hc-append 300 (hc-append 80 d-pict d-pict) d-pict)))
(define mixed-tree
  (ppict-do
    (blank (* 3/4 client-w) (* 3/4 client-h))
    #:go (coord 1/2 1/10 'cc) (tag-pict d-pict 'A)
    #:go (coord 1/2 4/10 'cc) (hc-append 200 (tag-pict s-pict 'B) (tag-pict s-pict 'C))
    #:go (coord 1/2 7/10 'cc) (hc-append 300 (hc-append 80 (tag-pict d-pict 'D) (tag-pict d-pict 'E)) (tag-pict d-pict 'F))))

(struct val-arrow [src-tag src-find tgt-tag tgt-find start-angle end-angle start-pull end-pull label] #:transparent)

(define (add-value-arrow pp arr)
  (pin-arrow-line 8 pp
                  (find-tag pp (val-arrow-src-tag arr))
                  (val-arrow-src-find arr)
                  (find-tag pp (val-arrow-tgt-tag arr))
                  (val-arrow-tgt-find arr)
                  #:style 'short-dash
                  #:start-angle (val-arrow-start-angle arr)
                  #:end-angle (val-arrow-end-angle arr)
                  #:start-pull (val-arrow-start-pull arr)
                  #:end-pull (val-arrow-end-pull arr)
                  #:label (val-arrow-label arr)))

(define mixed-tree/values
  (for/fold ((acc mixed-tree))
            ((arr (in-list
                    (list
                      (val-arrow 'A lb-find 'B ct-find #f #f 2/4 2/4 (blank))
                      (val-arrow 'B lb-find 'D ct-find #f #f 2/4 2/4 (blank))
                      (val-arrow 'B rb-find 'E ct-find #f #f 2/4 2/4 (blank))
                      (val-arrow 'A rb-find 'C ct-find #f #f 2/4 2/4 (blank))
                      (val-arrow 'C rb-find 'F ct-find #f #f 2/4 2/4 (blank))
                      ;; 
                      (val-arrow 'B lc-find 'A lc-find (* 1/2 revolution) 0 2/4 2/4 (blank))
                      (val-arrow 'E rc-find 'C lc-find 0 0 2/4 2/4 (blank))))))
    (add-value-arrow acc arr)))

(define plot-program
    (ht-append 50
      (vl-append 10
        @tt|{class Plot {}|
        @tt|{  constructor(points,}|
        @tt|{              ..., onClick) {}|
        @tt|{    ....}|
        @tt|{  }}|
        @tt|{ }|
        @tt|{  show() {}|
        @tt|{    ....}|
        @tt|{  }}|
        @tt|{ }|
        @tt|{  mouseHandler(event) {}|
        @tt|{    img = this.onClick(event)}|
        @tt|{    ....}|
        @tt|{  }}|
        @tt|{ }}|
      )
      (vl-append 10
        @tt|{type Plot {}|
        @tt|{  constructor(}|
        @tt|{    points : Listof [Num, Num],}|
        @tt|{    ...,}|
        @tt|{    onClick : (x : [Num, Num]) => Image)}|
        @tt|{ }|
        @tt|{  show() : Void}|
        @tt|{ }|
        @tt|{  mouseHandler(event : MouseEvent) : Void}|
        @tt|{ }}|
      )
      (vl-append 10
        @tt|{function h(x) {}|
        @tt|{  ... x[0] ...}|
        @tt|{}}|
        @tt|{ }|
        @tt|{plot = new PointPlot(...., onClick=h)}|
        @tt|{ ... }|
        @tt|{plot.show()}|
        @tt|{// click, invokes mouseHandler}|
        @tt|{ }|
      )))

(define chain-pict
    (for/fold ((acc (hc-append 100 (tag-pict d-pict 'L) (tag-pict s-pict 'C) (tag-pict d-pict 'R))))
              ((arr (in-list
                      (list
                        (val-arrow 'L rc-find 'C lc-find (* 1/8 revolution) (* 1/8 revolution) 3/4 3/4 (blank))
                        (val-arrow 'C rc-find 'R lc-find (* 1/8 revolution) (* 1/8 revolution) 3/4 3/4 (blank))))))
      (add-value-arrow acc arr)))

(define (sec:outline)
  (pslide
    #:go (coord 1/2 1/2 'cc)
    @t{our goal: MT for migration}
    )
  (pslide
    ;; tree, dyn
    ;; tree, stat/dyn
    #:go (coord 1/2 1/2 'cc)
    #:alt [untyped-tree]
    mixed-tree
    )
  (pslide
    ;; tree, stat/dyn, value arrows
    #:go (coord 1/2 1/2 'cc)
    mixed-tree/values
    )
  (pslide
    ;; examples: racket -> tr; js -> ts; php -> hack, clojure ->> TC, python -> retic, mypy, pytype ...
    #:go (coord 1/2 1/2 'cc)
    (vc-append 20
      @t{Many examples:}
      @t{JS -> TypeScript}
      @t{PHP -> Hack}
      @t{Racket -> Typed Racket}
      @t{Python -> Retic, mypy, Pytype})
    )
  (pslide
    ;; broad context: formally charocterize the distinctions
    #:go (coord 1/2 1/2 'cc)
    @t{Broad context: formally characterize distinctions between MT systems}
    )
  (pslide
    ;; one class, ignores types at runtime ... 
    ;; [draw tree + erasure, value flowing in to typed]
    ;; characterized by type soundness, strongest claim is wesll/formed value
    ;; by contrasc ...
    #:go (coord 1/2 1/2 'cc)
    @t{one class: ignore types at runtime}
    @t{characterized by (trivial) type soundness}
    )
  (pslide
    ;; thanks to the property, easy to see the implications
    ;; ... if something goes wrong, need to consider whole program to debug
    #:go (coord SLIDE-LEFT SLIDE-TOP 'lt)
    @t{Implications}
    #:go (coord 1/2 1/2 'cc)
    (vl-append 10
      @tt|{function f (x : Num) {}|
      @tt|{  // ... need to handle any value! ...}|
      @tt|{}}|)
    #:go (coord SLIDE-LEFT SLIDE-BOTTOM 'lb)
    @t{Types are no help for debugging}
    )
  (pslide
    ;; [tree, value flows through typed component]
    #:go (coord 1/2 1/2 'cc)
    @t{In this paper: concerned with a different distinction}
    @t{(extent of types)}
    mixed-tree/values
    )
  (pslide
    ;; make concrete with example
    #:go (coord SLIDE-LEFT SLIDE-TOP 'lt)
    @t{Example: Interactive Plot}
    (ht-append 30
      (plot-pict (function sqr 0 2)
                 #:width 300 #:height 300)
      (plot-pict (list (function sqr 0 2) (point-pict (vector 1 1) (standard-fish 40 15)))
                 #:width 300 #:height 300)))
  (pslide
    ;; make concrete with an example
    ;; TODO example
    #:go (coord SLIDE-LEFT SLIDE-TOP 'lt)
    @t{Example: Interactive Plot}
    #:go (coord 1/2 1/2 'cc)
    (scale plot-program 0.4)
    )
  (pslide
    ;; at least two ways to interpret
    #:go (coord 1/2 1/2 'cc)
    @t{(At least) two interpretations}
    @t{A. untyped-to-untyped communication, client wrong to trust types}
    @t{B. typed layer should affect behavior}
    @t{ }
    @t{TS does not distinguish}
    @t{ }
    @t{Argument: Complete Monitoring distinguishes}
    ;; in terms of the program, CM says B
    )
  (pslide
    ;; [black boxes]
    #:go (coord SLIDE-LEFT SLIDE-TOP 'lt)
    @t{Generally, value may cross iff the receiver accepts full resposibility}
    @t{ if not, send a proxy}
    #:go (coord 1/2 1/2 'cc)
    chain-pict)
  (pslide
    #:go (coord 1/2 1/2 'cc)
    @t{CM implications:}
    @t{- able to detect any sender that fails its obligations}
    @t{- can precisely explain failures}
    )
  (pslide
    (scale plot-program 0.4)
    #:next
    #:go (coord 1/2 1/2 'cc)
    (add-rounded-border
      @t{Error between lib and api}
      #:x-margin 20 #:y-margin 20
      #:frame-width 4)
    )
  (pslide
    #:go (coord 1/2 1/2 'cc)
    @t{Summary: a system that satisfies CM guards all channels of communication}
    )
  (pslide
    #:go (coord SLIDE-LEFT SLIDE-TOP 'lt)
    @t{Conversely, other systems allow unchecked obligations}
    @t{IF something goes wrong, cannot pinpoint cause}
    #:go (coord 1/2 1/2 'cc)
    chain-pict
    )
  (pslide
    #:go (coord SLIDE-LEFT SLIDE-TOP 'lt)
    @t{In general, multiple responsible parties ...}
    mixed-tree/values
    )
  (pslide
    #:go (coord 1/2 1/2 'cc)
    @t{Question: can identify exactly the responsible parties?}
    @t{q1: guarantee ONLY relevant boundaries (soundness)}
    @t{q2: guarantee AT LEAST all relevant boundaries (completeness)}
    )
  (pslide
    #:go (coord 1/2 1/2 'cc)
    @t{Surprising answer: no wrappers => unsound and incomplete blame}
    @t{  may have irrelevant boundaries, may miss crucial boundaries}
    @t{ }
    @t{open question for wrapper-free MT/GT}
    )
  (pslide
    #:go (coord 1/2 1/2 'cc)
    (vc-append 20
      @t{In the paper:}
      @t{- unified model with blame algorithms: TR, Retic, compromise}
      @t{- spec for ownership (not like Rust)}
      @t{- complete monitoring, blame soundness, blame completeness})
    )
  (pslide
    #:go (coord SLIDE-LEFT SLIDE-TOP 'lt)
    (table
      4
      (list
        @t{ } Natural-pict Transient-pict Amnesic-pict
        @t{ } @t{(wrapping)} @t{(wrapper-free)} @t{(wrapping, forgetful)}
        @t{complete monitoring} yes-pict no-pict no-pict
        @t{blame soundness}     yes-pict no-pict yes-pict
        @t{blame completeness}  yes-pict no-pict yes-pict)
      (cons lc-superimpose cc-superimpose) cc-superimpose
      25 30))
  (pslide
    #:go (coord 1/2 1/2 'cc)
    (vc-append 20
      @t{PS every typed language sits on an untyped runtime}
      @t{ignored by theory; MT/GT cannot ignore}
      @t{need to think critically about conventional theorems in this generalized setting})
    )
  (pslide)
  (pslide
    ;; question-period slide
    @t{END}
    )
  (void))

;; -----------------------------------------------------------------------------

(define (sec:unused)
  (pslide
    ;; TODO pick a style ... should look different than "implications" and "landscape"
    ;; TODO cascade placer?
    #:go heading-text-coord
    @st{Example: optional typing}
    #:go (coord 1/2 big-program-y 'lt)
    @t{erase types,}
    @t{run the untyped code}
    #:go big-program-coord-left
    #:alt
    [optional-program]
    (cellophane optional-program 0.5)
    #:go (coord big-program-x big-program-y 'lt #:abs-x (w%->pixels 26/100) #:abs-y (h%->pixels 15/100))
    #:alt
    [optional-compile]
    optional-run
    #:next
    #:go center-coord
    (make-ribbon @t{Characterized by (a lack of) type soundness}))
  (pslide
    #:go heading-text-coord @st{To prove complete monitoring:}
    #:go (coord slide-text-left 44/100 'lt) cm-proof-text
    #:alt
    [#:go (coord plot-library-x cm-program-y 'ct) U-node
     #:go (coord plot-api-x cm-program-y 'ct) T-node
     #:go (coord plot-client-x cm-program-y 'ct) U-node]
    #:go (coord plot-library-x cm-program-y 'ct #:abs-y ownership-abs-y) (add-hubs (add-ownership U-node 0) 'L)
    #:go (coord plot-api-x cm-program-y 'ct #:abs-y ownership-abs-y) (add-hubs (add-ownership T-node 1) 'C)
    #:go (coord plot-client-x cm-program-y 'ct #:abs-y ownership-abs-y) (add-hubs (add-ownership U-node 2) 'R)
    #:go (coord (midpt plot-library-x plot-api-x) cm-program-y #:abs-y (- ownership-abs-y)) (make-ownership-anchor 'LC)
    #:go (coord (midpt plot-api-x plot-client-x) cm-program-y #:abs-y (- ownership-abs-y)) (make-ownership-anchor 'CR)
    #:next
    #:go (at-find-pict 'LC lt-find 'cc)
    (add-hubs (add-ownership ownership-v-pict 0) 'v0)
    #:set (add-program-arrow ppict-do-state (program-arrow 'L-E rt-find 'v0-W lc-find 0 0 1/4 1/4 black))
    #:next
    #:go (at-find-pict 'LC cb-find 'ct) cm-check-pict
    #:next
    #:go (at-find-pict 'LC rt-find 'cc)
    (add-hubs (add-ownership ownership-v-pict 1) 'v1)
    #:set
    (for/fold ((acc ppict-do-state))
              ((arr (in-list (list (program-arrow 'v0-E rc-find 'v1-W lc-find 0 0 0 0 black) (program-arrow 'v1-E rc-find 'C-W lt-find 0 0 1/4 1/4 black)))))
      (add-program-arrow acc arr))
    #:next
    #:go (at-find-pict 'CR lt-find 'cc)
    (add-hubs (add-ownership ownership-v-pict 1) 'v2)
    #:set (add-program-arrow ppict-do-state (program-arrow 'C-E rt-find 'v2-W lc-find 0 0 1/4 1/4 black))
    #:next
    #:go (at-find-pict 'CR cb-find 'ct) cm-x-pict
    #:next
    #:go (at-find-pict 'CR rt-find 'cc)
    (add-hubs (add-ownership* ownership-v-pict '(1 2)) 'v3)
    #:set
    (for/fold ((acc ppict-do-state))
              ((arr (in-list (list (program-arrow 'v2-E rc-find 'v3-W lc-find 0 0 0 0 black) (program-arrow 'v3-E rc-find 'R-W lt-find 0 0 1/4 1/4 black)))))
      (add-program-arrow acc arr)))
  (pslide
    #:go heading-text-coord @st{Tradeoffs: complete monitoring}
    #:go illustration-text-coord
    ;; add picture?
    ;;   check-pict
    ;;   (scale (face 'sortof-unhappy) 1/5)
    (vl-append
      tiny-y-sep
      @t{+ offers useful guarantees}
      @t{- demands run-time support})
    #:next
    #:go illustration-pict-coord
    (make-landscape big-landscape-size #:fog? #false #:focus (cons 41/100 37/100)))
  (pslide
    ;; can use same tools, ownership labels, to talk about existing (same enriched language)
    #:go heading-text-coord
    @st{Implications: lack of complete monitoring}
    #:go illustration-text-coord
    @t{value may accumulate unchecked obligations}
    #:go (coord slide-left 35/100 'lt)
    bsbc-pict
    #:next
    #:go (coord slide-text-right 30/100 'rt)
    (make-legend
      @t{Challenge: if an error}
      @t{ occurs, identify the}
      @t{ responsible parties}))
  (pslide
    ;; TODO hmph, 3 bullet points here
    #:go heading-text-coord
    @st{Open question for 'transient' migratory typing}
    #:go (coord 1/2 30/100 'cc)
    @t{How close a language without proxies get}
    @t{to blame soundness and completeness?}
    #:go (coord slide-text-left 46/100 'lt)
    @t{- easy to blame nothing, or everything}
    (blank 0 small-y-sep)
    @t{- useful middle point?}
    (blank 0 small-y-sep)
    @t{- may need to explore a relaxed model}
    @t{   of ownership})
  (void))

;; =============================================================================

(module+ main
  (do-show))

(define (make-font-table-pict str)
  (table
    2
    (for/fold ([acc '()]
               #:result (reverse acc))
              ([face (in-list (get-face-list))]
               #;[i (in-range 10)])
      (list* (text str face) (text face) acc))
    lb-superimpose lb-superimpose 20 5))

(define (make-target wh #:color [pre-color #f])
  (define color (or pre-color racket-red))
  (for/fold ((acc (disk wh #:draw-border? #true #:color color #:border-width 2 #:border-color black)))
            ((i (in-range 4)))
    (define size (* (- 8 (* 2 i)) 1/10 wh))
    (cc-superimpose
      acc
      (cond
        [(= i 3)
         (cc-superimpose
           (disk (* 17/10 size) #:draw-border? #true #:border-width (* 3/10 size) #:border-color color #:color white)
           (disk (* 3/4 size) #:draw-border? #false #:color color))]
        [(= 0 (modulo i 2))
         ;; white
         (disk size #:draw-border? #false #:color white)]
        [else
         (disk size #:draw-border? #true #:border-width (* 1/10 size) #:border-color color #:color white)]))))

(define (make-boundary-check-pict w h type-pict check-pict)
  (make-program-pict
    #:x-margin 0 #:y-margin 0
    (ppict-do
      (blank w h)
      #:go (coord 5/100 25/100 'lt)
      (add-hubs U-node 'L)
      #:go (coord (- 1 5/100) 25/100 'rt)
      (add-hubs T-node 'R)
      #:go (coord 1/2 35/100 'ct)
      (add-hubs (add-rounded-border
                  #:radius 1 #:background-color legend-tan #:x-margin 4
                  check-pict) 'C)
      #:go (coord 4/5 7/10 'lt)
      (add-hubs halt-pict 'X)
      #:go (coord 5/10 5/100 'ct)
      (add-rounded-border type-pict #:background-color "Ivory" #:x-margin 8 #:y-margin 4)
      #:set
      (for/fold ((acc ppict-do-state))
                ((arr (in-list
                        (list
                          (program-arrow 'L-E rt-find 'C-W lt-find 0 0 0 0 black)
                          (program-arrow 'C-E rt-find 'R-W lc-find 0 0 0 0 black)
                          (program-arrow 'C-E rb-find 'X-W lc-find 0 0 1/4 1/4 black)))))
        (add-program-arrow acc arr)))))

(module+ raco-pict
  (define raco-pict
    (add-rectangle-background #:x-margin 40 #:y-margin 40
    (begin (blank 800 600)

  (ppict-do (filled-rectangle client-w client-h #:draw-border? #f #:color ice-color)



  )
  ))
  )
  (provide raco-pict)
)

(module+ test
  (require rackunit) )
