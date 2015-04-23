function diffFrames( vid, n) 

init_frame = readFrame(vid);

while hasFrame(vid)
    for i = 1:n
        if i == n
            final_frame = readFrame(vid);
        else
            readFrame(vid);
        end
    end
    imshow(init_frame - final_frame);
    init_frame = final_frame;
    input('Press any key to continue');
end
end


