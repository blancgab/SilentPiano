% Silent Piano

vid = VideoReader(fullfile('videos','TwoHanded.mov'));
figure(1);

f = readFrame(vid);

while hasFrame(vid)
    fprev = f;
    f = readFrame(vid);
    imshow(f);
    input('Press any key to continue');
end