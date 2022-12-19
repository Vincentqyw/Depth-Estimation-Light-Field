close all;
clear all;

%FOLDER = '../analysis_dataset_IMG_0025/';
%FOLDER = '../analysis_bottle_reflection/';
%FOLDER = '../analysis_box_rule/';
%FOLDER = '../analysis_box_rule2/';
%FOLDER = '../analysis_box_texts/';
%FOLDER = '../analysis_flowers/';
%FOLDER = '../analysis_2_test/';
%FOLDER = '../analysis_dataset_stillLife/';
FOLDER = '../analysis_datasetbuddha/';
FOLDER = '../analysis_dataset_IMG_0025/';

Z1 = imread([FOLDER, '/1-shear_depth_estimate.png']);
Z1 = double(Z1) * -4;

W1 = double(imread([FOLDER, '/2-shear_depth_confidence.png']))/255;

Z2 = imread([FOLDER, '/3-corre_depth_estimate.png']);
Z2 = double(Z2) * -4;

W2 = double(imread([FOLDER, '/4-corre_depth_confidence.png']))/255;

im = im2double(imread([FOLDER, '/0-pinhole.png']));

Zs = {Z1, Z2};
Ws = {W1, W2};

% Play with these parameters! Here are two okay looking ones that I found
% really briefly. The Ws matter too, consider adding a constant to them, or
% raising them to a power or a fractional power.
gradient_thres = 0.1;

Zsmooth1 = smoothZ(Zs, Ws, [1, 1], 10, 10, 1,im,gradient_thres);

Zsmooth2 = smoothZ(Zs, Ws, [1, 1], 4, 4, 0,im,gradient_thres);


to_display = Zsmooth1;

to_display_max = max(max(to_display));
to_display_min = min(min(to_display));
to_display_disp = (to_display-to_display_min)./(-to_display_min+to_display_max);
imshow(to_display_disp);
visualizeZ_3D(Zsmooth1,im);

out1 = (Zsmooth1/(-4))/255;
out2 = (Zsmooth2/(-4))/255;

imwrite(out1,'smooth1.png');
imwrite(out2,'smooth2.png');