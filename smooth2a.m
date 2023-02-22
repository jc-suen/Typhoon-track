function [B] = smooth2a(A,w)

% Pad the array with zeros
A = padarray(A,[w w],'replicate','both');

% Create a Gaussian filter
s = w/3;
[x,y] = meshgrid(-w:w,-w:w);
h = exp(-(x.^2 + y.^2)/(2*s^2))/(2*pi*s^2);

% Normalize the filter
h = h/sum(h(:));

% Convolve the filter with the padded array
B = conv2(A,h,'valid');

end