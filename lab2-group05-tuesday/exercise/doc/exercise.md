

### Exercise



In the reference design from **experiment 5**, only the lower memory half (i.e., address range 000h-0FFh) is used for storing the LCD codes of lower-case characters. First, extend the “MIF” file with the LCD codes such that the upper memory half (i.e., address range 100h-1FFh) stores the LCD codes for upper-case characters. Each letter character displayed on the LCD should be shown in either the _upper-case_ _mode_ or the _lower-case_ _mode_, which are defined as follows. If the position (or index) of the _least_ significant switch that is in the _low_ position from the group of switches 15 down to 0 is an odd number then _mode_ is _upper-case_; otherwise it is _lower-case_ (this includes the scenario when no switches from 15 down to 0 are in the _low_ position). For the sake of simplicity, it is assumed that the _mode_ affects only the letter keys, i.e., ‘a’ to ‘z’; digit keys ('0' to '9') and the space key are not affected by this _mode_. It is fair to assume that for this exercise, no other keys than the types specified above (i.e., 'a' to 'z', '0' to '9' and space) will be typed. It is important to note that the _mode_ can be changed by toggling a switch at a time between the times when any two keys that have been pressed.



As for the in-lab experiment, an entire line is displayed at once after the last (sixteenth) character to be displayed on a line has been typed. 

For the top line, if the sequence of the first eight characters is identical to the sequence of the last eight characters (a **match** status), display letter “d” (for “detected”) on the leftmost 7-segment display until a new key is type. The behavior to be implemented for the bottom line is the same as for the top line, with one exception: letter "d" will be displayed on the leftmost 7-segment display only if the sequence of the first eight characters is a **reverse match** of the sequence of the last eight characters. After a key is pressed again, the behavior resumes as specified above for the top line. Note, at any other times than specified above the leftmost 7-segment display will be lightened off (as if the board is not powered). Note also, what gets displayed on the remaining 7-segment displays is not specified (you can use them to display some debug info, if you deem this to be useful).



Consider the following illustrative examples for clarification purposes:



|  Line  | Printed Characters | Leftmost 7-Segment Display |	 Status       |
|:------:|:------------------:|:--------------------------:|:----------------:|
|   Top  | ‘Ab01C23dAB01c23D’ |              d             |    **match**     |
|   Top  | ‘aB01c23Dab01c230’ |  	  		               |       N/A        |
| Bottom | ‘aB01c23Dd32C10bA’ |  	         d	           | **reverse match**|





As shown above, it is important to emphasize that the _lower-case_/_upper-case_ _mode_ matters only for the letter keys when displaying a character and it does do not matter when the match/reverse match comparisons are done. As a final point, you should also note that while a full line of 16 characters gets sent to the LCD controller, it will take just below 15 microseconds (us) in simulation. Hence, make sure the next key press in `board_events.txt` will be done after these 15 us have elapsed (this concerns simulation only, if you choose to use it).



Submit your sources and in your report write approx half-a-page (but not more than a full-page) that describes your reasoning. Your sources should follow the directory structure from the in-lab experiments (already set-up for you in the `exercise` folder); note, your report (in `.pdf`, `.txt` or `.md` format) should be included in the `exercise/doc` sub-folder.



Your submission is due 16 hours before your next lab session. Late submissions will be penalized.



