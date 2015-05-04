vid = VideoReader(fullfile('videos','TwoHanded.mov'));
figure(1);

f = readFrame(vid);
g = rgb2gray(f);

kernel = ones(3,3)./9;
bg = conv2(double(g), kernel, 'same');
be5 = edge(double(bg),'sobel',  25);

THRESHOLD = 1;
% ge = edge(g,'sobel',[],'vertical');
be1 = edge(double(bg),'sobel',  15);
be5 = edge(double(bg),'sobel',  25);
be10 = edge(double(bg),'sobel', 35);
be50 = edge(double(bg),'sobel', 45);

se = ones(5,1);
im1 = imopen(be5,se);
im2 = imclose(im1,se);

imshow(be5);
title('TS=25');