This code is a Matlab implementation of the tracking algorithm based on Boosted Color
Soft Segmentation and ICA-R described in
     Fan Yang, Huchuan Lu and Yen-Wei Chen, Robust Tracking Based on Boosted Color 
     Soft Segmentation and ICA-R£¬International Conference on Image Processing (ICIP), 
     Hong Kong, 2010.

All important functions are commented. For details, please refer to the explanatory 
notes of respective .m files. 

The main function is tracking.m. Run it to see how tracking proceeds. The tracking 
results are saved in individual folders in the subdirectory ./result/ as .jpg format.
The affine parameters of the tracked object are also saved in ./result folder in a
.mat file with the same name as the sequence. 

Images of sequences are in the subdirectory ./data/. We provide three public sequence. 
You can change initial parameters to run other sequences. Also, you can add your own 
testing sequences by specifying necessary parameters.

This code is the preliminary version. We appreciate any comments/suggestions. 
Questions regarding the code can be directed to Fan Yang (fyang.dut@gmail.com).

Fan Yang and Huchuan Lu, 
IIAU-Lab, Dalian University of Technology, China,
Dec. 2010
