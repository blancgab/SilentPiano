function diffFrames(n) 
vid = VideoReader(fullfile('videos','TwoHanded.mov'));
addpath('stabilization');

init_frame = readFrame(vid);
temp = load('template.mat');
[~, ~, stable_init] = stabilize_frame(init_frame, temp, 3);

while hasFrame(vid)
    for i = 1:n
        if i == n
            final_frame = readFrame(vid);
            [~, ~, final_stable] = stabilize_frame(final_frame, temp, 3);
        else
            readFrame(vid);
        end
    end
    close all;
    figure;
    imshow(rgb2gray(init_frame - final_frame));
    figure
    imshow(stable_init - final_stable);
    init_frame = final_frame;
    stable_init = final_stable;
    %input('Press any key to continue');
end

rmpath('stabilization');
end


