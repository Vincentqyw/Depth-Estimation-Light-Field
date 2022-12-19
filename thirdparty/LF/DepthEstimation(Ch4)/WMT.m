%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z Ma et al.,
% Constant Time Weighted Median Filtering for Stereo Matching and Beyond
% ICCV 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dispMapOutput1 = WMT(Refined_Disp , im_cen)

imgGuide = im_cen;
dispMapInput  = round(Refined_Disp);
eps = 0.01^2;
r = ceil(max(size(imgGuide, 1), size(imgGuide, 2)) / 40);
dispMapOutput = weighted_median_filter(dispMapInput, imgGuide,1:max(dispMapInput(:)), r, eps);
dispMapOutput1 = medfilt2(dispMapOutput,[3,3]);
disp_scale = 1;