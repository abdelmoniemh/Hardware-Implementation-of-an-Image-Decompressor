### Take-home exercise

Modify **experiment 5** to support the following behaviour on the green LEDs.

- green LED 8 is lightened only if at least one of the switches 14 down to 10 is high;
- green LED 7 is lightened only if all of the switches 14 down to 10 are high;
- green LED 6 is lightened only if the number of switches from 14 down to 10 that are high is an odd number;
- green LED 5 is lightened only if at most one of the switches 9 down to 5 is low;
- green LED 4 is lightened only if none of the switches 9 down to 5 is low;
- green LED 3 is lightened only if the number of switches from 9 down to 5 that are high is an even number;
- green LED 2 is lightened only if at least four of the switches 4 down to 0 are low;
- green LED 1 is lightened only if all of the switches 4 down to 0 are low;
- green LED 0 is lightened only if the number of switches from 4 down to 0 that are high is greater than the number of switches from 4 down to 0 that are low.

The two rightmost 7-segment displays show the content of a 2-digit binary coded decimal (BCD) counter that counts *up* from 00 to 99 or it counts *down* from 99 to 00 in two different modes of operation: **wraparound** and **rebound**, as detailed below.

- the meaning of push-buttons 0, 1 and 2 from the in-lab contribution to **experiment 5** are the same; you will need to add the functionality for push-button 3, as described next;

- when push-button 3 has been pressed the counter’s mode of operation will change from **wraparound** to **rebound**, or vice versa; in the **wraparound** mode, 99 is followed by 00 while counting *up*; likewise, 00 is followed by 99 while counting *down* in the **wraparound** mode; 
- in the **rebound** mode, when 99 has been reached while counting *up*, the count direction will change from *up* to *down* and the next state will be 98 (the counter will continue in the *down* direction); likewise, in the **rebound** mode, when 00 has been reached while counting *down*, the count direction will change from *down* to *up* (the next state will be 01);

- the activity on any of the four push-buttons is ignored when the counter is in either state 00 or state 99; note, it is also assumed that after any push-button has been pressed, no other push-button activity will occur within one second;- if push-button 3 is pressed multiple times while the counter is stopped (as controlled by push-button 0) then, each time it is pressed, push-button 3 will produce a change of mode from **wraparound** to **rebound**, or vice versa; 
- on power-up assume the counter is active in state 00, and the counting direction is *up* in the **wraparound** mode.

Submit your sources and in your report write approx half-a-page (but not more than a full-page) that describes your reasoning. Your sources should follow the directory structure from the in-lab experiments (already set-up for you in the `exercise` folder); note, your report (in `.pdf`, `.txt` or `.md` format) should be included in the `exercise/doc` sub-folder.

Your submission is due 16 hours before your next lab session. Late submissions will be penalized.
