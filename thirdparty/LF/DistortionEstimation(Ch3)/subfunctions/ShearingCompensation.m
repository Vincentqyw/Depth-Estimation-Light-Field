%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jinsun Park (zzangjinsun@gmail.com / zzangjinsun@kaist.ac.kr)
% Computer Vision and Image Processing Lab, KAIST, KOREA
%
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% Hae-Gon Jeon, Jaesik Park, Gyeongmin Choe, Jinsun Park, Yunsu Bok, Yu-Wing Tai and In So Kweon
% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), Jun 2015
%
% Name   : ShearingCompensation
% Input  : LF     - light field images
%          D_R    - row wise distortion
%          D_C    - column wise distortion
%          POINT  - fft point
%          DISP   - display flag
% Output : RESULT - compensated light field images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RESULT = ShearingCompensation(LF, D_R, D_C, POINT, DISP)
% Get the size of image
[M, N, R, C, CH] = size(LF);

if(DISP ~= 0)
    fprintf(1,'\nEPI bending started.\n');
end

for ch=1:CH
    if(DISP ~= 0)
        fprintf(1,'\nChannel : %5.0d / %5.0d',ch,CH);
    end
    
    for i=1:M
        if(DISP ~= 0)
            fprintf(1,'\ni : %5.0d / %5.0d\n',i,M);
            str_length = 0;
        end
        
        for r=1:R
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'Row : %5.0d / %5.0d',r,R);
            end
            EPI = squeeze(LF(i,:,r,:,ch));

            BENT = EPIShearingPixel(EPI,D_R(r,:,ch),POINT);

            LF(i,:,r,:,ch) = BENT;
        end
    end
    
    for j=1:N
        if(DISP ~= 0)
            fprintf(1,'\nj : %5.0d / %5.0d\n',j,N);
            str_length = 0;
        end
        for c=1:C
            if(DISP ~= 0)
                fprintf(1,repmat('\b',1,str_length));
                str_length = fprintf(1,'Col : %5.0d / %5.0d',c,C);
            end
            EPI = squeeze(LF(:,j,:,c,ch));

            BENT = EPIShearingPixel(EPI, D_C(:,c,ch), POINT);
            
            LF(:,j,:,c,ch) = BENT;
        end
    end
end

if(DISP ~= 0)
    fprintf('\nEPI bending finished.\n');
end

RESULT = LF;

return;