%% KEYPRESS DETECTION

function keys = keypress(map, diff, stabrad)

n = size(map);
keycorr = zeros(1, n(1));
black = ones(1, n(1));
keys = [];

% figure out which are the black keys
for i = 1:n(1)
    if isempty(strfind(map{i,1}, 'b'))
        black(i) = 0;
    end
end

% zero pad diff image
diff = padarray(diff, [stabrad stabrad], 'both');

% correlate the frames, get correlation sum
for i = 1:n(1)
    framecorr = and(map{i,2}, diff);
    keycorr(i) = sum(sum(framecorr));
end

% keycorr

% find local maxima in the correlation vector
[pks, loc] = findpeaks(keycorr);
for i = 1:numel(loc)
    if black(loc(i)) == 1
        if keycorr(loc+2) ~= 0
            loc(i) = loc(i)+1;
        end
    end
    if pks(i) > 100 % only get peaks that are clearly keypresses
        keys = [keys; loc(i)];
    end
end
pks
loc

figure
plot(keycorr)