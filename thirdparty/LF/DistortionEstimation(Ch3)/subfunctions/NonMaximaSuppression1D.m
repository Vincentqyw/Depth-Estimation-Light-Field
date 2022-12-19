%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jinsun Park (zzangjinsun@gmail.com / zzangjinsun@kaist.ac.kr)
% Computer Vision and Image Processing Lab, KAIST, KOREA
%
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% Hae-Gon Jeon, Jaesik Park, Gyeongmin Choe, Jinsun Park, Yunsu Bok, Yu-Wing Tai and In So Kweon
% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), Jun 2015
%
% Name   : NonMaximaSuppression1D
% Input  : I      - input image
%          th     - threshold value
%          radius - window radius
% Output : S      - suppressed image
%          X      - x indices of maximas
%          Y      - each maxima value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S, X, Y] = NonMaximaSuppression1D(I, th, radius)
% Window size
W = 2*radius+1;

% I is assumed to be a row vector
N = numel(I);

% pad boundary with zeros
I = [zeros(1,radius), I, zeros(1,radius)];

sup1 = I;
sup2 = I;


% Non maxima suppression in both direction
for n=1:N
    ROI1 = sup1(n:n+W-1);
    ROI2 = sup2(N:N+W-1);
    
    max1 = max(ROI1(:));
    max2 = max(ROI2(:));
    
    sup1(n:n+W-1) = ROI1.*(ROI1 == max1);
    sup2(N:N+W-1) = ROI2.*(ROI2 == max2);
end

S = sup1.*(sup1.*sup2 > th^2);
S = S(radius+1:end-radius);

X = find(S);
Y = S(X);