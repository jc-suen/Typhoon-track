function [x, y] = ll2xy(lon, lat)
% LL2XY Convert longitude and latitude to x and y distances in kilometers
% using a simple approximation assuming a spherical Earth with radius 6371 km.

R = 6371; % Earth's radius in kilometers
lon0 = lon(1); % Longitude of the center point
lat0 = lat(1); % Latitude of the center point

% Convert longitude and latitude to radians
lon = deg2rad(lon);
lat = deg2rad(lat);
lon0 = deg2rad(lon0);
lat0 = deg2rad(lat0);

% Calculate x and y distances in kilometers
x = R * cos(lat) .* (lon - lon0);
y = R * (lat - lat0);

end
