function defocus_response = DEFOCUS_ANALYSIS(IM_Refoc_alpha,LF_parameters)
%DEFOCUS_ANALYSIS 
%           Takes the image refocused to alpha, and outputs response
%           for each pixel. This is a rudimentry contrast-based peak detection.
%           Input : IM_Refoc_alpha
%           Output: defocus_response

%           EQUATION (2) (3) in paper


defocus_radius = LF_parameters.defocus_radius                             ;

% contrast-peak detection
grad_map         = abs(gradient(IM_Refoc_alpha))                          ;
h                = fspecial('average',[defocus_radius defocus_radius])    ;
shear_std_map    = imfilter(grad_map,h,'symmetric')                       ;
shear_std_map    = ((shear_std_map(:,:,1).^2 ...
                    +shear_std_map(:,:,2).^2 ...
                    +shear_std_map(:,:,3).^2)/3).^(1/2)                   ;
    
defocus_response = shear_std_map                                          ;
end

