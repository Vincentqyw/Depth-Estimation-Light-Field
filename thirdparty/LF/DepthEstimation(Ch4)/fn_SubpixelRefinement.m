%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2010.06.14 Jaesik Park
% implementation of Spatial-Depth Super Resolution for Range Images
% CVPR 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function fn_SubpixelRefinement

% goal : To reduce the discontinnuities caused by the quantization in the
% depth hypothesis selecetion process
% input : depth hypothesis and cost volume
% output : refined depth (integer)

function depth = fn_SubpixelRefinement(depth_h, cost, disps)

height = size(cost,1);
width = size(cost,2);
level_num = size(cost,3);

ndisp = numel(disps);

depth = zeros(height,width);


idmap = fn_Disp2Idx(depth_h, disps);

for iter=2:ndisp-1
    
    costslice_m = cost(:,:,iter-1);
    costslice_c = cost(:,:,iter);
    costslice_p = cost(:,:,iter+1);
    
    vid = find(idmap == iter);
    
    f_dm = costslice_m(vid);
    f_dc = costslice_c(vid);
    f_dp = costslice_p(vid);
    
    depth_sub = disps(iter) - (f_dp-f_dm)./(2*(f_dp+f_dm)-2.*f_dc);
    
    depth(vid) = depth_sub;
end
