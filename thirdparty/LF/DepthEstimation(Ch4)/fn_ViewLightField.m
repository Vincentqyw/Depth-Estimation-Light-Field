%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2015.05.14 Jaesik Park
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function fn_ViewLightField

% input : 5D light field image structure (t,s,y,x,ch), single type pixel intensities.


function fn_ViewLightField(LF)

fprintf('ViewLightField...');

ns = size(LF,1);
nt = size(LF,2);
h = size(LF,3);
w = size(LF,3);

% keyboard;

bigimg = zeros(h*nt,w*ns,3);
% cnt=1;
for t=1:nt
	ts = (t-1)*h+1;
    te = t*h;
    for s=1:ns
        ss = (s-1)*w+1;
        se = s*w;    
        img = squeeze(LF(t,s,:,:,:));
        bigimg(ts:te,ss:se,:) = img;
%         bigimg(ts:te,ss:se,1) = img(:,:,1);
%         bigimg(ts:te,ss:se,2) = img(:,:,2);
%         bigimg(ts:te,ss:se,3) = img(:,:,3);        
%         cnt = cnt + 1;      
        figure(1); imshow(img); 
        title(sprintf('s : %d, t : %d',s,t));
        pause(0.05);
    end
end

bigimg = imresize(bigimg,0.3);
figure; imshow(bigimg);

fprintf('done.\n');
