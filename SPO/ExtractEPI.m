
function [img_h, img_v, img_view, focus_img] = FulltoEPI(img_RGB,NumView)

midView = round(NumView/2);
[height,width, nD] = size(img_RGB);
img_h = zeros(height,width/NumView,nD); 

for i=1:height/NumView
    for j=1:width/NumView
        img_h(1+(i-1)*NumView:NumView+(i-1)*NumView,j,:) = img_RGB(midView+(i-1)*NumView,1+(j-1)*NumView:NumView+(j-1)*NumView,:);
    end
end
% img_h = uint8(img_h);
% imwrite(img_h,'lf_h.jpg');
% clear img_h;

img_v = zeros(height/NumView,width,nD);
for i=1:height/NumView
    for j=1:width/NumView
        img_v(i,1+(j-1)*NumView:NumView+(j-1)*NumView,:) = img_RGB(1+(i-1)*NumView:NumView+(i-1)*NumView,midView+(j-1)*NumView,:);
    end
end
% img_v = uint8(img_v);
% imwrite(img_v,'lf_v.jpg');
% clear img_v;


img_view = img_RGB(midView:NumView:end,midView:NumView:end,:);
% img_view = uint8(img_view);
% imwrite(img_view,'img_view.jpg');

% img_view = img_RGB(midView:NumView:end,7:NumView:end,:);
% img_view = uint8(img_view);
% imwrite(img_view,'img_view7.jpg');


focus_img = zeros(height/NumView,width/NumView,3);
for viewh = 1:NumView
    for viewv = 1:NumView
        for nB = 1:nD
            focus_img(:,:,nB) = focus_img(:,:,nB) + double(img_RGB(viewh:NumView:end,viewv:NumView:end,nB));
        end
    end
end
focus_img = focus_img./(NumView*NumView);
% imwrite(uint8(focus_img/(NumView*NumView)),'img_focus.bmp');
