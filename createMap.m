% Create Mapping of Location, Pitch Value

vid = VideoReader(fullfile('videos','TwoHanded.mov'));
figure(1);

f = readFrame(vid);
g = rgb2gray(f);

thresh = 25;
kernel = ones(3,3)./9;
bg = conv2(double(g), kernel, 'same');
be  = edge(double(bg),'sobel',  thresh);

imshow(be);
title('TS=25');