function IM_Pinhole = REMAP2PINHOLE(LF_Remap,LF_parameters)
%REMAP2PINHOLE 
%           Takes the LF RAW input and converts to our LF Standard
%           Input : Lytro_RAW_Demosaic (x',y')
%           Output: LF_Remap           (x*u,y*v)

x_size        = LF_parameters.x_size                                      ;
y_size        = LF_parameters.y_size                                      ;
UV_diameter   = LF_parameters.UV_diameter                                 ;
UV_radius     = LF_parameters.UV_radius                                   ;

IM_Pinhole = zeros(y_size,x_size,3);

for x = 1:x_size
    for y = 1:y_size
        x_coord_center = 1 + UV_radius + UV_diameter * (x - 1)            ;
        y_coord_center = 1 + UV_radius + UV_diameter * (y - 1)            ;
        
        IM_Pinhole(y,x,1) = LF_Remap(y_coord_center,x_coord_center,1)     ;
        IM_Pinhole(y,x,2) = LF_Remap(y_coord_center,x_coord_center,2)     ;
        IM_Pinhole(y,x,3) = LF_Remap(y_coord_center,x_coord_center,3)     ;
    end
end


end

