%% Depth Parameter for 'Buddha'
o_min = -1.5402;         			% the minimum disparity of adjacent view
o_max = 0.8458;          			% the maximum disparity of adjacent view

opts.NumView = 9;        			% the angular resolution
midView = floor(opts.NumView/2);
opts.Dmin = o_min*midView;    		% the minimum disparity between the border view and the central view
opts.Dmax = o_max*midView;    		% the maximum disparity between the border view and the central view


