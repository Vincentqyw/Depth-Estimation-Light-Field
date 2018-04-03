function defocus_response = DEFOCUS_COST_CVPR2016(IM_Refoc_alpha,center,LF_parameters,defocus_radius,small_radius,gamma)

y_size = LF_parameters.yRes;
x_size = LF_parameters.xRes;

s_pix = small_radius;

% 
grad_map         = abs((IM_Refoc_alpha)-(center))                         ;
h                = fspecial('average',[small_radius small_radius])    ;
grad_map    = imfilter(grad_map/255,h,'symmetric')                       ;
grad_map    = ((grad_map(:,:,1).^2 ...
                    +grad_map(:,:,2).^2 ...
                    +grad_map(:,:,3).^2)/3).^(1/2)        ;
avg_map    = imfilter(center/255,h,'symmetric')                       ;

grad_map_ext = ones(9,y_size+defocus_radius-1,x_size+defocus_radius-1);
avg_map_ext = ones(10,y_size+defocus_radius-1,x_size+defocus_radius-1,3);
                
diffY = -s_pix;
diffX = -s_pix;
grad_map_ext(1,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(1,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = -s_pix;
diffX = 0;
grad_map_ext(2,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(2,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = -s_pix;
diffX = s_pix;
grad_map_ext(3,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(3,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = 0;
diffX = -s_pix;
grad_map_ext(4,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(4,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = 0;
diffX = 0;
grad_map_ext(5,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(5,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = 0;
diffX = s_pix;
grad_map_ext(6,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(6,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = s_pix;
diffX = -s_pix;
grad_map_ext(7,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(7,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = s_pix;
diffX = 0;
grad_map_ext(8,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(8,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = s_pix;
diffX = s_pix;
grad_map_ext(9,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = grad_map;
avg_map_ext(9,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = avg_map;

diffY = 0;
diffX = 0;
avg_map_ext(10,round(defocus_radius/2)+diffY:y_size+floor(defocus_radius/2)+diffY,round(defocus_radius/2)+diffX:x_size+floor(defocus_radius/2)+diffX,:) = center/255;

avg_map_ext = abs(avg_map_ext(1:9,:,:,:) - repmat(avg_map_ext(10,:,:,:),9,1,1,1));
avg_map_ext    = (avg_map_ext(:,:,:,1)+avg_map_ext(:,:,:,2)+avg_map_ext(:,:,:,3))/3;

[grad_map, idx_grad] = min(grad_map_ext,[],1);
idx_grad = reshape(idx_grad,y_size+defocus_radius-1,x_size+defocus_radius-1);
avg_map = zeros(y_size+defocus_radius-1,x_size+defocus_radius-1);
for i = 1:9
   temp = reshape(avg_map_ext(i,:,:),y_size+defocus_radius-1,x_size+defocus_radius-1); 
   avg_map(idx_grad==i) = temp(idx_grad==i);
end

grad_map_ext = sort(grad_map_ext,1,'ascend');
grad_map = grad_map_ext(1,:,:);
grad_map = reshape(grad_map,y_size+defocus_radius-1,x_size+defocus_radius-1);

grad_map = grad_map + avg_map * gamma;
grad_map = imcrop(grad_map,[round(defocus_radius/2) round(defocus_radius/2) x_size-1 y_size-1]); 



defocus_response = grad_map;
end

