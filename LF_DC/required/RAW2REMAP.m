function LF_Remap =  RAW2REMAP(Lytro_RAW_Demosaic,image_cords,LF_parameters)
%RAW2REMAP
%           Takes the LF RAW input and converts to our LF Standard
%           Input : Lytro_RAW_Demosaic (x',y')
%           Output: LF_Remap           (x*u,y*v)
%               x'= u + UV_diameter * (x - 1)
%               y'= v + UV_diameter * (y - 1)

x_size        = LF_parameters.x_size                                      ;
y_size        = LF_parameters.y_size                                      ;
UV_diameter   = LF_parameters.UV_diameter                                 ;
UV_radius     = LF_parameters.UV_radius                                   ;

LF_Remap      = zeros(y_size*UV_diameter,x_size*UV_diameter)              ;

for x = 1:x_size
    for y = 1:y_size
        
        x_cord_center = image_cords(y,x,2)                                ;
        y_cord_center = image_cords(y,x,1)                                ;
        
        for x_adjust = -UV_radius:1:UV_radius
            for y_adjust = -UV_radius:1:UV_radius
                
                x_index_in = x_cord_center+x_adjust                       ;
                y_index_in = y_cord_center+y_adjust                       ;
                
                x_index_ou = x_adjust+UV_radius+1 + (x-1)*UV_diameter     ;
                y_index_ou = y_adjust+UV_radius+1 + (y-1)*UV_diameter     ;
                
                LF_Remap(y_index_ou,x_index_ou,1) =...
                               Lytro_RAW_Demosaic(y_index_in,x_index_in,1);
                LF_Remap(y_index_ou,x_index_ou,2) =...
                               Lytro_RAW_Demosaic(y_index_in,x_index_in,2);
                LF_Remap(y_index_ou,x_index_ou,3) =...
                               Lytro_RAW_Demosaic(y_index_in,x_index_in,3);
                
            end
        end
    end
end


end

