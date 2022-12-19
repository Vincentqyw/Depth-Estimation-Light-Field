%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jinsun Park (zzangjinsun@gmail.com / zzangjinsun@kaist.ac.kr)
% Computer Vision and Image Processing Lab, KAIST, KOREA
%
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% Hae-Gon Jeon, Jaesik Park, Gyeongmin Choe, Jinsun Park, Yunsu Bok, Yu-Wing Tai and In So Kweon
% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), Jun 2015
%
% Name   : EPIShearingPixel
% Input  : EPI    - epipolar image
%          OFFSET - shearing offset
%          N      - point of fft
% Output : RESULT - corrected epi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RESULT = EPIShearingPixel(EPI, OFFSET, N)
% Get the size of image
[R, C, CH] = size(EPI);

ref = round(R/2);

RESULT = zeros(R,C,CH);

rows = [1:ref-1,ref+1:R];

OMEGA = 2*pi/N;

FT = zeros(R,N,CH);

for k=1:R-1
    FT(rows(k),:) = fft(EPI(rows(k),:),N);
end 

for c=1:C
    for k=1:R-1
        for ch=1:CH
            COEF = [0:N/2, (-N/2+1):-1];
            COEF = exp(-sqrt(-1)*OMEGA*COEF*OFFSET(c)*(rows(k)-ref));
            
            FT_temp = FT(rows(k),:).*COEF;
            
            TEMP = ifft(FT_temp,N);
            
            RESULT(rows(k),c,ch) = real(TEMP(c));
        end
    end
end

RESULT(ref,:,:) = EPI(ref,:,:);

return;