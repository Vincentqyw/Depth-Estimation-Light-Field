%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2010.06.14 Jaesik Park
% implementation of Spatial-Depth Super Resolution for Range Images
% CVPR 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function IterRefine

% input : a depth map (double) and a color image
% output : a disparity map with sub-pixel precision

function dmap_r = IterRefine(dispMapOutput1,img,param)

dmap_i = double(dispMapOutput1);
mindisp = 1;
maxdisp = max(dmap_i(:));
step = 1;

img = im2double(img);

disps = mindisp:step:maxdisp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% iterative refinement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cost = fn_MakeCostVolume(dmap_i, disps);

eps = 0.01^2;
r = ceil(max(size(img, 1), size(img, 2)) / 100);
iternum = param.iternum; % parameter #5

for iter=1:iternum    
    disp(['IterRefine : (' num2str(iter) '/' num2str(iternum) ')']);
    cost = fn_WMF4IterRefine(cost, img, disps, r, eps);
    dmap_h = fn_SelectMinimumCost(cost, disps);
    dmap_r = fn_SubpixelRefinement(dmap_h, cost, disps);
    cost = fn_MakeCostVolume(dmap_r, disps);        
end