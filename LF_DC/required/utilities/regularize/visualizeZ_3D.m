function visualizeTerrain(Z,im)

if (im == 0)
    surf(Z, visualizeZ(Z), 'EdgeColor', 'none'); imtight; axis image ij; view(-180, 91);
else
    surf(Z, im, 'EdgeColor', 'none'); imtight; axis image ij; view(-180, 91);
end

