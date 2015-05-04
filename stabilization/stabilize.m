%STABILIZE_FRAME Summary of this function goes here
%   Detailed explanation goes here
[M_IMG, N_IMG] = size(img);
temp = load('template.mat');
search_radius = 3;
count = 0;
while vid.hasFrame() && count < 10
    f = readFrame(vid);    
    [x, y, cropped] = locate_template(f, temp, search_radius);
    %
    %imshow(cropped)
    count = count +1;
    %input('Press key to continue');
end


