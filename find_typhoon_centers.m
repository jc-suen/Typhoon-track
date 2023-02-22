function [typhoon_lat, typhoon_lon, typhoon_wind_speed, typhoon_pressure] = find_typhoon_centers(wind_lat, wind_lon, wind_speed, pressure_lat, pressure_lon, pressure_gradient, wind_speed_threshold, pressure_gradient_threshold)
% Find typhoon centers using wind speed and pressure gradient criteria

% Smooth wind speed and pressure gradient data
wind_speed_smooth = smooth2a(wind_speed, 5, 5);
pressure_gradient_smooth = smooth2a(pressure_gradient, 5, 5);

% Find grid cells where wind speed and pressure gradient exceed thresholds
typhoon_idx = (wind_speed_smooth > wind_speed_threshold) & (pressure_gradient_smooth > pressure_gradient_threshold);

% Find typhoon centers
[typhoon_lat, typhoon_lon] = find(typhoon_idx);
typhoon_wind_speed = wind_speed(typhoon_idx);
typhoon_pressure = pressure(typhoon_lat, typhoon_lon);

% Convert lat/lon to degrees
typhoon_lat = wind_lat(typhoon_lat);
typhoon_lon = wind_lon(typhoon_lon);

end