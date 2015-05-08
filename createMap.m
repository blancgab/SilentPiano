% Create Mapping of Location, Pitch Value

close all

vid = VideoReader(fullfile('videos','TwoHanded.mov'));

f = readFrame(vid);
g = rgb2gray(f);
g = im2bw(g, 1.4*graythresh(g));
% imshow(g)

%% PROCESSING THE IMAGE

% remove fine details
g = imopen(imclose(g,ones(3,2)),ones(3,2));
% remove reflective edges on black keys
g = imopen(g,ones(150,1));
imshow(g)

% isolation of keys via horizontal edges
hbounds = sum(edge(double(g), 'canny', 'horizontal'), 2);
[temp, pos] = sort(hbounds(1:vid.Height-2), 'descend');
h_n = temp(1:2);
h_p = pos(1:2);

% edge detection, invert, fill keys, remove background
g  = imcomplement(edge(double(g), 'canny'));
g = imopen(g,ones(20));
g = imerode(g,ones(2));
g(1:pos(2),:) = 0;
g(pos(1)-5:vid.Height,:) = 0;
% figure
imshow(g)

%% FINDING THE BOUNDARIES

[B, L, N, A] = bwboundaries(g, 'noholes');
figure
imshow(f)
hold on;
for i = 1:N
    b = B{i};
    plot(b(:,2),b(:,1),'g','Linewidth',2);
    col = b(1,2); row = b(1,1);
    h = text(col+25, row+25, num2str(L(row,col)));
    set(h,'Color','g','FontSize',14,'FontWeight','bold');
end

% mapping the labels to note names
% hard code for now
L(L==1) = 'C5';
L(L==2) = 'B4';
L(L==3) = 'Bb4';
L(L==4) = 'A4';
L(L==5) = 'Ab4';
L(L==6) = 'G4';
L(L==7) = 'Gb4';
L(L==8) = 'F4';
L(L==9) = 'E4';
L(L==10) = 'Eb4';
L(L==11) = 'D4';
L(L==12) = 'Db4';
L(L==13) = 'C4';
L(L==14) = 'B3';
L(L==15) = 'Bb3';
L(L==16) = 'A3';
L(L==17) = 'Ab3';
L(L==18) = 'G3';
L(L==19) = 'Gb3';
L(L==20) = 'F3';
L(L==21) = 'E3';
L(L==22) = 'Eb3';
L(L==23) = 'D3';
L(L==24) = 'Db3';
L(L==25) = 'C3';
L(L==26) = 'B2';