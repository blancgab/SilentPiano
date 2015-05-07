% Silent Piano

vid = VideoReader(fullfile('videos','TwoHanded.mov'));
figure(1);

vidWidth = vid.Width;
vidHeight = vid.Height;

f = readFrame(vid);
% createMap(f)

while hasFrame(vid)
    
    fprev = f;
    f = readFrame(vid);
    
    diff = abs(f-fprev);
    
    subplot(2,1,1);
    imshow(f);
    
    subplot(2,1,2);
    nhf = noHandsFilter(f);
    se = ones(4,1);
    bwd = im2bw(diff,.2);
    imshow(bwd.*nhf);    
    
    drawnow;
end