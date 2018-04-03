
function [dmap,minmap] = fn_SelectMinimumCost(cost, disps)

h = size(cost,1);
w = size(cost,2);
nstep = numel(disps);

% cost aggregation
dmap = zeros(h,w);
minmap = ones(h,w)*100;
for iter = 1:nstep
    costslice = cost(:,:,iter);
    minid = find(minmap > costslice);
    minmap(minid) = costslice(minid);
    dmap(minid) = disps(iter);    
end
