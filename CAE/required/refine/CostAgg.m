%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C Rhemann et al.,
% Fast cost-volume filtering for visual correspondence and beyond
% CVPR 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% note : This code is slightly modified by Hae-Gon Jeon

function dispVol1=CostAgg(E1,Ic,param)

r = param.r;               
eps = param.eps;           
numLabel = size(E1,3);
im_cen = Ic;

E1_cell = squeeze(num2cell(E1,[1 2]));
dispVol1_cell = cell(1,1,numLabel);

parfor d=1:numLabel % use regular for loop when not using the parallel computing toolbox
    p1 = E1_cell{d};
    q1 = guidedfilter_color(im_cen, p1, r, eps);
    dispVol1_cell{d} = q1;
    fprintf('CostAgg.. cost slice %d.\n',d);
end
delete (gcp);
% parpool close;
dispVol1=cell2mat(dispVol1_cell);