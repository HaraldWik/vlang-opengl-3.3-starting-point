**About**

This repo is here for those who want to learn OpenGL 3.3 with V
you can use this as a starting point, its not a good one but its better than doing it from scratch I'd know.

**File Info**

main.c <-- The same project but C
main.v <-- Uses my custom bind
main-with-bind.v <-- Uses the raw C imports

**C**

To compile the C project use this : clang -o my_program main.c -I/usr/include/SDL2 -lSDL2 -lGL -lGLEW -lm

The C project is the only one that acctualy works :/

**Compilation**

The C project is compiled using clang but I persume that gcc works fine too

**Note**

The glShaderSource function is cursed :|
And the gl folder is the custom binding, feel free to use it!

**To People with OpenGL knowledge**

Please open an issue or discussion, so this can repo can be as good as possible,
since I'm not very good with OpenGl all help is good!
