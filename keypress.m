%% KEYPRESS DETECTION

function keys = keypress(map, diff, stabrad)

n = size(map);
keycorr = zeros(1, n(1));
black = zeros(1, n(1));
keys = [];

% figure out which are the black keys
for i = 1:n(1)
    bkey = strfind(map{i,1}, 'b');
    if bkey{1} == 2
        black(i) = 1;
    end
end

% find where the black key ends
for i = 1:3
    if black(i) == 1
        [row1, col1] = find(map{i,2}, 1);
        break
    end
end
for i = n(1):-1:n(1)-2
    if black(i) == 1
        [row2, col2] = find(map{i,2}, 1);
        break
    end
end
topofblack = min(row1, row2);

% zero pad diff image
diff = padarray(diff, [stabrad stabrad], 'both');
% generate diff of white keys only too
diffwhite = zeros(size(diff));
diffwhite(1:topofblack-5, :) = diff(1:topofblack-5, :);

% correlate the frames, get correlation sum
for i = 1:n(1)
    framecorr = and(map{i,2}, diff);
    keycorr(i) = sum(sum(framecorr));
end

% keycorr

% find local maxima in the correlation vector
[pks, loc] = findpeaks(keycorr);
for i = 1:numel(loc)
    % adjust for left side of frame
    if black(loc(i)) == 1 && loc(i) < n(1)/2
        if keycorr(loc(i)+2) > 10
            loc(i) = loc(i)+1;
        elseif sum(sum(and(map{loc(i)+1,2}, diffwhite))) > 10
            loc(i) = loc(i)+1;
        end
    end
    if pks(i) > 150 % only get peaks that are clearly keypresses
        keys = [keys; loc(i)];
    end
end
keycorr
pks
loc

% figure
plot(keycorr)