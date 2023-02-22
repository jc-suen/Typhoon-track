clear;clc

% Load the latitude, longitude, u10, and v10 data for the tropical cyclone
ncfile = 'download08.nc'; % name of the netCDF file
lat = ncread(ncfile, 'latitude');
lon = ncread(ncfile, 'longitude');
u10 = ncread(ncfile, 'u10');
v10 = ncread(ncfile, 'v10');
sp = ncread(ncfile, 'msl'); % surface pressure in Pa
time = ncread(ncfile, 'time'); % time in hours since 1900-01-01 00:00:00
[LON,LAT]=meshgrid(lon,lat);

% Calculate the grid spacing in x and y direction
dx = 111000*cosd(mean(0.25)); % grid spacing in x-direction in m
dy = 111000*0.25; % grid spacing in y-direction in m

% Initialize variables to track maximum wind speed and minimum pressure
max_wind_speed = 0;
min_pressure = 1e6; % set initial value to a large number
max_curl_posion=[];

% Calculate wind stress curl and minimum pressure for each time step and plot the track, max wind speed, and min pressure for each time step
for t = 1:length(time)
    % Extract the u10, v10, and sp data for the current time step
    u10_t = squeeze(u10(:,:,t));
    v10_t = squeeze(v10(:,:,t));

    % Calculate the wind stress curl using u10 and v10 data
    [du_dy, ~] = gradient(u10_t, dy, dx);
    [~, dv_dx] = gradient(v10_t, dy, dx);
    curl = (dv_dx - du_dy);%*rho_air*Cd; % calculate wind stress curl in N/m^3

    % Find the location of the maximum wind speed and minimum pressure
    [max_wind_speed_t, idx_max_wind_speed] = max(sqrt(u10_t.^2 + v10_t.^2), [], 'all', 'linear');
    [min_pressure_t, idx_min_pressure] = min(sp(:,:,t), [], 'all', 'linear');

    % Convert the index of maximum wind speed and minimum pressure to longitude and latitude
    [lat_max_wind_speed, lon_max_wind_speed] = ind2sub(size(u10_t), idx_max_wind_speed);
    [lat_min_pressure, lon_min_pressure] = ind2sub(size(sp(:,:,t)), idx_min_pressure);

    % Update maximum wind speed and minimum pressure if the current time step has a greater value
    if max_wind_speed_t > max_wind_speed
        max_wind_speed = max_wind_speed_t;
    end
    if min_pressure_t < min_pressure
        min_pressure = min_pressure_t;
    end
% 
%     % Plot the path of the tropical cyclone on a map with wind stress curl, and the location of the maximum wind speed and minimum pressure
%     figure;
%     m_proj('mercator', 'lon', [min(double(lon)) double(max(lon))], 'lat', ...
%         [min(double(lat)) max(double(lat))]);
%     m_pcolor(LON, LAT, curl');
%     shading interp;
%     m_coast('color', 'k', 'linewidth', 1);
%     m_grid('linestyle', 'none', 'linewidth', 1, 'tickdir', 'out', 'fontsize', 10);
%     m_line(LON, LAT, 'color', 'r', 'linewidth', 2);
%     m_text(lon_max_wind_speed, lat_max_wind_speed, 'Max Wind Speed', 'color', 'b', 'fontsize', 12, 'horizontalalignment', 'left');
    % Find the location of the maximum wind stress curl
    [max_curl, idx] = max(curl(:));
    [idx_r, idx_c] = ind2sub(size(curl), idx);
    lon_max_curl = lon(idx_r);
    lat_max_curl = lat(idx_c);
    max_curl_posion=[max_curl_posion;lon_max_curl,lat_max_curl];

%     % Find the location of the maximum wind speed and minimum pressure
%     [~, idx] = max(u10_t(:).^2 + v10_t(:).^2);
%     [idx_r, idx_c] = ind2sub(size(u10_t), idx);
%     lon_max_wind_speed = lon(idx_c);
%     lat_max_wind_speed = lat(idx_r);
% 
%     [~, idx] = min(sp_t(:));
%     [idx_r, idx_c] = ind2sub(size(sp_t), idx);
%     lon_min_pressure = lon(idx_c);
%     lat_min_pressure = lat(idx_r);

    % Plot the path of the tropical cyclone on a map with wind stress curl, and the location of the maximum wind speed and minimum pressure
%     figure;
%     m_proj('mercator', 'lon', [min(double(lon)) double(max(lon))], 'lat', ...
%         [min(double(lat)) max(double(lat))]);
%      m_pcolor(LON, LAT, curl');
%     shading interp;
%     m_coast('color', 'k', 'linewidth', 1);
%     m_grid('linestyle', 'none', 'linewidth', 1, 'tickdir', 'out', 'fontsize', 10);
%     m_line(LON, LAT, 'color', 'r', 'linewidth', 2);
% %     m_text(lon_max_wind_speed, lat_max_wind_speed, 'Max Wind Speed', 'color', 'b', 'fontsize', 12, 'horizontalalignment', 'left');
% %     m_text(lon_min_pressure, lat_min_pressure, 'Min Pressure', 'color', 'b', 'fontsize', 12, 'horizontalalignment', 'right');
%     m_plot(lon_max_curl, lat_max_curl, 'rx', 'markersize', 12, 'linewidth', 2);
%     title(sprintf('Tropical Cyclone Track, Max Wind Speed, and Min Pressure (Time: %d)', t));
%     colorbar;

end




