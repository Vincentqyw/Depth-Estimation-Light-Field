%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jinsun Park (zzangjinsun@gmail.com / zzangjinsun@kaist.ac.kr)
% Computer Vision and Image Processing Lab, KAIST, KOREA
%
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% Hae-Gon Jeon, Jaesik Park, Gyeongmin Choe, Jinsun Park, Yunsu Bok, Yu-Wing Tai and In So Kweon
% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), Jun 2015
%
% Name   : ShearingSlopeEstimation
% Input  : G        - epi gradient
%          RANGE    - offset range
%          DIVISION - shifting division
%          POINT    - point for FFT
%          MARGIN   - boundary margin pixel
%          TH       - gradient threshold
%          DISP     - display flag
% Output : SLOPE    - slope for each pixel
%          INDEX    - indices for estimated point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SLOPE, INDEX] = ShearingSlopeEstimation(G, RANGE, DIVISION, POINT, MARGIN, TH, DISP)
% Get the size of image
[R, C] = size(G);
ref = round(R/2);

OFFSET = RANGE(1):DIVISION:RANGE(2);
NUM = numel(OFFSET);

STACK = zeros(R,C,NUM);

XX = [0:POINT/2, -POINT/2+1:-1];

OMEGA = 2*pi/POINT;

ROWS = [1:ref-1,ref+1:R];

FT = zeros(R,POINT);

for m=1:numel(ROWS)
    r = ROWS(m);
    FT(r,:) = fft(G(r,:),POINT);
end

if(DISP ~= 0)
    str_length = 0;
end
for k=1:NUM
    if(DISP ~= 0)
        fprintf(1,repmat('\b',1,str_length));
        str_length = fprintf(1,'Shifting : %3.0d / %3.0d',k,NUM);
    end
    
    for m=1:numel(ROWS)
        r = ROWS(m);    
        offset_row = r-ref;
        
        COEF = exp(-sqrt(-1)*OMEGA*XX*OFFSET(k)*offset_row);
    
        FT_SHIFTED = FT(r,:).*COEF;
    
        G_shifted = ifft(FT_SHIFTED,POINT);
        
        G_shifted = G_shifted(1,1:C);
    
        STACK(r,:,k) = real(G_shifted);
    end
end
STACK(ref,:,:) = repmat(G(ref,:),[1,1,NUM]);

if(DISP ~= 0)
    fprintf(1,'\n');
end

STACK = sum(STACK,1);

[~, ind_slope] = max(STACK,[],3);

[~, ind_maxima, ~] = NonMaximaSuppression1D(G(ref,:), TH, 2);

ind_inside = (ind_maxima > MARGIN)&(ind_maxima < (C-MARGIN));
ind_maxima = ind_maxima(ind_inside);

SLOPE = OFFSET(ind_slope(ind_maxima));
INDEX = ind_maxima;

return;



