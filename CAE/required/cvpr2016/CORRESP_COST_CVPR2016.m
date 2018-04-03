function response = CORRESP_COST_CVPR2016(LF_Remap_alpha,LF_parameters)

yRes = LF_parameters.yRes;
xRes = LF_parameters.xRes;
UV_diameter = LF_parameters.UV_diameter;
UV_radius = LF_parameters.UV_radius;
sigma = 1;

response = zeros(yRes,xRes);

entropy_mex(double(xRes),double(yRes),double(UV_diameter),double(UV_radius),double(sigma),LF_Remap_alpha,response);

end

