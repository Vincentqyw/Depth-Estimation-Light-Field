%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2015.05.12 Hae-Gon Jeon
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% CVPR 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function GraphCuts

% input : cost volume
% output : disparity label (int32)

function Refined_Disp = GraphCuts(dispVol_1, im_cen, param)

fprintf('GraphCuts...');

addpath(genpath('gco-v3.0'))

disp=dispVol_1;
[height, width, num_labels] = size(disp);

im = im2double(im_cen);
[row, col, ch] = size(im);

Data = reshape(disp,[],num_labels)';
numQuantiz =3*num_labels;

QQ = ( Quantiz(Data(:) , linspace(min(Data(:)),max(Data(:)),numQuantiz)) ) ;
Data_idx = reshape(QQ,size(Data));
idx = reshape(1:numel(im),row,col,ch);
idx0 = idx(1:end-1,1:end-1,:);
idx1 = idx(2:end  ,1:end-1,:);
idx2 = idx(1:end-1,2:end,:);

whc = sqrt(sum((im(idx0) - im(idx1)).^2,3));
wvc = sqrt(sum((im(idx0) - im(idx2)).^2,3));

% Intensity discontinuity
Qwhc = ( Quantiz(whc(:), linspace(0,max(whc(:)),numQuantiz)));
Qwhc = max(Qwhc(:)) - Qwhc;
Qwvc = ( Quantiz(wvc(:), linspace(0,max(wvc(:)),numQuantiz)));
Qwvc = max(Qwvc(:)) - Qwvc;

Neigh = sparse([idx0(:,:,1),idx0(:,:,1),idx1(:,:,1),idx2(:,:,1)],[idx1(:,:,1),idx2(:,:,1),idx0(:,:,1),idx0(:,:,1)], [Qwhc, Qwvc,Qwhc, Qwvc], row*col,row*col);

% Graph Cut Parameter
param_data = param.data; % Data term 3
param_smooth = param.smooth; % Smoothness term 10
param_neigh = param.neigh; % Weight for Neighbol pixels 0.015
h = GCO_Create(height*width, num_labels);
GCO_SetDataCost(h,int32(param_data*Data_idx));
Smoothness = min(triu(gallery('circul', [0:num_labels-1]'),0)+triu(gallery('circul', [0:num_labels-1]'),0)',10);

GCO_SetSmoothCost(h,int32(param_smooth*Smoothness));

GCO_SetNeighbors(h,param_neigh*Neigh);
Sum = GCO_Expansion(h,10);
Label = GCO_GetLabeling(h);
[E, D, S] = GCO_ComputeEnergy(h);
GCO_Delete(h);

Refined_Disp = reshape(Label,[height width]);

fprintf('done.\n');