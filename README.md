# FP_Batch_Analysis
The following code is intended to be used in the preprocessing of the FP data. Use Choose_Experiment_FP to set up the parameters. It takes animal ID and date to choose experiment from the given spreadsheet. The data window of interest needs to be specified. The first value in data window represents time before trigger and the second value represents the total duration from which the sample will be isolated. The final output provides a cell of batch data with each cell representing individual experiment sessions.
Each cell contains, the raw baseline corrected data, trial ID, and the sorted data matrix based on the triggers in ascending order. For example, FRA analysis contains Sorted data from two different channels, A,C and each cells have the frequency response in increasing order.
