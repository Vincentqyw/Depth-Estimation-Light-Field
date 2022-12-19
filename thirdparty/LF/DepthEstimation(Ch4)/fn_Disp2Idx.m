
function idmap = fn_Disp2Idx(dmap, disps)

ndisp = numel(disps);

h = size(dmap,1);
w = size(dmap,2);
idmap = zeros(h,w);

for iter = 1:ndisp
    idmap(dmap == disps(iter)) = iter;
end