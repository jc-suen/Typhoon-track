% Helper function to calculate distance on sphere (using Haversine formula)
function d = distance_on_sphere(lat, lon)
    R = 6371; % Earth's radius in kilometers
    dlat = deg2rad(diff(lat));
    dlon = deg2rad(diff(lon));
    a = sin(dlat/2).^2 + cos(deg2rad(lat(1:end-1))).*cos(deg2rad(lat(2:end))).*sin(dlon/2).^2;
    c = 2*atan2(sqrt(a), sqrt(1-a));
    d = [0, R*c]; % distances in kilometers
end