############################################################################
#  This file our depth estimation results of the 4D Light Field Benchmark. 
#                                                                          
#  Authors: Shuo Zhang                                                     
#  Contact: shuo.zhang@buaa.edu.cn        
#  
#  The results were calculated using the proposed Spinning Parallelogram 
#  Operator (SPO) at Beihang University. If you use any part of the results,
#  please cite:	
#     
#  @article{Zhang2016Robust,
#    title={Robust depth estimation for light field via spinning parallelogram 
#  		  operator},
#    author={Zhang, Shuo and Sheng, Hao and Li, Chao and Zhang, Jun and Xiong, 
#  		  Zhang},
#    journal={Computer Vision and Image Understanding},
#    volume={145},
#    pages={148-159},
#    year={2016},
#    }
#
#  The 4D Light Field Benchmark was created by the University of Konstanz  
#  and the HCI at Heidelberg University. If you use any part of the        
#  benchmark, please cite:												   
#                                                                          
#  @inproceedings{honauer2016benchmark,                                    
#    title={A dataset and evaluation methodology for depth estimation on   
#           4D light fields},                                              
#    author={Honauer, Katrin and Johannsen, Ole and Kondermann, Daniel     
#            and Goldluecke, Bastian},                                     
#    booktitle={Asian Conference on Computer Vision},                      
#    year={2016},                                                          
#    organization={Springer}                                               
#    }       
#                                                                  
############################################################################

INTRODUCTION
============

The depth maps are calculated using the proposed Spinning Parallelogram 
Operator (SPO), where the related parameters are:

--Uploaded Version:

number of bins = 64
alpha = 0.8, in Eq (3)
sigma = 0.26, in Eq (6)   

--Specific Parameters:

number of bins = 8 for 'Dots'
number of bins = 32 for 'stripes'
number of bins = 128 for 'stripes'
