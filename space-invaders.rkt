;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))



;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))



(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))


(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))



;; Functions:

; Game -> Game
; called to let the space invader game. Start with (main START_GAME)
; no tests for main function

(define START_GAME
  (make-game empty empty (make-tank (/ WIDTH 2) 1)))

(define (main g)
  (big-bang g
    (on-tick update-game) ; Game -> Game
    (to-draw render-game) ; Game -> Image
    (on-key input-game))) ; Game KeyEvent -> Game


; Game -> Game
; advances the game over time
; :::
#;
(define (update-game g) g) ; stub

(check-random (update-game G0)
              (spawn (collision (move G0))))
(check-random (update-game G1)
              (spawn (collision (move G1))))
(check-random (update-game G2)
              (spawn (collision (move G2))))
(check-random (update-game G3)
              (spawn (collision (move G3))))

(define (update-game g)
  (spawn (collision (move g))))

; Game -> Game
; spawns new invaders
; :::
#;
(define (spawn g) g) ; stub

(check-random (spawn (make-game empty empty T0))
              (make-game (if (< (random 1000) INVADE-RATE)
                             (cons (make-invader (random WIDTH) 0 (+ (random INVADER-X-SPEED) 1))
                                   empty)
                             empty) empty T0))
(check-random (spawn (make-game (list (make-invader 150 100 6))
                                empty T0))
              (make-game (if (< (random 1000) INVADE-RATE)
                             (cons (make-invader (random WIDTH) 0 (+ (random INVADER-X-SPEED) 1))
                                   (list (make-invader 150 100 6)))
                             (list (make-invader 150 100 6))) empty T0))

(define (spawn g)
  (make-game (if (< (random 1000) INVADE-RATE)
                 (cons (make-invader (random WIDTH)
                                     0
                                     (+ (random INVADER-X-SPEED) 1))
                       (game-invaders g))
                 (game-invaders g))
             (game-missiles g)
             (game-tank g)))


; Game -> Game
; removes missiles and invaders that have collided
; :::
#;
(define (collision g) g) ; stub

(check-expect (collision (make-game (list I1) (list M1) T0))
              (make-game (list I1) (list M1) T0))
(check-expect (collision (make-game (list I1) (list M1 M2) T0))
              (make-game empty (list M1) T0))
(check-expect (collision (make-game (list I1 I2) (list M1 M2) T0))
              (make-game (list I2) (list M1) T0))

(define (collision g)
  (make-game (collide-invaders (game-invaders g) (game-missiles g))
             (collide-missiles (game-invaders g) (game-missiles g))
             (game-tank g)))


; ListOfInvaders ListOfMissiles -> ListOfInvaders
; removes the invaders if collided missiles
; :::
#;
(define (collide-invaders loi lom) loi) ; stub

(check-expect (collide-invaders (list I1)
                                (list M1))
              (list I1))
(check-expect (collide-invaders (list I1 I2)
                                (list M1 M2))
              (list I2))

(define (collide-invaders loi lom)
  (cond [(empty? lom) loi]
        [else
         (collide-invaders
          (collide-invaders-helper loi (first lom))
          (rest lom))]))


; ListOfInvaders Missile -> ListOfInvaders
; removes the invaders if the missile collided
; :::
#;
(define (collide-invaders-helper loi m) loi) ; stub

(check-expect (collide-invaders-helper (list I1) M1)
              (list I1))
(check-expect (collide-invaders-helper (list I1 I2) M1)
              (list I1 I2))
(check-expect (collide-invaders-helper (list I1 I2) M2)
              (list I2))

(define (collide-invaders-helper loi m)
  (cond [(empty? loi) empty]
        [else
         (if (collided? (first loi) m)
             (collide-invaders-helper (rest loi) m)
             (cons (first loi)
                   (collide-invaders-helper (rest loi) m)))]))
             

; Invader Missile -> Boolean
; true if the missile collided with the invader
; :::
#;
(define (collided? i m) false) ; stub

(check-expect (collided? I1 M1) false)
(check-expect (collided? I1 M2) true)
(check-expect (collided? I1 M3) true)

(define (collided? i m)
  (and (and (>= (invader-x i) (- (missile-x m) HIT-RANGE))
            (<= (invader-x i) (+ (missile-x m) HIT-RANGE)))
       (and (>= (invader-y i) (- (missile-y m) HIT-RANGE))
            (<= (invader-y i) (+ (missile-y m) HIT-RANGE)))))


; ListOfInvaders ListOfMissiles -> ListOfMissiles
; removes the missiles if collided invaders
; :::
#;
(define (collide-missiles loi lom) lom) ; stub

(check-expect (collide-missiles (list I1)
                                (list M1))
              (list M1))
(check-expect (collide-missiles (list I1 I2)
                                (list M1 M2))
              (list M1))

(define (collide-missiles loi lom)
  (cond [(empty? loi) lom]
        [else
         (collide-missiles
          (rest loi)
          (collide-missiles-helper (first loi) lom))]))


; Invader ListOfMissiles -> ListOfMissiles
; removes the missiles if collided invader
; :::
#;
(define (collide-missiles-helper i lom) lom) ; stub

(check-expect (collide-missiles-helper I1 (list M1))
              (list M1))
(check-expect (collide-missiles-helper I1 (list M1 M2))
              (list M1))

(define (collide-missiles-helper i lom)
  (cond [(empty? lom) empty]
        [else
         (if (collided? i (first lom))
             (collide-missiles-helper i (rest lom))
             (cons (first lom)
                   (collide-missiles-helper i (rest lom))))]))


; Game -> Game
; moves the missiles and the invaders
; :::
#;
(define (move g) g) ; stub

(check-expect (move (make-game empty empty T0))
              (make-game empty empty (move-tank T0)))
(check-expect (move (make-game
                     (list (make-invader (/ WIDTH 2) (/ HEIGHT 2) 5))
                     (list (make-missile (/ WIDTH 2) (/ HEIGHT 2)))
                     T1))
              (make-game (move-invaders (direct-invaders (list (make-invader (/ WIDTH 2) (/ HEIGHT 2) 5))))
                         (clean-missiles (move-missiles (list (make-missile (/ WIDTH 2) (/ HEIGHT 2)))))
                         (move-tank T1)))
(check-expect (move (make-game
                     (list (make-invader (/ WIDTH 2) (/ HEIGHT 2) -5)
                           (make-invader (- WIDTH 1) 100 3)
                           (make-invader 0 120 -1))
                     (list (make-missile (/ WIDTH 2) (/ HEIGHT 2))
                           (make-missile (/ WIDTH 3) (/ HEIGHT 3))
                           (make-missile (/ WIDTH 2) -5))
                     T1))
              (make-game (move-invaders (direct-invaders (list
                                                        (make-invader (/ WIDTH 2) (/ HEIGHT 2) -5)
                                                        (make-invader (- WIDTH 1) 100 3)
                                                        (make-invader 0 120 -1))))
                         (clean-missiles (move-missiles (list
                                        (make-missile (/ WIDTH 2) (/ HEIGHT 2))
                                        (make-missile (/ WIDTH 3) (/ HEIGHT 3))
                                        (make-missile (/ WIDTH 2) -5))))
                         (move-tank T1)))

(define (move g)
  (make-game (move-invaders (direct-invaders (game-invaders g)))
             (clean-missiles (move-missiles (game-missiles g)))
             (move-tank (game-tank g))))


; ListOfInvaders -> ListOfInvaders
; moves the invaders closer to the tank
; :::
#;
(define (move-invaders loi) loi) ; stub

(check-expect (move-invaders empty) empty)
(check-expect (move-invaders (list (make-invader 100 150 12)))
              (list (make-invader 112 162 12)))
(check-expect (move-invaders (list (make-invader 200 120 -5)
                                   (make-invader 225 125 2)))
              (list (make-invader 195 125 -5)
                    (make-invader 227 127 2)))

(define (move-invaders loi)
  (cond [(empty? loi) empty]
        [else
         (cons (make-invader (+ (invader-x (first loi))
                                (invader-dx (first loi)))
                             (+ (invader-y (first loi))
                                (abs (invader-dx (first loi))))
                             (invader-dx (first loi)))
               (move-invaders (rest loi)))]))


; ListOfInvaders -> ListOfInvaders
; changes the direction of invaders when they reach the wall
; :::
#;
(define (direct-invaders loi) loi) ; stub

(check-expect (direct-invaders empty) empty)
(check-expect (direct-invaders
               (list (make-invader (- WIDTH 5) (/ HEIGHT 2) 7)))
              (list (make-invader (- WIDTH 5) (/ HEIGHT 2) 7)))
(check-expect (direct-invaders
               (list (make-invader (+ WIDTH 2) (/ HEIGHT 3) 5)))
              (list (make-invader (+ WIDTH 2) (/ HEIGHT 3) -5)))
(check-expect (direct-invaders
               (list (make-invader (+ WIDTH 3) (/ HEIGHT 2) 5)
                     (make-invader (- WIDTH 5) (/ HEIGHT 3) 7)
                     (make-invader -1 (/ HEIGHT 2) -4)))
              (list (make-invader (+ WIDTH 3) (/ HEIGHT 2) -5)
                    (make-invader (- WIDTH 5) (/ HEIGHT 3) 7)
                    (make-invader -1 (/ HEIGHT 2) 4)))

(define (direct-invaders loi)
  (cond [(empty? loi) empty]
        [else (cons (direct-one-invader (first loi))
                    (direct-invaders (rest loi)))]))


; Invader -> Invader
; changes the direction of one invader when they reach the wall
; :::
#;
(define (direct-one-invader i) i) ; stub

(check-expect (direct-one-invader (make-invader (+ WIDTH 3) (/ HEIGHT 2) 5))
              (make-invader (+ WIDTH 3) (/ HEIGHT 2) -5))
(check-expect (direct-one-invader (make-invader (- WIDTH 5) (/ HEIGHT 3) 7))
              (make-invader (- WIDTH 5) (/ HEIGHT 3) 7))
(check-expect (direct-one-invader (make-invader -1 (/ HEIGHT 2) -4))
              (make-invader -1 (/ HEIGHT 2) 4))

(define (direct-one-invader i)
  (cond [(> (invader-x i) WIDTH)
         (make-invader (invader-x i)
                       (invader-y i)
                       (* -1 (abs (invader-dx i))))]
        [(< (invader-x i) 0)
         (make-invader (invader-x i)
                       (invader-y i)
                       (abs (invader-dx i)))]
        [else i]))


; ListOfMissiles -> ListOfMissiles
; moves the missiles towards the top of the screen
; :::
#;
(define (move-missiles lom) lom) ; stub

(check-expect (move-missiles empty) empty)
(check-expect (move-missiles (list (make-missile (/ WIDTH 2) (/ HEIGHT 2))))
              (list (make-missile (/ WIDTH 2) (- (/ HEIGHT 2) MISSILE-SPEED))))
(check-expect (move-missiles (list (make-missile (/ WIDTH 2) (/ HEIGHT 2))
                                   (make-missile (/ WIDTH 3) (/ HEIGHT 3))))
              (list (make-missile (/ WIDTH 2) (- (/ HEIGHT 2) MISSILE-SPEED))
                    (make-missile (/ WIDTH 3) (- (/ HEIGHT 3) MISSILE-SPEED))))

(define (move-missiles lom)
  (cond [(empty? lom) empty]
        [else
         (cons (make-missile (missile-x (first lom))
                             (- (missile-y (first lom)) MISSILE-SPEED))
               (move-missiles (rest lom)))]))

; ListOfMissiles -> ListOfMissiles
; cleans the missiles from the top of the screen
; :::
#;
(define (clean-missiles lom) lom) ; stub

(check-expect (clean-missiles empty) empty)
(check-expect (clean-missiles (list (make-missile (/ WIDTH 2) (/ HEIGHT 2))))
              (list (make-missile (/ WIDTH 2) (/ HEIGHT 2))))
(check-expect (clean-missiles (list (make-missile (/ WIDTH 2) -5)))
              empty)
(check-expect (clean-missiles (list (make-missile (/ WIDTH 2) (/ HEIGHT 2))
                                    (make-missile (/ WIDTH 5) -10)))
              (list (make-missile (/ WIDTH 2) (/ HEIGHT 2))))

(define (clean-missiles lom)
  (cond [(empty? lom) empty]
        [(> (missile-y (first lom)) 0)
         (cons (first lom)
               (clean-missiles (rest lom)))]
        [else (clean-missiles (rest lom))]))


; Tank -> Tank
; moves the tank
; :::
#;
(define (move-tank t) t) ; stub

(check-expect (move-tank (make-tank 50 1))
              (make-tank (+ 50 TANK-SPEED) 1))
(check-expect (move-tank (make-tank 50 -1))
              (make-tank (- 50 TANK-SPEED) -1))
(check-expect (move-tank (make-tank 0 -1))
              (make-tank 0 -1))
(check-expect (move-tank (make-tank WIDTH 1))
              (make-tank WIDTH 1))

(define (move-tank t)
  (if (= (tank-dir t) -1)
      (tank-left t)
      (tank-right t)))

 
; Tank -> Tank
; moves the tank left
#;
(define (tank-left t) t) ; stub

(check-expect (tank-left (make-tank 120 -1))
              (make-tank (- 120 TANK-SPEED) -1))
(check-expect (tank-left (make-tank 0 -1))
              (make-tank 0 -1))

(define (tank-left t)
  (if (> (tank-x t) 0)
      (make-tank (- (tank-x t) TANK-SPEED)
                 -1)
      t))

; Tank -> Tank
; moves the tank right
#;
(define (tank-right t) t) ; stub

(check-expect (tank-right (make-tank 160 1))
              (make-tank (+ 160 TANK-SPEED) 1))
(check-expect (tank-right (make-tank WIDTH 1))
              (make-tank WIDTH 1))

(define (tank-right t)
  (if (< (tank-x t) WIDTH)
      (make-tank (+ (tank-x t) TANK-SPEED)
                 1)
      t))

; Game -> Image
; renders the game onto the screen
; :::
#;
(define (render-game g) BACKGROUND) ; stub

(check-expect (render-game G0)
              (render-invaders (game-invaders G0)
                               (render-tank (game-tank G0)
                                                (render-missiles (game-missiles G0) BACKGROUND))))
(check-expect (render-game G2)
              (render-invaders (game-invaders G2)
                               (render-tank (game-tank G2)
                                                (render-missiles (game-missiles G2) BACKGROUND))))
(check-expect (render-game G3)
              (render-invaders (game-invaders G3)
                               (render-tank (game-tank G3)
                                                (render-missiles (game-missiles G3) BACKGROUND))))

(define (render-game g)
              (render-invaders (game-invaders g)
                               (render-tank (game-tank g)
                                                (render-missiles (game-missiles g) BACKGROUND))))


; ListOfInvaders Image -> Image
; renders the invaders onto the game
; :::
#;
(define (render-invaders loi bg) bg) ; stub

(check-expect (render-invaders empty BACKGROUND) BACKGROUND)
(check-expect (render-invaders (list (make-invader 400 270 -3))
                               BACKGROUND)
              (place-image INVADER 400 270 BACKGROUND))
(check-expect (render-invaders (list (make-invader 100 150 7)
                                     (make-invader 350 230 12))
                               BACKGROUND)
              (place-image INVADER 100 150
                           (place-image INVADER 350 230 BACKGROUND)))

(define (render-invaders loi bg)
  (cond [(empty? loi) bg]
        [else
         (place-image INVADER (invader-x (first loi))
                      (invader-y (first loi))
                      (render-invaders (rest loi) bg))]))


; ListOfMissiles Image -> Image
; renders the missiles onto the game
; :::
#;
(define (render-missiles lom bg) bg) ; stub

(check-expect (render-missiles empty BACKGROUND) BACKGROUND)
(check-expect (render-missiles (list (make-missile 300 120))
                               BACKGROUND)
              (place-image MISSILE 300 120 BACKGROUND))
(check-expect (render-missiles (list (make-missile 220 333)
                                     (make-missile 110 230))
                               BACKGROUND)
              (place-image MISSILE 220 333
                           (place-image MISSILE 110 230 BACKGROUND)))

(define (render-missiles lom bg)
  (cond [(empty? lom) bg]
        [else
         (place-image MISSILE (missile-x (first lom))
                      (missile-y (first lom))
                      (render-missiles (rest lom) bg))]))


; Tank Image -> Image
; renders the tank onto the game
; :::
#;
(define (render-tank t bg) bg) ; stub

(check-expect (render-tank (make-tank 100 2) BACKGROUND)
  (place-image TANK 100 (- HEIGHT TANK-HEIGHT/2) BACKGROUND))
(check-expect (render-tank (make-tank 150 2) BACKGROUND)
  (place-image TANK 150 (- HEIGHT TANK-HEIGHT/2) BACKGROUND))

(define (render-tank t bg)
  (place-image TANK (tank-x t) (- HEIGHT TANK-HEIGHT/2) bg))


; Game KeyEvent -> Game
; takes input from keyboard and updates game off it
; :::
#;
(define (input-game g ke) g) ; stub

(check-expect (input-game (make-game empty
                                     (list (make-missile 120 150))
                                     (make-tank 100 -1))
                          " ")
              (make-game empty
                         (list (make-missile 100 (- HEIGHT TANK-HEIGHT/2))
                               (make-missile 120 150))
                         (make-tank 100 -1)))
(check-expect (input-game (make-game empty
                                     (list (make-missile 120 150))
                                     (make-tank 100 -1))
                          "left")
              (make-game empty
                         (list (make-missile 120 150))
                         (make-tank 100 -1)))
(check-expect (input-game (make-game empty
                                     (list (make-missile 120 150))
                                     (make-tank 100 1))
                          "left")
              (make-game empty
                         (list (make-missile 120 150))
                         (make-tank 100 -1)))
(check-expect (input-game (make-game empty
                                     (list (make-missile 120 150))
                                     (make-tank 100 1))
                          "right")
              (make-game empty
                         (list (make-missile 120 150))
                         (make-tank 100 1)))
(check-expect (input-game (make-game empty
                                     (list (make-missile 120 150))
                                     (make-tank 100 -1))
                          "right")
              (make-game empty
                         (list (make-missile 120 150))
                         (make-tank 100 1)))
(check-expect (input-game (make-game empty
                                     (list (make-missile 120 150))
                                     (make-tank 100 1))
                          "a")
              (make-game empty
                         (list (make-missile 120 150))
                         (make-tank 100 1)))

(define (input-game g ke)
  (cond [(string=? ke " ")
         (make-game (game-invaders g)
                    (cons (make-missile (tank-x (game-tank g))
                                        (- HEIGHT TANK-HEIGHT/2))
                          (game-missiles g))
                    (game-tank g))]
        [(string=? ke "left")
         (make-game (game-invaders g)
                    (game-missiles g)
                    (make-tank (tank-x (game-tank g))
                               -1))]
        [(string=? ke "right")
         (make-game (game-invaders g)
                    (game-missiles g)
                    (make-tank (tank-x (game-tank g))
                               1))]
        [else g]))


(main (make-game (list (make-invader 100 120 12)
                       (make-invader 260 135 6)
                       (make-invader 150 400 -12)
                       (make-invader 30 175 -10))
                 (list (make-missile 200 100)
                       (make-missile 200 60)
                       (make-missile 60 400))
                 (make-tank 50 1)))