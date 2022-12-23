### Exercise 1

Modify the design from __experiment 3__ as follows. 

In the first and the second DP-RAMs there are two different arrays (called W and X respectively) of 8-bit numbers, interpreted as signed integers. Each of these two arrays has 512 elements (initialized the same way as in the lab, i.e., using memory initialization files). Design the circuit that computes two arrays Y and Z defined as follows (for every _k_ from 0 to 511).

Y[_k_] = W[_k_] - X[_k_], if W[_k_] and X[_k_] are both positive (note, value zero is considered positive) or both negative; otherwise Y[_k_] = W[_k_] + X[_k_];

Z[_k_] = |W[_k_]| - |X[_k_]|, if _k_ is smaller than 256 then (where |A| is the absolute value of element A); otherwise Z[_k_] = (|W[_k_]| + |X[_k_]|)/2.

Each element Y[_k_] should overwrite the corresponding element W[_k_] in the first DP-RAM (for every _k_ from 0 to 511); likewise, each Z[_k_] should overwrite the X[_k_] in location _k_ in the second DP-RAM. If implemented correctly no overflow should occur on any of the elements from Y[_k_] and Z[_k_]. The above calculations should be implemented in as few clock cycles as it can be facilitated by the two DP-RAMs. It is important to note that a simplifying assumption for this problem is that all the elements from the W and X arrays are in the range -127 to +127.

For this exercise only, in your report you __MUST__ discuss your resource usage in terms of registers. You should relate your estimate to the register count from the compilation report in Quartus. You should also inspect the critical path either in the Timing Analyzer menu, as shown in the videos on circuit implementation and timing from **lab** 3, or by inspecting the `.sta.rpt` file from the `syn/output_files` sub-folder, which contains the same info as displayed in the Timing Analyzer menu. Based on your specific design structure you should provide your interpretation for the critical path in your design. Finally, you should also provide your most reasonable explanation for the total number of logic elements reported by Quartus, nonetheless it is important to emphasize that you will not be explicitly assessed for this last explanation.

Submit your sources and in your report write approx half-a-page (but not more than full-page) that describes your reasoning. Your sources should follow the directory structure from the in-lab experiments (already set-up for you in the `exercise1` folder); note, your report (in `.pdf`, `.txt` or `.md` format) should be included in the `exercise1/doc` sub-folder. 

Your submission is due 16 hours before your next lab session. Late submissions will be penalized.
