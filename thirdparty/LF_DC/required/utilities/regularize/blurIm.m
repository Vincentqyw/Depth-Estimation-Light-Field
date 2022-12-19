function im_blur = blurIm(im, sigma)

if isinf(sigma)
  v = mean(im(:));
  im_blur = v * ones(size(im));
elseif sigma == 0
  im_blur = im;
else
  sz = ceil(4*sigma)+1;
  kernel = exp(lnormpdf(-sz:sz, 0, sigma));
  kernel = kernel ./ sum(kernel);
  
  im_blur = conv2(kernel, kernel, im, 'same');
  
%   im_blur = imfilter(im, kernel, 'replicate', 'same');
%   im_blur = imfilter(im_blur, kernel', 'replicate', 'same');
end