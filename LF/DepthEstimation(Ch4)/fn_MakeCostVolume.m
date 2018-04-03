%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2010.06.14 Jaesik Park
% implementation of Spatial-Depth Super Resolution for Range Images
% CVPR 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function fn_MakeCostVolume

% input : depth map (double)
% output : cost volume (double)

function costvol = fn_MakeCostVolume(depth, levels)

% parameters;
L = 5;   % search range
eta = 1; % constant
nlevel = numel(levels);

[height width] = size(depth);
costvol = zeros(height, width, nlevel);

for iter = 1:nlevel
    cur_level = levels(iter);
    costvol(:,:,iter) = min(eta*L,(cur_level-depth(:,:)).^2);
end

