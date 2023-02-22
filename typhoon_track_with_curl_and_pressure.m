clear;clc
% Load the ERA5 data from the netCDF files
ncfile = 'download08.nc'; % name of the netCDF file
u10 = ncread(ncfile, 'u10');
v10 = ncread(ncfile, 'v10');
sp = ncread(ncfile, 'msl');
lat = ncread(ncfile, 'latitude');
lon = ncread(ncfile, 'longitude');
time = ncread(ncfile, 'time');
time_ad = datetime(1900,1,1) + hours(time);

% Set the search radius for identifying the typhoon center
search_radius = 200; % km

% Set the threshold for minimum pressure and wind stress curl
min_pressure = 1000; % Pa
min_curl = 1e-6; % N/m^3
min_wind = 20;% m/s

% Convert lat/lon coordinates to x/y distances in km
[lat_grid, lon_grid] = meshgrid(lat, lon);
[x, y] = ll2xy(lat_grid, lon_grid);

% Calculate the grid spacing in x and y direction
dx = 111000*cosd(mean(0.25)); % grid spacing in x-direction in m
dy = 111000*0.25; % grid spacing in y-direction in m

% % Convert lat/lon coordinates to x/y distances in km
% lat = deg2rad(lat);
% lon = deg2rad(lon);
% R = 6371; % Earth radius in km
% [x, y] = pol2cart(lon, R*lat);

typhoon_center_posion=[];
time_posion=[];

% Loop over each time step in the ERA5 data
for t = 1:size(u10,3)
    % Extract the u10, v10, and sp data for the current time step
    u10_t = squeeze(u10(:,:,t));
    v10_t = squeeze(v10(:,:,t));
    sp_t = squeeze(sp(:,:,t));
    wind_speed_t= sqrt(u10_t.^2 + v10_t.^2);

    % Calculate the wind stress curl for the current time step
    [dudy, dudx] = gradient(u10_t,dx,dy);
    [dvdy, dvdx] = gradient(v10_t,dx,dy);
    curl_tau = dvdx - dudy;

    % Find the location of the typhoon center based on the minimum
    % surface pressure and maximum wind stress curl within a search radius
    [~, min_idx] = min(sp_t(:));
    [min_lat, min_lon] = ind2sub(size(sp_t), min_idx);
    min_sp = sp_t(min_lat, min_lon);
    [max_curl, max_idx] = max(abs(curl_tau(:)));
    [max_lat, max_lon] = ind2sub(size(curl_tau), max_idx);%find the posion of max curl in total number
    max_curl = curl_tau(max_lat, max_lon);
    [max_wind, max_wind_idx] = max(wind_speed_t(:));
    [max_lat_wind, max_lon_wind] = ind2sub(size(wind_speed_t), max_wind_idx);%find the posion of max curl in total number
    max_wind_speed = wind_speed_t(max_lat_wind, max_lon_wind);
    dist_to_min = distance(lat(min_lon), lon(min_lat), lat_grid, lon_grid);%离最低气压的距离
    dist_to_max = distance(lat(max_lon), lon(max_lat), lat_grid, lon_grid);%离最大风应力旋度的距离
    dist_to_min = dist_to_min.*111;
    dist_to_max = dist_to_max.*111;

    % Apply the thresholds for minimum pressure and wind stress curl
    if min_sp/100 > min_pressure || abs(max_curl) < min_curl || max_wind_speed < min_wind
        fprintf('No typhoon detected at time: %s\n', time_ad(t));
        continue
    end
    
    in_range = dist_to_min <= search_radius & dist_to_max <= search_radius;
    curl_tau(~in_range) = NaN;
    sp_t(~in_range) = NaN;
    [~, max_idx] = max(abs(curl_tau(:)));
    [max_lat, max_lon] = ind2sub(size(curl_tau), max_idx);
    max_curl = curl_tau(max_lat, max_lon);

    typhoon_center_posion=[typhoon_center_posion; lat(min_lon), lon(min_lat)];
    time_posion=[time_posion;t];

    % Print the location, surface pressure, and wind stress curl of the typhoon center
    fprintf('Time: %s\n', time_ad(t));
    fprintf('Typhoon center: (%.2f N, %.2f E)\n', lat(min_lon), lon(min_lat));
    fprintf('Surface pressure: %.2f hPa\n', min_sp/100);
    fprintf('Max wind stress curl: %.2e N/m^3\n', max_curl);
    fprintf('Max wind speed: %.2e m/s\n', max_wind_speed);

    % Plot the wind stress curl and location of the typhoon center on a map
    H=figure;
    set(gcf,'Units','centimeter','Position',[0 0 50 40]);
    set (gca,'position',[0.1,0.1,0.8,0.8] );
    m_proj('mercator', 'lat', [double(min(lat)), double(max(lat))], 'lon',...
        [double(min(lon)), double(max(lon))]);
    m_pcolor(lon_grid, lat_grid, curl_tau);
    %m_grid('linestyle', 'none', 'linewidth', 1, 'tickdir', 'out', 'fontsize', 10);
    shading flat;
    colormap;
    colorbar('location', 'southoutside', 'fontsize', 12);
    hold on;
    % Plot the location of the typhoon center
    m_plot(lon(min_lat), lat(min_lon), 'r.', 'markersize', 20);
    m_grid('linestyle','none','box','on','YaxisLocation','left','YLim',...
        [double(lat(end)) double(lat(1))],'YTick',double(lat(end)):2:double(lat(1)),...
        'XaxisLocation','bottom','XLim',[double(lon(1)) double(lon(end))],...
        'XTick',double(lon(1)):2:double(lon(end)),'fontsize',10);

    m_gshhs_i('patch',[.7 .7 .7]);
    m_gshhs_i('color','k','linewidth',0.7);


    % Add a title and labels to the plot
    title(sprintf('Wind stress curl at %s', time_ad(t)));
    xlabel('Longitude');
    ylabel('Latitude');

    % Save the plot to a PNG file
    print(sprintf('wind_stress_curl_%04d.png', t), '-dpng', '-r300');
    close (H)
end
