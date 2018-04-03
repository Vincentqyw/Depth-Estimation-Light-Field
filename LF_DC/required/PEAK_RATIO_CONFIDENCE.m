function confidence = PEAK_RATIO_CONFIDENCE(response,LF_parameters,minmax)
%PEAK_RATIO_CONFIDENCE
%           Takes the image refocused to alpha, and outputs response
%           for each pixel. This is a rudimentry contrast-based peak detection.
%           Input : response
%                   minmax        (0 for min- corresp, 1 for max - defocus)
%           Output: confidence

%           EQUATION (7) in paper

x_size           = LF_parameters.x_size                                   ;
Y_size           = LF_parameters.y_size                                   ;
depth_resolution = LF_parameters.depth_resolution                         ;

if(minmax == 1)
    for x = 1:x_size
        for y = 1:Y_size
            squeeze_response = squeeze(response(y,x,1:depth_resolution));
            
            [squeeze_response_sorted_peaks,imax,xmin,imin] = extrema(squeeze_response);
            if numel(squeeze_response_sorted_peaks) <= 1
                squeeze_response_sorted = sort(squeeze_response,'ascend');
                confidence(y,x) = squeeze_response_sorted(1)/squeeze_response_sorted(2);
            else
                confidence(y,x) = squeeze_response_sorted_peaks(1)/squeeze_response_sorted_peaks(2);
            end
        end
    end
else
    for x = 1:x_size
        for y = 1:Y_size
            squeeze_response = squeeze(response(y,x,1:depth_resolution));
         
            [xmax,imax,squeeze_response_sorted_peaks,imin] = extrema(squeeze_response);
            if numel(squeeze_response_sorted_peaks) <= 1
                squeeze_response_sorted = sort(squeeze_response,'descend');
                confidence(y,x) = squeeze_response_sorted(2)/squeeze_response_sorted(1);
            else
                confidence(y,x) = squeeze_response_sorted_peaks(2)/squeeze_response_sorted_peaks(1);
            end
        end
    end
end

end

