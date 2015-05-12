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
init_count = count;

map_size = size(map);

binsize = 10; % number of columns per bin

% figure

% LOOP

% extract the raw presses, no debounce
raw_presses = zeros(num_frames, map_size(1));

while hasFrame(vid)

    % get stabilized frames for diff, sliding window
    f = readFrame(vid);
    [~, ~, new_frame] = stabilize_frame(f, temp, radius);
    nh = noHandsFilter(f);
    
    % merge 2 hand removal frames
    nhf = and(buffer(:,:,1,2), nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius));
    
    % change diff to b&w, mask with hand filter
    diff = uint8(abs(double(new_frame) - buffer(:, :, 1, 1))); % both positive and negative diffs
    buffer(:, :, 1, :) = [];
    buffer(:, :, n, 1) = new_frame;
    buffer(:, :, n, 2) = nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius);
    
    bwd = im2bw(diff,.3);
    d = bwd.*nhf; % final diff
    
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
    if  max(d2) > 250 && sum(d2)/max(d2) < 5
%         subplot(2,1,1)
%         imshow(d);
%         str = sprintf('frame: %i, max: %i, sum: %i', count, max(d2), sum(d2));
%         title(str);
%         subplot(2,1,2)
        presses = keypress(map, d, radius)
        
        for i = 1:size(presses)
            key = presses(i);
            raw_presses(count, key) = 1;
        end
    end
   
    drawnow
    count = count +1;
end

% confirm new press with previous
old_raw_presses = raw_presses; % for tweaking confirm
CONFIRM = 2;
copy = raw_presses;
for c = 1:CONFIRM-1
    raw_presses(CONFIRM:num_frames) = and(raw_presses(CONFIRM:num_frames), copy(CONFIRM-c:num_frames-c));
end

%raw_presses(2:num_frames) = and(raw_presses(2:num_frames), raw_presses(1:num_frames-1));


% debounce and release too long presses
notestoplay = zeros(num_frames, map_size(1));
last_pressed = init_count*ones(1, map_size(1)); % for debouncing
last_released = init_count*ones(1, map_size(1)); % for debouncing
DEBOUNCE = 6; %ignore key presses within 6 frames
RELEASE_TIME = 80;
for i = init_count:size(raw_presses, 1)
    % copy previous frame key status
    notestoplay(i, :) = notestoplay(i - 1, :);
    presses = find(raw_presses(i, :)~=0);
    for j = 1:numel(presses)
        key = presses(j);
        currently_pressed = notestoplay(i - 1, key);
        if currently_pressed && i - last_pressed(key) > DEBOUNCE
            last_released(key) = i;
            notestoplay(i, key) = 0;
        elseif ~currently_pressed && i - last_released(key) > DEBOUNCE
            last_pressed(key) = i;
            notestoplay(i, key) = 1;
        end
    end
    
    % release any keys that have been on for too long
    to_release = find(and((notestoplay(i, :) > 0), (i - last_pressed > RELEASE_TIME)) > 0);
    last_released(to_release) = i;
    notestoplay(i, to_release) = 0;
    
end

% parse notestoplay for MIDI function
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
            M = [M; 1, 1, 73-i, 120, startframe/29.97, endframe/29.97];
        end
    end
end
writemidi(matrix2midi(M), 'output.midi');