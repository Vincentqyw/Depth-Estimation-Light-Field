
function SPO(input_path, output_path, NumberOfBins)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT:
% Shuo Zhang (shuo.zhang@buaa.edu.cn)

% TERMS OF USE : 
% Any scientific work that makes use of our code should appropriately
% mention this in the text and cite our CVIU 2016 paper. For commercial
% use, please contact us.

% PAPER TO CITE:
% Shuo Zhang, Hao Sheng, Chao Li, Jun Zhang and Zhang Xiong.
% Robust depth estimation for light field via spinning parallelogram operator
% Computer Vision and Image Understanding, 2016, 145(C), 148-159

% BIBTEX TO CITE:
%   @article{Zhang2016Robust,
%     title={Robust depth estimation for light field via spinning parallelogram 
%   		  operator},
%     author={Zhang, Shuo and Sheng, Hao and Li, Chao and Zhang, Jun and Xiong, 
%   		  Zhang},
%     journal={Computer Vision and Image Understanding},
%     volume={145},
%     pages={148-159},
%     year={2016},
%     } 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameter setting
nD = 64;                               % number of depth labels
alpha = 0.8;                           % alpha in Eq (3)
sigma = 0.26;                          % sigma in Eq (6)   
run(strcat(input_path,'depth_opt.m')); % parameter of the light field image
% opts.Dmin: the minimum disparity between the border view and the central view; (-2 default)
% opts.Dmax: the maximum disparity between the border view and the central view; (2 default)
% opts.NumView: the angular resolution; (9 default)

%% Image loading  
% light field image: 3-dimension (height*NumView, width*NumView, nB)
img = double(imread(strcat(input_path,'lf.bmp')));                          

% extrat EPIs from Light Field Images
[img_h_RGB, img_v_RGB, img_view] = ExtractEPI(img, opts.NumView);           

%% Local depth estimation by SPO
% local depth estimation in Eq.3 and Eq.4
[cost_h, cost_v] = LocalDepthSPO(img_h_RGB, img_v_RGB, NumberOfBins, alpha, nD, opts);

% winner-takes-all strategy in Eq.5                                                 
[~,labels_max] = max(cost_h,[],3);                                          
save_img = uint8((256/(nD))*(labels_max-1));
imwrite(save_img,(strcat(output_path,'local_depth_h.bmp')));

[~,labels_max] = max(cost_v,[],3);                                         
save_img = uint8((256/(nD))*(labels_max-1));
imwrite(save_img,(strcat(output_path,'local_depth_v.bmp')));

%% Confidence calculation
% the weighted cost volume calculated in Eq.7
weight_cost = ConfidenceCal(cost_h, cost_v, sigma, nD);                 

[~,labels_max] = max(weight_cost,[],3);
save_img = uint8((256/(nD))*(labels_max-1));
imwrite(save_img,(strcat(output_path,'local_depth_integration.bmp')));

%% Depth Optimization
% guided filter for the cost volume
r = 7;                                                                  
eps = 0.0001; 

tic;
reverseStr = ''  ;
for d=1:nD 
        p = weight_cost(:,:,d);
        q = guidedfilter_color(double(img_view), double(p), r, eps);        
        weight_cost(:,:,d) = q;
        msg = sprintf('Processing: %d/%d done!\n',d, nD)  ;
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
fprintf('Final depth estimation completed in %.2f sec\n', toc);

[~,weightD] = max(weight_cost,[],3);
save_img = uint8((256/(nD))*(weightD-1));
imwrite(save_img,strcat(output_path,'SPO_depth.bmp'));

