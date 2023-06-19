# Racket Invaders

This is the final project for [How to Code: Simple Data](https://learning.edx.org/course/course-v1:UBCx+HtC1x+2T2017/home) avaliable on Edx. The goal of the project is to recreate the Space Invaders game released in 1978. The racket file has been compiled to an executable (exe) file and is playable on windows.

## Problem:
Space Invaders game should have the following behaviour:

1. The tank should move right and left at the bottom of the screen when you press the arrow keys. If you press the left arrow key, it will continue to move left at a constant speed until you press the right arrow key.
2. The tank should fire missiles straight up from its current position when you press the space bar.
3. The invaders should appear randomly along the top of the screen and move at a 45 degree angle. When they hit a wall they will bounce off and continue at a 45 degree angle in the other direction.
4. When an invader reaches the bottom of the screen, the game is over. 


## Domain Analysis
Domain analysis is an analysis of the problem in order to identify the key factors of the program.

### Sketch:
![Sketch of Space Invaders](res\img\sketch.png)

### Constant Information:
1. Width and Height of Screen
2. X and Y Speed of Invaders
3. Tank Speed
4. Missle Speed
5. Hit Range
6. Rate of Invader Spawning
7. Background
8. Image of Invaders
9. Image of Tank
10. Image of Missles

### Changing Information:
1. List of Missles
2. List of Invaders
3. X of Tank
4. Y of Missles
5. X and Y of Invaders

### Big-Bang Options:
1. on-tick
2. on-draw
3. on-key