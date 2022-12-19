%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2015.05.12 Hae-Gon Jeon
% Accurate Depth Map Estimation from a Lenslet Light Field Camera
% CVPR 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function fn_SubpixelShift

% goal : Image shift with sub-pixel precision using phase theorem
% input
% f - fft of color image
% delta - 1X2 matrix for sub-pixel displacement
% nr, nc - row and column size of input image
% mode - 1) color image, 2) gradient image 
% output : a sub-pixel shifted image

function g = fn_SubpixelShift(f, delta,nr,nc,mode)

deltar = delta(1);
deltac = delta(2);
phase = 2;

Nr = ifftshift(-fix(nr/2):ceil(nr/2)-1);
Nc = ifftshift(-fix(nc/2):ceil(nc/2)-1);
[Nc,Nr] = meshgrid(Nc,Nr);

g = ifft2(f.*repmat(exp(1i*2*pi*(deltar*Nr/nr+deltac*Nc/nc)),[1 1 3])).*exp(-1i*phase);

if mode == 1
    g = min(1,max(0,abs(g))) ;
else
    g = abs(g);
end
