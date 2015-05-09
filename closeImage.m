addpath('stabilization');

original = rgb2gray(imread('frame0.bmp'));
m = rgb2gray(imread('keyMask.bmp'));
%mask = im2bw(m, 1-graythresh(m));
% 
% afterOpening = imopen(original,mask);
% figure, imshow(afterOpening,[]);

BW = im2bw(original, graythresh(original));

filt = zeros(size(mask)-2);
filt = padarray(filt, [0, 40], 1, 'both');
imshow(filt);

out = imfilter(double(BW), double(filt));
out = (out-min(min(out)))/(max(max(out)) - min(min(out)))*255;
out = uint8(out);
imshow(out);



rmpath('stabilization');