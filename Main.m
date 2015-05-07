% Silent Piano

vid = VideoReader(fullfile('videos','TwoHanded.mov'));
addpath('stabilization');
figure(1);

vidWidth = vid.Width;
vidHeight = vid.Height;

init_frame = readFrame(vid);
temp = load('template.mat');
[~, ~, stable_init] = stabilize_frame(init_frame, temp, 3);
% createMap(f)

n = 1;

while hasFrame(vid)
    
    for i = 1:n
        if i == n
            final_frame = readFrame(vid);
            [~, ~, final_stable] = stabilize_frame(final_frame, temp, 3);
        else
            readFrame(vid);
        end
    end
    
    diff = abs(final_stable-stable_init);
    
    subplot(2,1,1);
    imshow(final_frame);
    
    subplot(2,1,2);
    nhf = noHandsFilter(final_frame);
    se = ones(4,1);
    bwd = im2bw(diff,.2);
    imshow(bwd.*nhf(1:714,1:1274));   
    
    stable_init = final_stable;
    
    drawnow;
end