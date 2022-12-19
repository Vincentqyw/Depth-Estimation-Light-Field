clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jinsun Park (zzangjinsun@gmail.com / zzangjinsun@kaist.ac.kr)
% Computer Vision and Image Processing Lab, KAIST, KOREA
%
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% Hae-Gon Jeon, Jaesik Park, Gyeongmin Choe, Jinsun Park, Yunsu Bok, Yu-Wing Tai and In So Kweon
% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), Jun 2015
%
% This script compensates for depth distortion by EPI shearing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('subfunctions');

% Image path
PATH_IMAGE = 'image\checker_15cm';
       
DATA = 'data\checker_15cm.mat';

load(DATA);

% Light field property
offset = 3;
ref = offset+1;
N = 2*offset+1;

N_FFT = 2^10;

DISP = 1;

tic

% Load images
LF = Make4DLF(PATH_IMAGE, 'png');

[M, N, R, C, CH] = size(LF);

LF_bent = ShearingCompensation(LF, D_R, D_C, N_FFT, DISP);

mkdir([PATH_IMAGE,'\compensated\']);

for i=1:M
    for j=1:N
        I = squeeze(LF_bent(i,j,:,:,:));

        I = uint8(I);

        imwrite(I,[PATH_IMAGE,'\compensated\view_',num2str(i),'_',num2str(j),'.png'],'png');
    end
end

toc