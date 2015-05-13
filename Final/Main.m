% Silent Piano
% 
% Olalekan Afuye
% Gabriel Blanco
% Harrison Liew
% Minh Trang Nguyen
%

clear; clc;
close all;
addpath('stabilization');
addpath('soundgeneration');

%% Input Parameters

videoname = 'TwoHanded.mov';
highest_note = 73;      % Highest 2handed

% videoname = 'OneHanded.mov'; 
% highest_note = 75;      % Highest 1 hand

start_time = 1.5;       % Start Time in Video (Saves Time while processing)

%% Load Video

filename = fullfile('videos',videoname);
extract_temp_scale(filename, 4, 0);
temp = load('template.mat');
vid = VideoReader(filename);
num_frames = ceil(vid.FrameRate * vid.Duration);
% vid  = VideoReader(filename); % recreate video after getting number of frames

%% Get First Frame, Create Map and Stabilize

disp('Creating Key Note Mapping...');
f = readFrame(vid);
map = createMap(f, vid.Height);

disp('Stabilizing Video...')
radius = 4;
[x, y, fs] = stabilize_frame(f, temp, radius);

%% Sliding Window Buffer

n = 3;                    % Size of Buffer Window
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

%% Starting Time
vid.CurrentTime = start_time; % jump to this point in video
count = round(vid.FrameRate * start_time);
init_count = count;

map_size = size(map);

binsize = 10;  % number of columns per bin

%% Loop

disp('Scanning for Keypresses...');

raw_presses = zeros(num_frames, map_size(1));

while hasFrame(vid)

    % Stabilized frames for diff, sliding window
    f = readFrame(vid);
    [~, ~, new_frame] = stabilize_frame(f, temp, radius);
    nh = noHandsFilter(f);
    
    % Merge Hand Removal frames
    nhf = and(buffer(:,:,1,2), nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius));
    
    % Change diff to b&w, mask with hand filter
    diff = uint8(abs(double(new_frame) - buffer(:, :, 1, 1))); % both positive and negative diffs
    buffer(:, :, 1, :) = [];
    buffer(:, :, n, 1) = new_frame;
    buffer(:, :, n, 2) = nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius);
    
    bwd = im2bw(diff,.3);
    d = bwd.*nhf;
    
    % Determine if key has been pressed & make column bins (prioritizing lines)
    d1 = sum(d);
    bins = floor((vid.Width-2*radius)/binsize);
    d2 = zeros(1, bins);
    for i = 1:bins
        for j = 1:binsize
            d2(1,i) = d2(1,i) + d1(binsize*i-j+1);
        end
    end
    
    % If lines are distinct but there isn't much noise elsewhere, key
    % has been pressed
    if  max(d2) > 250 && sum(d2)/max(d2) < 5
        
        presses = keypress(map, d, radius);
        
        for i = 1:size(presses)
            key = presses(i);
            raw_presses(count, key) = 1;
        end
    end
   
    if mod(count,10) == 0
        percent = count/num_frames*100;
        fprintf('Processing: %i Percent\n',uint8(percent));
    end
    
    count = count +1;
end

%% Confirm New Press with Previous

old_raw_presses = raw_presses; % for tweaking confirm
CONFIRM = 2;
copy = raw_presses;
for c = 1:CONFIRM-1
    raw_presses(CONFIRM:num_frames) = and(raw_presses(CONFIRM:num_frames), copy(CONFIRM-c:num_frames-c));
end

%% Debouncing

notestoplay = zeros(num_frames, map_size(1));
last_pressed = init_count*ones(1, map_size(1));  % for debouncing
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

%% Parse 'notestoplay' for MIDI function

M = zeros(30,6);
startframe = 0;
endframe = 0;
index = 1;
for i = 1:map_size(1)
    for j = 2:num_frames
        if notestoplay(j, i) == 1 && notestoplay(j-1, i) == 0
            startframe = j;
        end
        if notestoplay(j, i) == 0 && notestoplay(j-1, i) == 1
            endframe = j-1;
            M(index,:) = [1, 1, highest_note-i, 120, startframe/vid.FrameRate, endframe/vid.FrameRate];
            index = index+1;
        end
    end
end

%Evaluation section
C = expectedMidiMatrix();
[hc wc] = size(C);
out = accuracy(C,M);
result = cat(2,C,out);
percentage = (100/hc).*([numel(find(out(:,1)==1)); numel(find(out(:,1)==2));numel(find(out(:,1)==0))])

% validateResults(M,expectedMidiMatrix);
disp('Writing MIDI');
writemidi(matrix2midi(M), 'output.midi');
disp('Done');

rmpath('stabilization');
rmpath('soundgeneration');