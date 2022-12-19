function cost_out = fn_WMF4IterRefine(cost, imgGuide, vecDisps, r, epsilon)
%weighted_median_filter - Weighted median filter with guided filter weights
%
%   dispOut  = weighted_median_filter(dispIn, imgGuide, vecDisps, r, epsilon)
%
% INPUT:
%
%   dispIn   - Input 1-channel discrete disparity map, disparities must
%              come from vecDisps
%   imgGuide - Input guidance image, should be 3-channel RGB
%   vecDisps - Vector of disparities in consideration, must be intergers
%   r        - Local window radius for guided filter weights
%   epsilon  - Regularization parameter for guided filter weights
%

if ~exist('epsilon', 'var')
    epsilon = 0.01;
end

imgGuide = im2double(imgGuide);

cost_out  = zeros( size(cost) );
imgAccum = zeros( size(cost) );

guidedfilter_color_precompute(imgGuide, r, epsilon);

for d = 1 : numel(vecDisps)
    fprintf('%d of %d\n', d, numel(vecDisps));
    
    % note: this code differs from original code (modified by Jaesik Park)
    
    % apply guided filter to each slice
    costslice = cost(:,:,d);
    cost_out(:,:,d) = guidedfilter_color_runfilter(costslice);    
    
end



