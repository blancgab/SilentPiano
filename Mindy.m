% Silent Piano

temp = load('template.mat');
vid = VideoReader(fullfile('videos','TwoHanded.mov'));
figure(1);

vidWidth = vid.Width;
vidHeight = vid.Height;

f = readFrame(vid);
[ x, y, fs ] = stabilize_frame( f, temp, 2 );
% createMap(f)
m = 2;
count = 1;
while hasFrame(vid)
    
    fprev = f;
    fprevs = fs;
    f = readFrame(vid);
    [ x, y, fs ] = stabilize_frame( f, temp, 2 );
    nh = noHandsFilter(f);
    nhf = nh(3:718,3:1278);
    diff = abs(fs-fprevs);
      
    %se = ones(4,1);
    bwd = im2bw(diff,.2);
    d = bwd.*nhf;
    d1 = sum(d);
%     for i = 1:floor(1276/m)
%         d2(1,i) = d1(1,m*i-1)+ d1(1,m*i); %2 col each bin
%         %d2(1,i) = d1(1,m*i-1)+ d1(1,m*i-2)+ d1(1,m*i); %3 col each bin
%     end
    subplot(2,1,1);
    imshow(fs); 
    str = sprintf('%f ',count);
    title(str);
    subplot(2,1,2);
    %imshow(d1);
    plot(d1);
    ylim([0, 200]);
    
    drawnow;
    count = count +1;
end

% m = [7;1;4;4;12;2;6;10;2];
% [temp,originalpos] = sort( m, 'descend' );
% n = temp(1:3);
% p=originalpos(1:3);