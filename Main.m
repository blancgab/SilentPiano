%% Silent Piano

close all

% load video
temp = load('template.mat');
vid = VideoReader(fullfile('videos','TwoHanded.mov'));

% get first frame, create map, stabilize
f = readFrame(vid);
map = createMap(f, vid.Height);
radius = 4;
[x, y, fs] = stabilize_frame(f, temp, radius);

% sliding buffer
n = 2; % # of frames
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
count = n+1;

% other parameters
vid.CurrentTime = 1.5; % jump to this point in video
binsize = 10; % number of columns per bin
notestoplay = [];
figure

%% LOOP

while hasFrame(vid)

    % get stabilized frames for diff, sliding window
    f = readFrame(vid);
    [~, ~, new_frame] = stabilize_frame(f, temp, radius);
    nh = noHandsFilter(f);
    
    % merge 2 hand removal frames
    nhf = and(buffer(:,:,1,2), nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius));
    
    % change diff to b&w, mask with hand filter
    diff = new_frame - uint8(buffer(:, :, 1, 1));
    buffer(:, :, 1, :) = [];
    buffer(:, :, n, 1) = new_frame;
    buffer(:, :, n, 2) = nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius);
    
    bwd = im2bw(diff,.2);
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
    if  max(d2) > 300 && sum(d2)/max(d2) < 3.5
        subplot(2,1,1)
        imshow(d);
        str = sprintf('frame: %i, max: %i, sum: %i', count, max(d2), sum(d2));
        title(str);
        subplot(2,1,2)
        plot(d2)
        ylim([0 200])
        presses = keypress(map, d, radius);
        for i = 1:size(presses)
            notestoplay = [notestoplay; count, presses(i)];
        end
    end
    
    % input('continue ');
    drawnow
    count = count +1;
end

% play(notestoplay);