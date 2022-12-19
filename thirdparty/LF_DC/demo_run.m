% This gives a demo run of compute_LFdepth
clear all;


% two files that need to be mex
cd('required/mex');
mex required/mex/FAST_STDFILT_mex.c
mex required/mex/REMAP2REFOCUS_mex.c
cd('..');
cd('..');
% file path
file_path     =  'input/dataset/IMG_1.jpg'                                ;
% the main function
depth_output  = compute_LFdepth(file_path)                                ;