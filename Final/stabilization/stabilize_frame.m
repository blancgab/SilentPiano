function [ x, y, cropped ] = stabilize_frame( img, temp, search_radius, scale )
%LOCATE_TEMPLATE center image based on locating position of temp.template
%in img. 
%   New image size = size-2*search_radius
%   Detailed explanation goes here

if nargin < 4
    scale = 4;
end
img = rgb2gray(img);



template = temp.template;
col0 = temp.col0;
row0 = temp.row0;

search_radius = search_radius * scale;
template = double(template);
img = double(imresize(img, scale, 'bicubic'));

[M, N] = size(template);


dif = zeros(2*search_radius+1);

for col = col0-search_radius:col0+search_radius
    for row = row0-search_radius:row0+search_radius
        region = img(row:row+M-1, col:col+N-1);
        dif(row-(row0-search_radius)+1, col-(col0-search_radius)+1) = sum(sum(abs(region-template)));
    end
end
[minx, miny] = find(dif == min(min(dif)));
x = (minx(1) - search_radius)-1; % relative to origin
y = (miny(1)- search_radius)-1;

[M_IMG, N_IMG] = size(img);


if (x ~= 0 || y ~= 0)
    copy = zeros(2*search_radius + M_IMG, 2*search_radius + N_IMG);
    copy(1+ search_radius-x: M_IMG + search_radius-x, 1+search_radius-y: N_IMG + search_radius-y) = img;
    cropped = copy(2*search_radius+1:M_IMG, 2*search_radius+1:N_IMG);
else
    cropped = img(search_radius+1:M_IMG-search_radius, search_radius+1:N_IMG-search_radius);
end
cropped = uint8(cropped);
cropped = imresize(cropped, 1/scale, 'bicubic');

end


