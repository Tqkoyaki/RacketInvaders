;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
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
; called to make the game program; start with (main START-GAME)

; To start with game with
(define START-GAME (make-game empty empty (make-tank (/ WIDTH 2) 0)))

(define (main g)
  (big-bang g
    (on-tick update-game) ; Game -> Game
    (to-draw render-game) ; Game -> Image
    (on-key input-game))) ; Game KeyEvent -> Game


; Game -> Game
; updates game by advancing invaders, missles, and tank
#;
(define (update-game g) g) ; stub


(check-expect (update-game G0) (collision (advance-game G0)))
(check-expect (update-game G1) (collision (advance-game G1)))
(check-expect (update-game G2) (collision (advance-game G2)))
(check-expect (update-game G3) (collision (advance-game G3)))

(define (update-game g)
  (advance-game (collision g)))


; Game -> Game
; moves all the missles and invaders
#;
(define (advance-game g) g) ; stub

(check-expect (advance-game G0) (make-game (advance-invaders (game-invaders G0))
                                           (advance-missiles (game-missiles G0))
                                           (game-tank G0)))
(check-expect (advance-game G1) (make-game (advance-invaders (game-invaders G1))
                                           (advance-missiles (game-missiles G1))
                                           (game-tank G1)))
(check-expect (advance-game G2) (make-game (advance-invaders (game-invaders G2))
                                           (advance-missiles (game-missiles G2))
                                           (game-tank G2)))
(check-expect (advance-game G3) (make-game (advance-invaders (game-invaders G3))
                                           (advance-missiles (game-missiles G3))
                                           (game-tank G3)))

(define (advance-game g)
  (make-game (advance-invaders (game-invaders g))
             (advance-missiles (game-missiles g))
             (game-tank g)))


; ListOfMissiles -> ListOfMissiles
; updates all the missles
#;
(define (advance-missiles lom) lom) ; stub

(check-expect (advance-missiles (game-missiles G0)) (move-missiles (clean-missiles (game-missiles G0))))
(check-expect (advance-missiles (game-missiles G1)) (move-missiles (clean-missiles (game-missiles G1))))
(check-expect (advance-missiles (game-missiles G2)) (move-missiles (clean-missiles (game-missiles G2))))
(check-expect (advance-missiles (game-missiles G3)) (move-missiles (clean-missiles (game-missiles G3))))
(check-expect (advance-missiles (list (make-missile 100 (+ HEIGHT 10))
                                      (make-missile 100 (/ HEIGHT 2))))
              (list (make-missile 100 (+ (/ HEIGHT 2) MISSILE-SPEED))))

(define (advance-missiles lom)
  (move-missiles (clean-missiles lom)))


; ListOfMissles -> ListOfMissles
; moves all the missles
#;
(define (move-missiles lom) lom)

(check-expect (move-missiles (game-missiles G0)) (game-missiles G0))
(check-expect (move-missiles (game-missiles G1)) (game-missiles G1))
(check-expect (move-missiles (game-missiles G2)) (list (make-missile 150 (+ 300 MISSILE-SPEED))))
(check-expect (move-missiles (game-missiles G3)) (list (make-missile 150 (+ 300 MISSILE-SPEED))
                                                    (make-missile (invader-x I1) (+ (invader-y I1) 10 MISSILE-SPEED))))

(define (move-missiles lom)
  (cond [(empty? lom) empty]
        [else
         (cons (make-missile (missile-x (first lom))
                             (+ (missile-y (first lom))
                                MISSILE-SPEED))
              (move-missiles (rest lom)))]))


; ListOfMissles -> ListOfMissles
; removes all missles that are past the screen
#;
(define (clean-missiles lom) lom)

(check-expect (clean-missiles empty) empty)
(check-expect (clean-missiles (list (make-missile 150 (/ HEIGHT 2)))) (list (make-missile 150 (/ HEIGHT 2))))
(check-expect (clean-missiles (list (make-missile 250 (+ HEIGHT 25)))) empty)
(check-expect (clean-missiles (list (make-missile 150 (/ HEIGHT 3)) (make-missile 50 (+ HEIGHT 5)))) (list (make-missile 150 (/ HEIGHT 3))))

(define (clean-missiles lom)
  (cond [(empty? lom) empty]
        [else
         (if (> HEIGHT (missile-y (first lom)))
             (cons (first lom) (clean-missiles (rest lom)))
             (clean-missiles (rest lom)))]))


; ListOfInvaders -> ListOfInvaders
; updates all the invaders
(define (advance-invaders loi) loi) ; stub

(check-expect (advance-invaders (game-invaders G0)) (spawn-invaders (move-invaders (game-invaders G0))))
(check-expect (advance-invaders (game-invaders G1)) (spawn-invaders (move-invaders (game-invaders G1))))
(check-expect (advance-invaders (game-invaders G2)) (spawn-invaders (move-invaders (game-invaders G2))))
(check-expect (advance-invaders (game-invaders G3)) (spawn-invaders (move-invaders (game-invaders G3))))


; ListOfInvaders -> ListOfInvaders
; moves all the invaders already on the screen
(define (move-invaders loi) loi) ; stub


; ListOfInvaders -> ListOfInvaders
; spawns new invaders onto the top of the screen
(define (spawn-invaders loi) loi) ; stub


; Game -> Game
; updates list of invaders and missles based on if they collided
(define (collision g) g) ; stub


; Game -> Image
; renders the game's invaders, missles, and tank
(define (render-game g) g) ; stub


; Game KeyEvent -> Game
; takes user input to manipulate the tank
(define (input-game g ke) g) ; stub