;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Kinda2048) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp")))))
;; A World is a:
;; [List-of [List-of Value]]
;; Where each [List-of Value] represents a column of
;; values.

;; A Value is one of:
;; 0, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048


;; Posns for the numbers
(define POSNS `((,(make-posn  40  40)
                 ,(make-posn  80  40)
                 ,(make-posn 120  40)
                 ,(make-posn 160  40))
                (,(make-posn  40  80)
                 ,(make-posn  80  80)
                 ,(make-posn 120  80)
                 ,(make-posn 160  80))
                (,(make-posn  40 120)
                 ,(make-posn  80 120)
                 ,(make-posn 120 120)
                 ,(make-posn 160 120))
                (,(make-posn  40 160)
                 ,(make-posn  80 160)
                 ,(make-posn 120 160)
                 ,(make-posn 160 160))))

(define BACKGROUND (empty-scene 200 200))

;; Winning value:
(define FINAL 128)

;; Initial World:
(define START '((0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))

;   ;;;     ;;    ;;;;   ;;;   ;;; ;;;  ;;;   ;;;   ;;;;  
;    ;;    ;;    ;    ;   ;     ;   ;    ;;    ;   ;   ;  
;    ;;;   ;;   ;     ;;  ;     ;   ;    ;;;   ;  ;    ;  
;    ; ;  ; ;   ;      ;   ;   ;    ;    ; ;;  ;  ;       
;    ; ;  ; ;   ;      ;   ;   ;    ;    ;  ;  ;  ;       
;    ; ;;;  ;   ;      ;   ;;  ;    ;    ;  ;; ;  ;   ;;; 
;    ;  ;;  ;   ;      ;    ; ;     ;    ;   ; ;  ;    ;  
;    ;  ;   ;   ;;     ;    ; ;     ;    ;    ;;  ;    ;  
;    ;      ;    ;    ;     ;;;     ;    ;    ;;   ;   ;  
;   ;;;    ;;;    ;;;;       ;     ;;;  ;;;    ;    ;;;;  

;; move-right : World -> World
;; Moves every-thing to the right
(define (move-right w)
  (map move-list-right w))

;; move-list-right : [List-of Value] -> [List-of Value]
(define (move-list-right lov)
  (cond
    [(empty? lov) empty]
    [(empty? (rest lov)) lov]
    [(zero? (first  lov)) (cons 0 (move-list-right (rest lov)))]
    [(zero? (second lov)) (cons 0 (cons (first lov)
                                        (move-list-right (rest (rest lov)))))]
    [(= (first lov) (second lov)) (cons 0 (cons (* 2 (first lov))
                                                (move-list-right (rest (rest lov)))))]
    [else (cons (first lov)
                (move-list-right (rest lov)))]))

(check-expect (move-right
               '((0  0  0  0)
                 (0  0  0  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-right
               '((0  0  0  0)
                 (0  2  0  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  2  0)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-right
               '((0  0  0  0)
                 (0  2  2  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  4  0)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-right
               '((0  0  0  0)
                 (0  2  2  2)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  4  2)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-right
               '((0  0  0  0)
                 (0  0  2  2)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  0  4)
                (0  0  0  0)
                (0  0  0  0)))


;; move-left : World -> World
;; Moves all the values to the left,
;; adding together any equal values
(define (move-left w)
  (map reverse (move-right (map reverse w))))


(check-expect (move-left
               '((0  0  0  0)
                 (0  0  0  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-left
               '((0  0  0  0)
                 (0  0  2  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  2  0  0)
                (0  0  0  0)
                (0  0  0  0)))


(check-expect (move-left
               '((0  0  0  0)
                 (0  2  2  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  4  0  0)
                (0  0  0  0)
                (0  0  0  0)))


(check-expect (move-left
               '((0  0  0  0)
                 (0  2  2  2)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (2  0  4  0)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-left
               '((0  0  0  0)
                 (0  0  2  2)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  4  0)
                (0  0  0  0)
                (0  0  0  0)))


;; flip-left : World -> World
;; "Flips" the values on the world board
;; counter-clockwise
(define (flip-left w)
  (list (get-all-at-x w 3)
        (get-all-at-x w 2)
        (get-all-at-x w 1)
        (get-all-at-x w 0)))

;; *NOTE* Could've done helper here, although trivial
;; if the 4x4 size is kept.

;; get-all-at-x : World Number -> [List-of Value]
;; Makes a new list with the Xth value of each list
;; in the given world
(define (get-all-at-x w x)
  (cond
    [(empty? w) '()]
    [(cons?  w) (cons (list-ref (first w) x)
                      (get-all-at-x (rest w) x))]))

(check-expect 
 (flip-left
  '((0  0  0  0)
    (0  2  2  2)
    (0  0  0  0)
    (0  0  0  0)))
 '((0  2  0  0)
   (0  2  0  0)
   (0  2  0  0)
   (0  0  0  0)))
(check-expect
 (flip-left '((0  0  0  0)
              (2  0  4  0)
              (0  0  0  0)
              (0  0  0  0)))
 '((0  0  0  0)
   (0  4  0  0)
   (0  0  0  0)
   (0  2  0  0)))

(check-expect
 (flip-left
  (flip-left
   (flip-left
    (flip-left '((0  0  0  0)
                 (2  0  4  0)
                 (0  0  0  0)
                 (0  0  0  0))))))
 '((0  0  0  0)
   (2  0  4  0)
   (0  0  0  0)
   (0  0  0  0)))

;; Move-up : World -> World
;; Moves the pieces in the board up and
;; sums together similiar pieces
(define (move-up w)
  (flip-left
   (flip-left
    (flip-left
     (move-left
      (flip-left w))))))

(check-expect (move-up
               '((0  0  0  0)
                 (0  0  0  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-up
               '((0  0  0  0)
                 (0  0  2  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  2  0)
                (0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))


(check-expect (move-up
               '((0  0  0  0)
                 (0  2  2  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  2  2  0)
                (0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))


(check-expect (move-up
               '((0  2  2  2)
                 (0  2  0  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  4  2  2)
                (0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-up
               '((0  0  2  0)
                 (2  0  2  2)
                 (2  0  0  0)
                 (0  0  0  0)))
              '((0  0  4  2)
                (4  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))


;; move-down : World -> World
;; Moves the pieces in the board down and
;; sums together similiar pieces
(define (move-down w)
  (flip-left
   (flip-left
    (flip-left
     (move-right
      (flip-left w))))))

(check-expect (move-down
               '((0  0  0  0)
                 (0  0  0  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)
                (0  0  0  0)))

(check-expect (move-down
               '((0  0  0  0)
                 (0  0  2  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  0  0)
                (0  0  2  0)
                (0  0  0  0)))


(check-expect (move-down
               '((0  0  0  0)
                 (0  2  2  0)
                 (0  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  0  0)
                (0  2  2  0)
                (0  0  0  0)))


(check-expect (move-down
               '((0  2  2  2)
                 (0  2  0  0)
                 (0  2  0  0)
                 (0  2  2  2)))
              '((0  0  0  0)
                (0  4  2  2)
                (0  0  0  0)
                (0  4  2  2)))

(check-expect (move-down
               '((0  0  2  0)
                 (2  0  2  2)
                 (2  0  0  0)
                 (0  0  0  0)))
              '((0  0  0  0)
                (0  0  4  0)
                (4  0  0  2)
                (0  0  0  0)))
                                                                            
;    ;;;;  ;;;;;;;    ;;;;    ;;;;;;     ;;;   ;;   ;;; ;;;  ;;;  ;;;;;;;  ;;;   ;;;
;   ;  ;;  ;  ;  ;   ;    ;    ;   ;;     ;    ;;    ;   ;    ;    ;    ;   ;;    ; 
;   ;   ;  ;  ;  ;  ;     ;;   ;    ;     ;;   ;;    ;   ;    ;    ;        ;;;   ; 
;   ;         ;     ;      ;   ;    ;     ;;  ; ;;  ;    ;    ;    ;   ;    ; ;;  ; 
;    ;;       ;     ;      ;   ;   ;;      ;  ;  ;  ;    ;;;;;;    ;;;;;    ;  ;  ; 
;     ;;      ;     ;      ;   ;;;;;       ;  ;  ;  ;    ;    ;    ;   ;    ;  ;; ; 
;       ;     ;     ;      ;   ;           ;; ;  ; ;     ;    ;    ;        ;   ; ; 
;   ;   ;     ;     ;;     ;   ;            ;;   ;;;     ;    ;    ;    ;   ;    ;; 
;   ;;  ;     ;      ;    ;    ;            ;;    ;;     ;    ;    ;   ;;   ;    ;; 
;    ;;;     ;;;      ;;;;    ;;;           ;;    ;     ;;;  ;;;  ;;;;;;;  ;;;    ; 
                                                                                  
;; stop? : World -> Boolean
;; Checks if the player won or lost
(define (stop? w)
  (local
    [;; won? : World -> Boolean
     ;; Checks if the player won
     (define (won? w)
       (ormap (λ (l) (ormap (λ (x) (= x FINAL)) l)) w))
     ;; lost? : World -> Boolean
     ;; Checks if the player lost
     (define (lost? w)
       (and (no-zeros? w)
            (cant-move? w)))
     ;; no-zeros? : World -> Boolean
     ;; Checks if there are any zeros in the board
     (define (no-zeros? w)
       (not (ormap (λ (l) (ormap zero? l)) w)))
     ;; cant-move? : World -> Boolean
     ;; Checks if no moves are available anymore
     (define (cant-move? w)
       (and (equals? (move-right w) w)
            (equals? (move-left  w) w)
            (equals? (move-up    w) w)
            (equals? (move-down  w) w)))]
    (or (won? w) (lost? w))))

;; equals? : World World -> Boolean
;; Checks if the two wolrds are the same
(define (equals? wa wb)
  (local
    [;; [List-of Value] [List-of Value] -> Boolean
     ;; Checks if the contents of both lists are the same
     ;; in the same order
     (define (same-lov? la lb)
       (cond [(and (empty? la) (empty? lb)) true]
             [(and (cons?  la) (cons?  lb)) (and (= (first la) (first lb))
                                                 (same-lov? (rest la) (rest lb)))]
             [else false]))]
    (cond
      [(and (empty? wa) (empty? wb)) true]
      [(and (cons?  wa) (cons?  wb)) (and (same-lov? (first wa) (first wb))
                                          (equals? (rest wa) (rest wb)))])))


;                                                                              
;      ;;    ;;;;;;    ;;;;;;       ;;;;;;   ;;;       ;;;;      ;;;;; ;;;  ;;;
;      ;;     ;   ;;    ;   ;;       ;    ;   ;       ;    ;    ;   ;;  ;   ;; 
;     ; ;     ;    ;;   ;    ;;      ;    ;   ;      ;     ;;  ;;    ;  ;   ;  
;     ; ;     ;     ;   ;     ;      ;   ;    ;      ;      ;  ;        ; ;;   
;    ;  ;;    ;     ;   ;     ;      ;;;;     ;      ;      ;  ;        ;;;    
;    ;   ;    ;     ;   ;     ;      ;   ;;   ;      ;      ;  ;        ;  ;   
;    ;;;;;    ;     ;   ;     ;      ;    ;   ;      ;      ;  ;        ;  ;;  
;   ;    ;;   ;    ;;   ;    ;;      ;    ;   ;    ; ;;     ;  ;     ;  ;   ;  
;   ;     ;   ;   ;;    ;   ;;       ;   ;;   ;   ;;  ;    ;    ;   ;;  ;   ;; 
;  ;;;   ;;; ;;;;;;    ;;;;;;       ;;;;;;   ;;;;;;;   ;;;;      ;;;;; ;;;  ;;;
;                                                                                                                                               

;; new-block : World Key-Event -> World
;; Adds a new 2 value to the list 75% of the time or a new
;; 4 (25% of the times).
(define (new-block w k)
  (local
    [(define RAN (random 4))
     (define VAL (if (= 2 RAN) 4 2))
     (define ROW (list-ref w 3))] ;; last row
    (cond
      [(string=? k "up")
       (set-at-index w 3
                     (if (zero? (list-ref ROW RAN))
                         (set-at-index ROW RAN VAL)
                         (list-ref (new-block w k) 3)))]
      [(string=? k "down") (flip-left
                            (flip-left
                             (new-block (flip-left
                                         (flip-left w)) "up")))]
      [(string=? k "left") (flip-left
                            (new-block (flip-left
                                        (flip-left
                                         (flip-left w))) "up"))]
      [(string=? k "right") (flip-left
                             (flip-left
                              (flip-left
                               (new-block (flip-left w) "up"))))])))

;; set-at-index : [List-of X] Number X -> [List-of X]
;; Sets the given index to the given element
(define (set-at-index l i x)
  (cond [(empty? l) empty]
        [(zero?  i) (cons x
                          (set-at-index (rest l) -1 x))]
        [else       (cons (first l)
                          (set-at-index (rest l) (sub1 i) x))]))

(check-expect (set-at-index '(1 2 3 4) 3 0) '(1 2 3 0))
(check-expect (set-at-index '(1 2 3 4) 2 0) '(1 2 0 4))
(check-expect (set-at-index '(1 2 3 4) 1 0) '(1 0 3 4))
(check-expect (set-at-index '(1 2 3 4) 0 0) '(0 2 3 4))

;; ok-handler : World Key-Event -> World
;; Acts according to the key hit
(define (ok-handler w ke)
  (cond
    [(string=? ke "up")   (new-block (move-up w)    ke)]
    [(string=? ke "down") (new-block (move-down w)  ke)]
    [(string=? ke "right")(new-block (move-right w) ke)]
    [(string=? ke "left") (new-block (move-left w)  ke)]
    [else w]))

;; render : World -> Image
;; Draws the scene
(define (render w)
  (local
    [;; Number -> Image
     (define (draw-number n)
       (text (number->string n) 20 "black"))
     ;;[List-of Value] [List-of Posn] Image -> Image
     ;; Prints a list of values at the parallel posn in the
     ;; list of posn
     (define (print-list lov lop scn)
       (cond [(and (empty? lov) (empty? lop)) scn]
             [(empty? lov) (error "print-list: no more values")]
             [(empty? lop) (error "print-list: no more posns")]
             [else (place-image (draw-number (first lov))
                                (posn-x (first lop))
                                (posn-y (first lop))
                                (print-list (rest lov) (rest lop) scn))]))]
    (print-list
     (first w)
     (first POSNS)
     (print-list
      (second w)
      (second POSNS)
      (print-list
       (third w)
       (third POSNS)
       (print-list
        (fourth w)
        (fourth POSNS)
        BACKGROUND))))))

;; bug-checker : World -> World
;; Checks for bugs
(define (bug-checker w)
  (cond
    [(not (= 4 (length w)))
     (error "World doesn't have 4 lists")]
    [(not (= 4 (length (first w))))
     (error "First list doesn't have 4 values")]
    [(not (= 4 (length (second w))))
     (error "Second list doesn't have 4 values")]
    [(not (= 4 (length (third w))))
     (error "Third list doesn't have 4 values")]
    [(not (= 4 (length (fourth w))))
     (error "Fourth list doesn't have 4 values")]
    [else w]))

;; main : Number -> World
;; Runs the game
(define (main x)
  (big-bang START
            (on-key    ok-handler)
            (to-draw   render)
            (on-tick   bug-checker)
            (stop-when stop?)))

(main 2)

(define LEFT
  (list (list 0 1 0 0)
        (list 1 0 0 0)
        (list 0 1 0 0)
        (list 0 0 0 0)))

(define UP
  '((0 0 1 0)
    (0 1 0 1)
    (0 0 0 0)
    (0 0 0 0)))

(define DOWN
  '((0 0 0 0)
    (0 0 0 0)
    (1 0 1 0)
    (0 1 0 0)))

(define RIGHT
  '((0 0 0 0)
    (0 0 1 0)
    (0 0 0 1)
    (0 0 1 0)))
(check-expect (flip-left UP)    LEFT)
(check-expect (flip-left LEFT)  DOWN)
(check-expect (flip-left DOWN)  RIGHT)
(check-expect (flip-left RIGHT) UP)