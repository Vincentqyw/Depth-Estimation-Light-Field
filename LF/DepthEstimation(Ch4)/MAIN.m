clear all;
clc;
close all;

%% Loading dataset. 
% We recommend using sub-aperture images from geometric
% calibration toolbox (Bok et al., ECCV 14.)
% The toolbox generates more geometrically correct sub-aperture images than
% other toolboxes.
load('dataset\flowers\LF'); % input - 5-dimension (t,s,y,x,ch), single type pixel intensities [0,1].
fn_ViewLightField(LF);%显示49个视角的图像


%% Cost volume construnction using phase shift in Sec 4.2

param.windowsize = [1 1];
param.label = 100;   % number of labels
param.delta = 0.02; % pixel shift unit
param.alpha = 0.5;  % In Eq 5
param.tau1 = 0.5;   % In Eq 6
param.tau2 = 0.5;   % In Eq 8
Sc = [4,4];         % s-t coordinate of reference view
datatype = 2;       % 0: Synthetic Data, 1:Lytro data with long range, 2:Lytro data with short range.
tic;
E1 = CostVolume(LF,Sc,param,datatype);
toc;


%% Cost aggregation in Sec 4.2

Ic = im2double(squeeze(LF(Sc(1),Sc(2),:,:,1:3))); % Guided image 
param.r = 5;
param.eps = 0.0001;
tic;
E2 = CostAgg(E1,Ic,param);
toc;


%% Multi-label optimization via Graph-cuts in Sec 4.3

% If there are large holes in the disparity map,
% we recommend using Graph-cuts.
param.data = 2;
param.smooth = 1;
param.neigh = 0.009;
E3 = GraphCuts(E2, Ic, param);
figure; imagesc(E3); axis equal; colorbar;

% If the disparity map is noisy,
% we recommend using weighted median filter.
tic;
E3 = WMT(double(E3) , Ic);
toc;
figure; imagesc(E3); axis equal; colorbar;


%% Iterative refinement for continuous disparity map in Sec 4.3
param.iternum = 4;
tic;
E4 = IterRefine(E3,Ic,param);
toc;
figure; imagesc(E4); axis equal; colorbar;

