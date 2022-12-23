### Exercise

After the changes to __experiment 4__ have been applied, provide support for the following spec. 

Only PS/2 keys 0, 1, 2, 3, 4 and 5 must be monitored; consequently, if a PS/2 key that is not listed above has been pressed, you should take no action. Your design must identify the monitored keys (i.e., keys 0 to 5) that have been pressed __most__ times and __second most__ times and display two messages, as clarified through the examples given below. The location of the messages on the screen does not matter so long as they are visible and the message for the key pressed __most__ times is above the message for the key pressed __second most__ times. It is _critical_ to note that in the case that two or more keys have been pressed an equal number of times, the key associated with the larger digit takes precedence. 

_Example 1_ - Assume key 0 has been pressed 8 times, key 1 has been pressed 8 times, key 2 has been pressed 7 times, key 3 has been pressed 9 times, key 4 has been pressed 8 times and key 5 has been pressed 7 times. Then the two messages are:

`KEY 3 PRESSED  9 TIMES`

`KEY 4 PRESSED  8 TIMES`

Note, in this example keys 0, 1 and 4 are tied in the number of times they have been pressed, hence key 4 takes precedence because it is associated with a larger digit when compared to keys 0 and 1.

_Example 2_ - If in the state from _example 1_, key 0 is pressed next then the two messages become:

`KEY 3 PRESSED  9 TIMES`

`KEY 0 PRESSED  9 TIMES`

_Example 3_ - If in the state from _example 2_, key 0 is pressed next then the two messages become:

`KEY 0 PRESSED 10 TIMES`

`KEY 3 PRESSED  9 TIMES`

Take note, as you can see from this example, in case a key has been pressed more than 9 times, then the value associated with the number of times it has been pressed should be displayed in two-digit binary-coded decimal (BCD) format (assume that no key will be pressed more than 20 times). Note also, it is acceptable to display a space instead of a leading zero digit for a two-digit BCD format.

_Example 4_ - On power-up (and before any of the monitored keys have been pressed) the two messages are:

`KEY 5 PRESSED  0 TIMES`

`KEY 4 PRESSED  0 TIMES`

It is important to clarify that the above two messages are consistent with the rule that if two or more keys have been pressed an equal number of times, the key associated with the larger digit takes precedence. 

When testing the design on the board, assume that at most one key is pressed in each frame (one full period of V\_SYNC). In simulation, if you choose to use it while troubleshooting, in order to make it faster, it is recommended that you schedule multiple PS/2 key events in `board_events.txt` before the end of the first vertical blanking period, so only one full frame needs to be simulated to produce a `.ppm` file in the `exercise/data` sub-folder.

In your report you __MUST__ discuss your resource usage in terms of registers. You should relate your estimate to the register count from the compilation report in Quartus.

Submit your sources and in your report write approx half-a-page (but not more than a full-page) that describes your reasoning. Your sources should follow the directory structure from the in-lab experiments (already set-up for you in the `exercise` folder); note, your report (in `.pdf`, `.txt` or `.md` format) should be included in the `exercise/doc` sub-folder.

Your submission is due 16 hours before your next lab session. Late submissions will be penalized.

