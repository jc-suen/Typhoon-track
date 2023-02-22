clear;clc
% Load the ERA5 data from the netCDF files
ncfile = 'download08.nc'; % name of the netCDF file
% Load the NetCDF data into Matlab using the built-in ncdf toolbox
u10 = ncread(ncfile, 'u10');
v10 = ncread(ncfile, 'v10');
air_pressure = ncread(ncfile, 'msl');
lat = ncread(ncfile, 'latitude');
lon = ncread(ncfile, 'longitude');

% Set the region of interest (ROI) where you want to track typhoons
lat_min = 10; % minimum latitude of ROI
lat_max = 40; % maximum latitude of ROI
lon_min = 115; % minimum longitude of ROI
lon_max = 135; % maximum longitude of ROI

% Find the indices of the ROI in the lat and lon arrays
lat_idx = find(lat >= lat_min & lat <= lat_max);
lon_idx = find(lon >= lon_min & lon <= lon_max);

% Extract the u10, v10, and air pressure data for the ROI
u10_roi = u10(lon_idx, lat_idx, :);
v10_roi = v10(lon_idx, lat_idx, :);
air_pressure_roi = air_pressure(lon_idx, lat_idx, :);

% Calculate the wind stress curl for the ROI using finite differences
dx = 111000*cosd(mean(abs(lon(2) - lon(1))));
dy = 111000*abs(lat(2) - lat(1));


% Find the minimum air pressure in the ROI
min_pressure = min(air_pressure_roi, [], 'all');

% Find the locations of the minimum air pressure
[min_lat_idx, min_lon_idx, min_time_idx] = ind2sub(size(air_pressure_roi),...
    find(air_pressure_roi == min_pressure));

% Initialize the typhoon trajectories with the locations of the first minimum air pressure
typhoon_lat = lat(min_lat_idx);
typhoon_lon = lon(min_lon_idx);
typhoon_traj = [typhoon_lat, typhoon_lon];

% Loop over time to track the typhoon trajectories
for t = min_time_idx+1:size(air_pressure_roi, 3)
    % Find the maximum wind stress curl in a small window around each typhoon location
    window_size = 5; % size of window in degrees
    num_typhoons = size(typhoon_traj, 1);
    max_wind_curls = zeros(num_typhoons, 1);
    max_lat_idxs = zeros(num_typhoons, 1);
    max_lon_idxs = zeros(num_typhoons, 1);

    dudy = gradient(u10_roi(:,:,t), dy, dx);
    dvdx = gradient(v10_roi(:,:,t), dy, dx);
    wind_stress_curl = dvdx - dudy;

    for i = 1:num_typhoons
        typhoon_lat = typhoon_traj(i, 1);
        typhoon_lon = typhoon_traj(i, 2);
        lat_idx = find(lat >= typhoon_lat - window_size & lat <= typhoon_lat + window_size);
        lon_idx = find(lon >= typhoon_lon - window_size & lon <= typhoon_lon + window_size);
        wind_stress_curl_window = wind_stress_curl(lon_idx, lat_idx);
        max_wind_curls(i) = max(wind_stress_curl_window, [], 'all');
        [max_lat_idxs(i), max_lon_idxs(i)] = ind2sub(size(wind_stress_curl_window), ...
            find(wind_stress_curl_window == (max_wind_curls(i))));
    end
    % Find the locations of the maximum wind stress curl for each typhoon
    for i = 1:num_typhoons
        max_lat_idx = max_lat_idxs(i);
        max_lon_idx = max_lon_idxs(i);
        typhoon_lat = lat(max_lat_idx);
        typhoon_lon = lon(max_lon_idx);
        typhoon_traj(i, :) = [typhoon_lat, typhoon_lon];
    end

    % Print the typhoon location for each time step
    fprintf('Time step %d:\n', t);
    for i = 1:num_typhoons
        fprintf('Typhoon %d: lat = %.2f, lon = %.2f\n', i, typhoon_traj(i, 1), typhoon_traj(i, 2));
    end
end
