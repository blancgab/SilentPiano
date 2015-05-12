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
%map = createMap(f, vid.Height);

map_size = size(map);
bin_width = 15;
bin = ones(size(map{1, 2}, 1), bin_width);
peaks = ones(map_size(1), 4);
for i = 1: map_size(1)
    m = map{i, 2};
    dif = double(diff(m, 1, 2) ~= 0); % transitions
    con = conv2(dif, bin, 'same');
    
    m_sum = sum(con);
    [lval, locs] = findpeaks(m_sum, 'SortStr', 'descend', 'MinPeakDistance', 10);
    if (numel(locs) < 2)
        locs(2:4) = locs(1);
    elseif (numel(locs) < 3)
        locs(3:4) = locs(1);
    elseif (numel(locs) < 4)
        locs(4) = locs(1);
    end
    
    locs = locs - 1;
    peaks(i, :) = sort(locs(1:4));
    
    imshow(m);
    hold on
%     line([locs(1) locs(1)], [0, size(m, 1)]);
%     line([locs(2) locs(2)], [0, size(m, 1)]);
%     line([locs(3) locs(3)], [0, size(m, 1)]);
%     line([locs(4) locs(4)], [0, size(m, 1)]);
%     input('continue');
end


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
    diff2 = uint8(abs(double(new_frame) - buffer(:, :, 1, 1))); % both positive and negative diffs
    buffer(:, :, 1, :) = [];
    buffer(:, :, n, 1) = new_frame;
    buffer(:, :, n, 2) = nh(radius+1 : vid.Height-radius, radius+1 : vid.Width-radius);
    
    bwd2 = im2bw(diff2, .3);
    d2 = bwd2.*nhf;
    orig_d2 = d2;
    
    % copy previous frame key status
    notestoplay(count, :) = notestoplay(count - 1, :);
    
    % remove non vertical lines
    
    filt = ones(15, 1);
    filtered = conv2(d2, filt, 'same');
    
    d2(:, max(filtered) < 12) = 0;
    
    
    
    bin_width = 10;
    bin2 = ones(size(d2, 1), bin_width);
    con = conv2(d2, bin2, 'same');
    
    m_sum = sum(con);
    [lval, locs] = findpeaks(m_sum, 'SortStr', 'descend', 'MinPeakDistance', 12);
    presses = zeros(size(peaks, 1), 1);
    
    if (~isempty(find(count == 69:72, 1)))
        5;
    end
    
    if (  numel(locs) < 10) % discard if too many lines
        rows = [];
        for j = 1:numel(locs)
            location = locs(j);
            % max(filtered(:, locs(j)))
            if m_sum(location) > 20000
                
                % find closest
                
                peaks_copy = peaks;
                [row, col] = find(abs(peaks_copy-location) == min(min(abs(peaks_copy-location))));
                row1 = row(1); col1 = col(1);
                peaks_copy(row1, :) = -1;
                [row, col] = find(abs(peaks_copy-location) == min(min(abs(peaks_copy-location))));
                row2 = row(1); col2 = col(1);
                rows = [rows; [row1 row2]];
                
                            
%                 subplot(2,1,1)
%                 imshow(orig_d2);
%                 str = sprintf('frame: %i, max: %i, sum: %i', count, max(d2), sum(d2));
%                 title(str);
%                 subplot(2,1,2)
%                 plot(m_sum)
%                 ylim([0 10^5])
                
        
            end
        end
        for i = 1:size(rows, 1)
            cur_row = rows(i, :);
            for j = i+1:size(rows, 1)
                next_row = rows(j, :);
                intersec = intersect(cur_row, next_row);
                if ~isempty(intersec)
                    presses(intersec) = 1;
                end
            end
        end
        [presses, ~] = find(presses ~= 0);
        if ~isempty(presses)
            presses
            map{presses, 1}
            count
            subplot(2,1,1);
            imshow(orig_d2);
            str = sprintf('frame: %i, max: %i, sum: %i', count, max(d2), sum(d2));
            title(str);
            subplot(2,1,2)
            plot(m_sum)
            ylim([0 10^5]);
            %input('continue');
        end
        for i = 1:size(presses, 1)
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
    end
  
    
    
    % release any keys that have been on for too long
     to_release = find(and((notestoplay(count, :) > 0), (count - last_pressed > RELEASE_TIME)) > 0);
     last_released(to_release) = count;
     notestoplay(count, to_release) = 0;
     
    %input('continue ');
    drawnow;
    if (~isempty(find(count == 1, 1)))
        subplot(2,1,1);
        imshow(orig_d2);
        str = sprintf('frame: %i, max: %i, sum: %i', count, max(d2), sum(d2));
        title(str);
        subplot(2,1,2)
        plot(m_sum)
        ylim([0 10^5]);
    end
        
    count = count +1;
end

% play(notestoplay);