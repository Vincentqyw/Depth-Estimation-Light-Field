function guidedfilter_color_precompute(I, r, eps)
%   guidedfilter_color_precompute   Precomputation of the O(1) time guided filter using a color image as the guidance.
%
%   - guidance image: I (should be a color (RGB) image)
%   - local window radius: r
%   - regularization parameter: eps

global gfobj;

gfobj.I = I;
gfobj.r = r;
gfobj.eps = eps;

hei = size(I,1);
wid = size(I,2);
gfobj.N = boxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.

gfobj.mean_I_r = boxfilter(I(:, :, 1), r) ./ gfobj.N;
gfobj.mean_I_g = boxfilter(I(:, :, 2), r) ./ gfobj.N;
gfobj.mean_I_b = boxfilter(I(:, :, 3), r) ./ gfobj.N;

% variance of I in each local patch: the matrix Sigma in Eqn (14).
% Note the variance in each local patch is a 3x3 symmetric matrix:
%           rr, rg, rb
%   Sigma = rg, gg, gb
%           rb, gb, bb
gfobj.var_I_rr = boxfilter(I(:, :, 1).*I(:, :, 1), r) ./ gfobj.N - gfobj.mean_I_r .*  gfobj.mean_I_r; 
gfobj.var_I_rg = boxfilter(I(:, :, 1).*I(:, :, 2), r) ./ gfobj.N - gfobj.mean_I_r .*  gfobj.mean_I_g; 
gfobj.var_I_rb = boxfilter(I(:, :, 1).*I(:, :, 3), r) ./ gfobj.N - gfobj.mean_I_r .*  gfobj.mean_I_b; 
gfobj.var_I_gg = boxfilter(I(:, :, 2).*I(:, :, 2), r) ./ gfobj.N - gfobj.mean_I_g .*  gfobj.mean_I_g; 
gfobj.var_I_gb = boxfilter(I(:, :, 2).*I(:, :, 3), r) ./ gfobj.N - gfobj.mean_I_g .*  gfobj.mean_I_b; 
gfobj.var_I_bb = boxfilter(I(:, :, 3).*I(:, :, 3), r) ./ gfobj.N - gfobj.mean_I_b .*  gfobj.mean_I_b; 

gfobj.invSigma = cell(hei, wid);
for y=1:hei
    for x=1:wid
        Sigma = [gfobj.var_I_rr(y, x), gfobj.var_I_rg(y, x), gfobj.var_I_rb(y, x);
                 gfobj.var_I_rg(y, x), gfobj.var_I_gg(y, x), gfobj.var_I_gb(y, x);
                 gfobj.var_I_rb(y, x), gfobj.var_I_gb(y, x), gfobj.var_I_bb(y, x)];
        %Sigma = Sigma + eps * eye(3);
        
        gfobj.invSigma{y, x} = inv(Sigma + eps * eye(3)); % Eqn. (14) in the paper;
    end
end
