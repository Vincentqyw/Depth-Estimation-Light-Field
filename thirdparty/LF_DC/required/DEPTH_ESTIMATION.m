function [depth] = DEPTH_ESTIMATION(response,minmax)
%DEPTH_ESTIMATION
%           Takes the response and finds the min or max
%           Input : response
%                   minmax        (0 for min- corresp, 1 for max - defocus)
%           Output: depth

%           EQUATION (6) in paper


if(minmax == 1)
    [garbage depth] = max(response,[],3)  ;
else
    [garbage depth] = min(response,[],3)  ;
end

end

