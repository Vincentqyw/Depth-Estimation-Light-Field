function out = visualizeDEM(Z)

N = getNormals_conv(Z);

range = [min(Z(~isnan(Z))), max(Z(~isnan(Z)))];

Z = (Z - range(1))./max(eps,range(2) - range(1));
Z2 = min(1, max(0, Z));
Z2(isnan(Z)) = nan;
Z = Z2;
Z = mod(.75 - Z * .75, 1);

S = N(:,:,3);

vis = max(0, min(1, hsv2rgb(cat(3, Z, ones(size(S))*.75, S))));

if nargout == 0
  imagesc(vis);
  imtight;
else
  out = vis;
end
