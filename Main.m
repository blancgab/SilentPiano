% Silent Piano

vid = VideoReader(fullfile('videos','TwoHanded.mov'));
figure(1);

vidWidth = vid.Width;
vidHeight = vid.Height;
hf = figure;
set(hf,'position',[150 150 vidWidth vidHeight]);

%f = readFrame(vid);

% while hasFrame(vid)
%     fprev = f;
%     f = readFrame(vid);
%     imshow(f);
%     input('Press any key to continue');
% end

diffFrames(vid, 1);

