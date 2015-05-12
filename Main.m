% Silent Piano

close all

% load video
filename = fullfile('videos','TwoHanded.mov');
extract_temp_scale(filename, 4, 0);
temp = load('template.mat');
vid = VideoReader(filename);
num_frames = vid.NumberOfFrames;
vid  = VideoReader(filename); % recreate video after getting number of frames



% get first frame, create map, stabilize
f = readFrame(vid);
map = createMap(f, vid.Height);
radius = 4;
[x, y, fs] = stabilize_frame(f, temp, radius);

% sliding bufferQ2
n = 3; % # of frames
[M, N] = size(fs);
buffer = zeros(M, N, n, 2);
buffer(:, :, 1, 1) = fs;
nh = noHandsFilter(f);
buffer(:, :, 1, 2) = nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius);
for i = 2:n
    f = readFrame(vid);
    [~, ~, buffer(:, :, i, 1)] = stabilize_frame(f, temp, radius);
    nh = noHandsFilter(f);
    buffer(:, :, 1, 2) = nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius);
end
%count = n+1;

% other parameters
start_time = 1.5;
vid.CurrentTime = start_time; % jump to this point in video

count = round(vid.FrameRate * start_time);

map_size = size(map);

notestoplay = zeros(num_frames, map_size(1));
last_pressed = count*ones(1, map_size(1)); % for debouncing
last_released = count*ones(1, map_size(1)); % for debouncing
DEBOUNCE = 4; %ignore key presses within 4 frames
RELEASE_TIME = 80;


binsize = 10; % number of columns per bin

figure

% LOOP

while hasFrame(vid)

    % get stabilized frames for diff, sliding window
    f = readFrame(vid);
    [~, ~, new_frame] = stabilize_frame(f, temp, radius);
    nh = noHandsFilter(f);
    
    % merge 2 hand removal frames
    nhf = and(buffer(:,:,1,2), nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius));
    
    % change diff to b&w, mask with hand filter
    diff = new_frame - uint8(buffer(:, :, 1, 1));
    diff2 = uint8(abs(double(new_frame) - buffer(:, :, 1, 1))); % both positive and negative diffs
    buffer(:, :, 1, :) = [];
    buffer(:, :, n, 1) = new_frame;
    buffer(:, :, n, 2) = nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius);
    
    bwd = im2bw(diff,.3);
    bwd2 = im2bw(diff2, .3);
    d = bwd.*nhf; % final diff
%     d2 = bwd2.*nhf;
%     subplot(2, 1, 1);
%     imshow(d);
%     subplot(2, 1, 2);
%     imshow(d2);
%     drawnow
    
    % determine if key has been pressed
    % make column bins (prioritizes lines)
    d1 = sum(d);
    bins = floor((vid.Width-2*radius)/binsize);
    d2 = zeros(1, bins);
    for i = 1:bins
        for j = 1:binsize
            d2(1,i) = d2(1,i) + d1(binsize*i-j+1);
        end
    end
    % if lines are distinct but there isn't too much noise elsewhere, key
    % has been pressed
    
    % copy last state to new frame
    notestoplay(count, :) = notestoplay(count - 1, :);
    
    if  max(d2) > 200 && sum(d2)/max(d2) < 3.5
        subplot(2,1,1)
        imshow(d);
        str = sprintf('frame: %i, max: %i, sum: %i', count, max(d2), sum(d2));
        title(str);
        subplot(2,1,2)
        plot(d2)
        ylim([0 200])
        presses = keypress(map, d, radius)
        for i = 1:size(presses)
            key = presses(i);
            currently_pressed = notestoplay(count - 1, key);
            if currently_pressed && count - last_pressed(key) > DEBOUNCE
                last_released(key) = count;
                notestoplay(count, key) = 0;
            elseif ~currently_pressed && count - last_released(key) > DEBOUNCE
                last_pressed(key) = count;
                notestoplay(count, key) = 1;
            end
        end
        % release any keys that have been on for too long
        
    end
     to_release = find(and((notestoplay(count, :) > 0), (count - last_pressed > RELEASE_TIME)) > 0);
     last_released(to_release) = count;
     notestoplay(count, to_release) = 0;
     
    %input('continue ');
    drawnow
    count = count +1;
end

M = [];
startframe = 0;
endframe = 0;
for i = 1:map_size(1)
    for j = 2:num_frames
        if notestoplay(j, i) == 1 && notestoplay(j-1, i) == 0
            startframe = j;
        end
        if notestoplay(j, i) == 0 && notestoplay(j-1, i) == 1
            endframe = j-1;
            M = [M; 1, 1, 73-i, 30, startframe/29.97, endframe/29.97];
        end
    end
end
writemidi(matrixtomidi(M), 'output.midi');
% play(notestoplay);