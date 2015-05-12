function slidingDiffFrames(n) 
vid = VideoReader(fullfile('videos','TwoHanded.mov'));
addpath('stabilization');


init_frame = readFrame(vid);
temp = load('template.mat');
[~, ~, init_stable] = stabilize_frame(init_frame, temp, 3);
[M, N] = size(init_stable);


buffer = zeros(M, N, n);


buffer(:, :, 1) = init_stable;
for i = 2:n
    [~, ~, buffer(:, :, i)] = stabilize_frame(readFrame(vid), temp, 3);
end

count = n+1;


while hasFrame(vid)
    [~, ~, new_frame] = stabilize_frame(readFrame(vid), temp, 3);
    
    
    % update window
    imshow(new_frame - uint8(buffer(:, :, 1)));
    title(count);
    buffer(:, :, 1) = [];
    buffer(:, :, n) = new_frame;
    count = count + 1;
%     for i = 1:n
%         if i == n
%             final_frame = readFrame(vid);
%             [~, ~, final_stable] = stabilize_frame(final_frame, temp, 3);
%         else
%             readFrame(vid);
%         end
%     end
%     close all;
%     figure;
%     imshow(rgb2gray(init_frame - final_frame));
%     figure
%     imshow(stable_init - final_stable);
%     init_frame = final_frame;
%     stable_init = final_stable;
    %input('Press any key to continue');
end

rmpath('stabilization');
end


