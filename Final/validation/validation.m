%% Validation Display

clear; clc;

vid = VideoReader(fullfile('videos','TwoHanded.mov'));
NumberOfFrames = ceil(vid.FrameRate * vid.Duration);
figure(1);


%% Display

C = expectedResults;

f = readFrame(vid);
map = createMap(f,vid.Height);

num_keys = size(map,1);

masks = cell(num_keys,1);

for i=1:size(map,1)
    masks{i} = map{i,2};
end


for i = 1:NumberOfFrames
    
    f = rgb2gray(readFrame(vid));
    
    if (C(i) == 0)
        str = sprintf('FRAME %d)',i); 
        imshow(f);            
    else        
        str = sprintf('FRAME %d) %d',i,C(i,1,1));
        m = masks{73-C(i,1,1)};
        imshow(f.*uint8(m));    
    end    
    
    title(str);      
    
    drawnow;
end