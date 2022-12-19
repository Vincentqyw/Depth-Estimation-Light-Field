function out = visualizeNormals(Z)

N = getNormals_conv(Z);
N = N(:,:,[3,1,2]);
N(:,:,2:3) = N(:,:,2:3) / 1.25;
V = max(0, min(1, yuv2rgb_simple(N)));

V(isnan(N)) = 0;

if nargout == 0
  imagesc(V);
  imtight;
else
  out = V;
end
