%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jinsun Park (zzangjinsun@gmail.com / zzangjinsun@kaist.ac.kr)
% Computer Vision and Image Processing Lab, KAIST, KOREA
%
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% Hae-Gon Jeon, Jaesik Park, Gyeongmin Choe, Jinsun Park, Yunsu Bok, Yu-Wing Tai and In So Kweon
% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), Jun 2015
%
% Name   : Make4DLF
% Input  : filepath - image file path
%          ext      - extension of image file (e.g. 'png')
% Output : LF       - light field image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LF = Make4DLF(filepath, ext)
% Get image list
list = dir(fullfile([filepath,'\*.',ext]));

N = sqrt(size(list,1));

[R, C, CH] = size(imread([filepath,'\',list(1).name]));

LF = zeros(N,N,R,C,CH);

for i=1:N
    for j=1:N
        n = sub2ind([N,N],j,i);
        
        filename = [filepath, '\', list(n).name];
        
        I_temp = imread(filename);
        
        I_temp = double(I_temp);
        
        LF(i,j,:,:,:) = I_temp;
    end
end

return;