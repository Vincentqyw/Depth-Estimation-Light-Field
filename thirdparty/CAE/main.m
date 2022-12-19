clear;
clc;
close all;

% datacost type
% 1 = constrained adaptive defocus cost [Williem PAMI2017]
% 2 = constrained angular entropy cost [Williem PAMI2017]
% 3 = angular entropy cost [Williem CVPR2016]
% 4 = adaptive defocus cost [Williem CVPR2016]

% data type
% 0 = synthetic data
% 1 = Lytro data

% stringInput{1} = ('../dataset/wanner2013/buddha.h5');
stringInput{2} = ('D:\MATLAB\test\11.27\group2\25cm\25.mat');

datatype = 0;
delta = 0.02;
image_id = 2;
datacost_type = 4;
    
input_string = stringInput{image_id};

if datatype == 1
    load(input_string);
    LF = LF * 255;
    [uRes,vRes,yRes,xRes,cRes] = size(LF);
else
    ind = hdf5info(input_string);
    groundtruth = hdf5read(input_string,'/GT_DEPTH');
    LF_temp = hdf5read(input_string,'/LF');
    
    idx_size = max(size(ind.GroupHierarchy.Attributes));
    shortname = cell(idx_size,1);
    for ids = 1:idx_size
       shortname{ids} =  ind.GroupHierarchy.Attributes(ids).Shortname;
    end
    
    indexcell = strfind(shortname, 'dH');
    dH_id = find(not(cellfun('isempty', indexcell)));
    indexcell = strfind(shortname, 'focalLength');
    focalLength_id = find(not(cellfun('isempty', indexcell)));    
    indexcell = strfind(shortname, 'shift');
    shift_id = find(not(cellfun('isempty', indexcell)));
    indexcell = strfind(shortname, 'xRes');
    xRes_id = find(not(cellfun('isempty', indexcell)));
    indexcell = strfind(shortname, 'yRes');
    yRes_id = find(not(cellfun('isempty', indexcell)));
    indexcell = strfind(shortname, 'hRes');
    hRes_id = find(not(cellfun('isempty', indexcell)));
    indexcell = strfind(shortname, 'vRes');
    vRes_id = find(not(cellfun('isempty', indexcell)));
    
    dH = ind.GroupHierarchy.Attributes(dH_id).Value;
    focalLength = ind.GroupHierarchy.Attributes(focalLength_id).Value;
    shift = ind.GroupHierarchy.Attributes(shift_id).Value;

    xRes = ind.GroupHierarchy.Attributes(xRes_id).Value;
    yRes = ind.GroupHierarchy.Attributes(yRes_id).Value;
    uRes = ind.GroupHierarchy.Attributes(hRes_id).Value;
    vRes = ind.GroupHierarchy.Attributes(vRes_id).Value;
end

UV_diameter = uRes;
UV_center = round(UV_diameter/2);
UV_radius = UV_center - 1;
UV_size = UV_diameter^2;
LF_y_size = yRes * vRes;
LF_x_size = xRes * uRes;
        
depth_resolution = 75;
    
LF_parameters       = struct('LF_x_size',LF_x_size,...
                             'LF_y_size',LF_y_size,...
                             'xRes',xRes,...
                             'yRes',yRes,...
                             'UV_radius',double(UV_radius),...
                             'UV_diameter',double(UV_diameter),...
                             'UV_size',double(UV_size),...
                             'UV_center',UV_center,...
                             'depth_resolution',depth_resolution...
                             );
                                   
LF_Remap_alpha   = zeros(LF_y_size,LF_x_size,3);
E1 = (zeros(yRes,xRes,depth_resolution));
                         
if datatype == 0
    LF = permute(double(LF_temp), [5 4 3 2 1]); 
    depth = groundtruth(:,:,UV_center,UV_center)';
    disparity = (double(dH)*focalLength) ./ depth - double(shift);
    delta = max(abs(min(disparity(:))),max(disparity(:))) / floor(depth_resolution/2);
end

LF_Remap    = reshape(permute(LF, [1 3 2 4 5]), [LF_y_size LF_x_size 3]);     
IM_Pinhole = im2double(squeeze(LF(UV_center,UV_center,:,:,1:3))); 

for index = 1:depth_resolution    
    if datatype == 1
        alpha = (index-round(depth_resolution/2)) * double(delta);
    else
        alpha = (index-round(depth_resolution/2)) * double(delta);
    end

    IM_Refoc_alpha   = zeros(yRes,xRes,3);
    if datatype == 1 
        REMAP2REFOCUS_LYTRO_mex(double(xRes),double(yRes),...
                            double(UV_diameter),double(UV_radius),LF_Remap,...
                            LF_Remap_alpha,IM_Refoc_alpha,double(alpha));       
    else
        REMAP2REFOCUS_mex(double(xRes),double(yRes),...
                            double(UV_diameter),double(UV_radius),LF_Remap,...
                            LF_Remap_alpha,IM_Refoc_alpha,double(alpha));
    end 


    switch datacost_type
        case 1
            small_radius = 3;
            large_radius = small_radius*2+1;
            gamma = 15;
            E1(:,:,index) = DEFOCUS_COST_PAMI2017(IM_Refoc_alpha,IM_Pinhole,LF_parameters,small_radius,large_radius,gamma);
        case 2
            sigma = 10;
            E1(:,:,index) = CORRESP_COST_PAMI2017(LF_Remap_alpha,LF_parameters,sigma);
        case 3
            E1(:,:,index) = CORRESP_COST_CVPR2016(LF_Remap_alpha,LF_parameters);
        case 4                
            defocus_radius = 15;
            small_radius = 5;
            gamma = 0.1;
            E1(:,:,index) = DEFOCUS_COST_CVPR2016(IM_Refoc_alpha,IM_Pinhole,LF_parameters,defocus_radius,small_radius,gamma);
    end
    msg = sprintf('Processing: %d/%d done!\n',index,depth_resolution);
    fprintf(msg);                                       
end           

E1 = (E1-min(E1(:))) ./ (max(E1(:))-min(E1(:)));

% WTA
[min_cost,depth_E1] =  min(E1,[],3); 

% Graph cut
param.data = 5;
param.smooth = 2;
param.neigh = 0.005;
depth_E2 = double(GraphCuts(E1, IM_Pinhole, param));

% Edge preserving filtering
param.r = 15;
param.eps = 0.0001;
E3 = CostAgg(E1,IM_Pinhole,param);
[min_cost,depth_E3] =  min(E3,[],3); 

% Edge preserving filtering + Graph cut
param.data = 5;
param.smooth = 2;
param.neigh = 0.005;
depth_E4 = double(GraphCuts(E3, IM_Pinhole, param));

