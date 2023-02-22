function plot_typhoon_tracks(typhoon_lat, typhoon_lon, typhoon_wind_speed, typhoon_pressure)
% Plot typhoon tracks

% Create figure
figure();

% Plot typhoon tracks
scatter(typhoon_lon, typhoon_lat, 30, typhoon_wind_speed, 'filled');
colormap(jet);
colorbar();
xlabel('Longitude');
ylabel('Latitude');
title('Typhoon Tracks');

% Save figure
filename = sprintf('typhoon_tracks_%d.png', t);
saveas(gcf, filename);

% Generate report
report = sprintf('Typhoon tracks for time step %d\n', t);
report = [report sprintf('Number of typhoons detected: %d\n', length(typhoon_lat))];
for i = 1:length(typhoon_lat)
report = [report sprintf('Typhoon %d\n', i)];
report = [report sprintf(' Location: (%f, %f)\n', typhoon_lat(i), typhoon_lon(i))];
report = [report sprintf(' Maximum Wind Speed: %f m/s\n', typhoon_wind_speed(i))];
report = [report sprintf(' Minimum Pressure: %f hPa\n', min(typhoon_pressure(i,:)))];
end

% Save report
report_filename = sprintf('typhoon_report_%d.txt', t);
fid = fopen(report_filename, 'w');
fprintf(fid, report);
fclose(fid);

end
