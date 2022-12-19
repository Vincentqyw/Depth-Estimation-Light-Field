function response = DEFOCUS_COST_PAMI2017(IM_Refoc_alpha,IM_Pinhole,LF_parameters,small_radius,large_radius,gamma)

yRes = LF_parameters.yRes;
xRes = LF_parameters.xRes;

IM_Pinhole_pad = padarray(IM_Pinhole,[large_radius large_radius], 'symmetric');
IM_refoc_alpha_pad = padarray(IM_Refoc_alpha,[large_radius large_radius], 'symmetric');
response = zeros(yRes,xRes);

adaptive_defocus_mex(double(xRes),double(yRes),double(small_radius),double(large_radius),double(gamma),IM_refoc_alpha_pad,IM_Pinhole_pad,response);

end

