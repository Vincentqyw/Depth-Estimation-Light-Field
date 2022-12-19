function corresp_response = CORRESP_ANALYSIS(IM_Refoc_alpha,LF_parameters)
%CORRESP_ANALYSIS 
%           Takes the LF remapped to alpha, and outputs response
%           for each pixel. This is a rudimentry correspondence, minimum
%           variance of patches.
%           Input : IM_Refoc_alpha
%           Output: corresp_response

%           EQUATION (4) (5) in paper

corresp_radius    = LF_parameters.corresp_radius                          ;
x_size            = LF_parameters.x_size                                  ;
y_size            = LF_parameters.y_size                                  ;
UV_radius         = LF_parameters.UV_radius                               ;
UV_diameter       = LF_parameters.UV_diameter                             ;


% patch variance
corr_std_map = FAST_STDFILT_mex(IM_Refoc_alpha,corresp_radius)            ;
corr_std_map = sqrt((corr_std_map(:,:,1).^2 ...
                    +corr_std_map(:,:,2).^2 ...
                    +corr_std_map(:,:,3).^2)/3)                           ;

for x = 1:x_size
    for y = 1:y_size
            y_cord                = UV_radius+1 + (y-1)*UV_diameter       ;
            x_cord                = UV_radius+1 + (x-1)*UV_diameter       ;
            corresp_response(y,x) = corr_std_map(y_cord,x_cord)           ;
    end
end

end

