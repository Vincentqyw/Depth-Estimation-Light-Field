function [N, dN_Z] = getNormals_conv(Z, scale)

getNormals_filters

if nargin >= 2
  f1 = scale * f1;
  f2 = scale * f2;
  f1m = scale * f1m;
  f2m = scale * f2m;
end

n1 = conv2(Z, f1m, 'same');
n2 = conv2(Z, f2m, 'same');
N3 = 1./sqrt(n1.^2 + n2.^2 + 1);

N1 = n1 .* N3;
N2 = n2 .* N3;

N = cat(3, N1, N2, N3);

if nargout >= 2
  
  N123 = -(N1.*N2.*N3);
  N3sq = N3.^2;

%   dN_Z.F1 = cat(3, (1 - N1.*N1).*N3, N123, -N1.*N3sq);
%   dN_Z.F2 = cat(3, N123, (1 - N2.*N2).*N3, -N2.*N3sq);

  dN_Z.F1_1 = (1 - N1.*N1).*N3;
  dN_Z.F1_2 = N123;
  dN_Z.F1_3 = -N1.*N3sq;
  
  dN_Z.F2_1 = N123;
  dN_Z.F2_2 = (1 - N2.*N2).*N3;
  dN_Z.F2_3 = -N2.*N3sq;

  dN_Z.f1 = f1;
  dN_Z.f2 = f2;
  
end

% d_loss_Z = conv2( sum(d_loss_N .* dN_Z.F1, 3) , f1, 'same') + conv2( sum(d_loss_N .* dN_Z.F2, 3) , f2, 'same');