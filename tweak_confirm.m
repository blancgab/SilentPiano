% confirm new press with previous
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
writemidi(matrix2midi(M), strcat('output', num2str(CONFIRM-1), '.midi'));