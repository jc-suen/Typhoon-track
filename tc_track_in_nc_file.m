% Load the latitude, longitude, u10, and v10 data for the tropical cyclone
ncfile = 'era5_data.nc'; % name of the netCDF file
lat = ncread(ncfile, 'latitude');
lon = ncread(ncfile, 'longitude');
u10 = ncread(ncfile, 'u10');
v10 = ncread(ncfile, 'v10');

% Calculate the wind speed using u10 and v10 data
wind_speed = sqrt(u10.^2 + v10.^2);

% Find the maximum wind speed
[max_wind_speed, index_wind_speed] = max(wind_speed(:));

% Extract the latitude and longitude of the maximum wind speed
lat_max_wind_speed = lat(mod(index_wind_speed-1,length(lat))+1);
lon_max_wind_speed = lon(ceil(index_wind_speed/length(lat)));

% Calculate the wind stress curl using u10 and v10 data
rho_air = 1.2; % density of air in kg/m^3
Cd = 1.2*10^-3; % drag coefficient
dx = 111000*cosd(lat); % grid spacing in x-direction in m
dy = 111000; % grid spacing in y-direction in m
du_dy = (u10(2:end,:) - u10(1:end-1,:))/dy;
dv_dx = (v10(:,2:end) - v10(:,1:end-1))/dx;
curl = (dv_dx(2:end,:) - du_dy(:,2:end))*rho_air*Cd; % calculate wind stress curl in N/m^3

% Plot the path of the tropical cyclone on a map with wind stress curl, and the location of the maximum wind speed
figure;
m_proj('mercator', 'lon', [min(lon) max(lon)], 'lat', [min(lat) max(lat)]);
m_pcolor(lon, lat, curl');
shading interp;
m_coast('color', 'k', 'linewidth', 1);
m_grid('linestyle', 'none', 'linewidth', 1, 'tickdir', 'out', 'fontsize', 10);
m_line(lon, lat, 'color', 'r', 'linewidth', 2);
m_text(lon_max_wind_speed, lat_max_wind_speed, 'Max Wind Speed', 'color', 'b', 'fontsize', 12, 'horizontalalignment', 'left');
colorbar;
title('Path of Tropical Cyclone and Wind Stress Curl');
