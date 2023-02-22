% Input data: latitudes and longitudes of typhoon track
lat = double(typhoon_center_posion(:,1))';
lon = double(typhoon_center_posion(:,2))';

% Define a threshold distance to detect typhoon tracks
threshold_distance = 200; % in kilometers

% Find the distance between consecutive points in the track
distance = distance_on_sphere(lat, lon);

% Identify the indices where the distance exceeds the threshold
indices = find(distance > threshold_distance);

% Extract each typhoon track based on the identified indices
tracks = cell(1, length(indices) + 1);
start_idx = 1;
for i = 1:length(indices)
    end_idx = indices(i);
    tracks{i} = [lat(start_idx:end_idx); lon(start_idx:end_idx)];
    start_idx = end_idx + 1;
end
tracks{end} = [lat(start_idx:end); lon(start_idx:end)];

