% Creates a mask that removes the hand (using saturation values) when
% applied to the frame differential
function [ nhf ] = noHandsFilter(f, saturation, dilation)

if ~exist('saturation','var')
    saturation = .5;
end

if ~exist('dilation','var')
    dilation = 14;
end

hsv = rgb2hsv(f);
h = hsv(:,:,2);
bwh = h > saturation;
se = ones(8,12);
im1 = imopen(bwh,se);
hands = imclose(im1,se);
se = strel('disk',dilation);
nhf = ~imdilate(hands,se);

end