function response = CORRESP_COST_PAMI2017(LF_Remap_alpha,LF_parameters,sigma)

yRes = LF_parameters.yRes;
xRes = LF_parameters.xRes;
UV_diameter = LF_parameters.UV_diameter;
UV_radius = LF_parameters.UV_radius;

response = zeros(yRes,xRes);

adaptive_corresp_mex(double(xRes),double(yRes),double(UV_diameter),double(UV_radius),double(sigma),LF_Remap_alpha,response);

end

