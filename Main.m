% Silent Piano

vid = VideoReader(fullfile('videos','ShortZelda.mp4'));
figure(1);
while hasFrame(vid)
    f = readFrame(vid);
    displayRGB(f);
    input('Press any key to continue');
end