%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2015.05.12 Hae-Gon Jeon
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% CVPR 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function fn_PatchSum

% goal : To reduce noise effect when finding correspondences using sum of absolute differences
% input : color image and user defined window size
% output : sum of color intensity in user defined patch

function I3 = fn_PatchSum(I,WindowSize)

[h,w,ch]=size(I);
I3=zeros(h,w,ch);
for ii = 1:ch
    I2 = imfilter(I(:,:,ii), ones(WindowSize(1),WindowSize(2)) / WindowSize(1)*WindowSize(2), 'replicate');
    I3(:,:,ii)=I2;
end
