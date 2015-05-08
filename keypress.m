n = 2; %one frame each time
m = 2;%bins
vid = VideoReader(fullfile('videos','TwoHanded.mov'));
init_frame = readFrame(vid);
nhf1 = noHandsFilter(init_frame);
[row, col, high] = size(init_frame);
location = zeros(1, col);
count = 1;
figure;
while hasFrame(vid)
    for j = 1:n
        if j == n
            final_frame = readFrame(vid);
            nhf2 = noHandsFilter(final_frame);
        else
            readFrame(vid);
        end
    end
    diff = rgb2gray(init_frame - final_frame);
    nhf = (nhf1.*nhf2);
    diff_frame = diff.*nhf;
    d1 = sum(diff_frame);
    d2 = zeros(1,floor(1280/m));
    for i = 1:floor(1280/m)
        d2(1,i) = d1(1,m*i-1)+ d1(1,m*i); %2 col each bin
        %d2(1,i) = d1(1,m*i-1)+ d1(1,m*i-2)+ d1(1,m*i); %3 col each bin
    end
    d1max = max(d1);
    max_index1 = find(d1 == max(d1));
    d2max = max(d2);
    max_index2 = find(d2 == max(d2));
    location(1,count)= max_index2(1);
    imshow(diff_frame);
    init_frame = final_frame;
    nhf1 = nhf2;
    count = count +1;
    input('Press any key to continue');
    display(count);
end
plot(location);
% subplot(1,2,1);
% plot(d1);
% subplot(1,2,2);
% plot(d2);
