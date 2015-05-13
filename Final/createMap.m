% KEYMAP FUNCTION

function map = createMap(firstFrame, vidHeight)

close all
addpath('stabilization');

g = rgb2gray(firstFrame);
g = im2bw(g, 1.4*graythresh(g));
% imshow(g)

%% PROCESSING THE IMAGE

% remove fine details
g = imopen(imclose(g,ones(3,2)),ones(3,2));
% remove reflective edges on black keys
g = imopen(g,ones(150,1));

% isolation of keys via horizontal edges
hbounds = sum(edge(double(g), 'canny', 'horizontal'), 2);
hbins = zeros(vidHeight/5,1);
for i = 1:vidHeight/5
    hbins(i) = sum(hbounds(5*i-4:5*i));
end
[temp, pos] = sort(hbins(1:size(hbins)-1), 'descend');
p = pos(1:2);

% edge detection, invert, fill keys, remove background
g  = imcomplement(edge(double(g), 'canny'));
g = imopen(g,ones(20));
g = imerode(g,ones(2));
g(1:min(p)*5,:) = 0;
g(max(p)*5-10:vidHeight,:) = 0;

% figure
% imshow(g)

%% FINDING THE BOUNDARIES & MAPPING NOTE NAMES

[B, L, N, A] = bwboundaries(g, 'noholes');
map = cell(N,2);
names = cellstr(['B ';'Bb';'A ';'Ab';'G ';'Gb';'F ';'E ';'Eb';'D ';'Db';'C ']);

% find key where the keys 2, 4, and 6 spaces away are all black. this is C.
for i = 1:N-6
    key = numel(B{i});
    if key > 1.3*numel(B{i+2}) && key > 1.3*numel(B{i+4}) && key > 1.3*numel(B{i+6})
        break;
    end
end

% if this C key is sufficiently far left, probably a C5, otherwise C4
if i < 6
    octave = 5;
else
    octave = 4;
end

% now map everything else to the left and right of this C.
for j = 1:i
    map{j,1} = strcat(names(12-(i-j)),num2str(octave));
end
octave = octave - 1; % down 1 octave to right of C
k = 1;
for j = i+1:N
    map{j,1} = strcat(names(k),num2str(octave));
    k = k + 1;
    if k == 13
        k = 1;
        octave = octave - 1;
    end
end

figure % show keymap
imshow(firstFrame)
hold on;
for i = 1:N
    b = B{i};
    plot(b(:,2),b(:,1),'g','Linewidth',2);
    col = b(1,2); row = b(1,1);
    h = text(col+10, row+10, map{i,1});
    set(h,'Color','g','FontSize',14,'FontWeight','bold');
end

%% CREATE MASKS

% first column of map cell was the note name.
% second column is the dilated masks.
for i = 1:N
    map{i,2} = zeros(size(L));
    map{i,2}(L==i) = 1;
   % map{i,2} = imdilate(map{i,2},ones(20));
    map{i,2} = imdilate(map{i,2},ones(6));

end
% figure
% imshow(map{26,2})