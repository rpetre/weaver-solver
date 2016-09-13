Weaver game solver in Prolog
============================

Weaver is an Android (and probably iOS, too) puzzle game that requires choosing how to twist a mesh
of coloured ribbons to match the required output colours.

After a couple of nights of struggling to come up with optimal solutions I decided it's the perfect use case to
finally learn Prolog so this is what I came up with. It's been hacked together after only a day of reading manuals
and inspired by various Sudoku and Nonograms solvers I found. The method is probably inefficient and the style is
definitely horrifying, sorry ;-)

This is known to run on SWI-Prolog (makes some use of nth0 and a couple of other list functions that weren't in GNU prolog).

The required conventions are as follows:
 - rotate the puzzle 45 degrees counter-clockwise (so the ribbons come from top and left and go to bottom and right)
 - the input conditions are [InTop,InLeft], where InTop is an array of the incoming vertical ribbons from left to right and
   InLeft is the aray of the incoming horizontal ribbons from top to bottom)
 - the output conditions are [OutBot,OutRight], similar to the input: first the outgoing vertical colours, then the outgoing
   horizontal colours

To run the solver, start swipl in the program directory, run `[game].` to load game.pl and query the game predicate in the 
with the input and output conditions plus the maximumi number of flips you want (the stars are awarded based on the number of twists).

For instance, level 1.3 would be `game([[red,red],[red,green]],[[red,green],[red,red]],1).` (The name of the colours doesn't matter as long as they're consistent).


Todo
====

 - come up with a representation of output conditions that can take alternatives


Play store link: https://play.google.com/store/apps/details?id=net.pyrosphere.weaver&hl=en
