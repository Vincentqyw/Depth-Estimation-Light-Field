function depth_output  = DEPTH_MRF(defocus_depth,corresp_depth,...
                                   defocus_confi,corresp_confi,...
                                   IM_Pinhole,LF_parameters)
%DEPTH_MRF 
%           Takes defocus and correspondence and uses MRF
%           Input : defocus_depth,corresp_depth
%                   defocus_confi,corresp_confi
%           Output: depth_output (regularized)

%           EQUATION (9) (10) (11) in paper

Z1 = defocus_depth  ;
Z1 = double(Z1) * -4    ;

Z2 = corresp_depth  ;
Z2 = double(Z2) * -4    ;

W1 = defocus_confi  ;
W2 = corresp_confi  ;


WS_PENALTY_W1        = LF_parameters.WS_PENALTY_W1                        ;
WS_PENALTY_W2        = LF_parameters.WS_PENALTY_W2                        ;
lambda_flat          = LF_parameters.lambda_flat                          ;
lambda_smooth        = LF_parameters.lambda_smooth                        ;
ROBUSTIFY_SMOOTHNESS = LF_parameters.ROBUSTIFY_SMOOTHNESS                 ;
gradient_thres       = LF_parameters.gradient_thres                       ;
SOFTEN_EPSILON       = LF_parameters.SOFTEN_EPSILON                       ;
CONVERGE_FRACTION    = LF_parameters.CONVERGE_FRACTION                    ;    
lambdas_eq           = [1,1]                                              ;

% Equation (9)
Zs                   = {Z1,Z2}                                            ;
Ws                   = {W1.^WS_PENALTY_W1, W2.^WS_PENALTY_W2}             ;

% Equation (10) (11) - Janoch et al. 2011
Zsmooth1 = smoothZ(Zs, Ws, lambdas_eq, lambda_flat, lambda_smooth, ...
    ROBUSTIFY_SMOOTHNESS,IM_Pinhole,gradient_thres, ...
    SOFTEN_EPSILON,CONVERGE_FRACTION)                                     ;

depth_output = (Zsmooth1/(-4))/255                                        ;

end

