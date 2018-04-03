clear all;
clc;
close all;

addpath(genpath('guidedfilter'));
addpath(genpath('preprocess'));


%% number of bins in the histogram

NumberOfBins = 64;                  % for traditional images
% NumberOfBins = 32;                % for Lytro images
% NumberOfBins = 8 ;                % for nosiy images
% NumberOfBins = 128;               % for low-texture images

%% input and output path
input_path  = 'input/Buddha/';
output_path = 'output/'; 
mkdir(output_path);

%% depth estimation
SPO(input_path, output_path, NumberOfBins);
