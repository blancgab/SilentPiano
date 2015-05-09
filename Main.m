% Silent Piano

temp = load('template.mat');
vid = VideoReader(fullfile('videos','TwoHanded.mov'));
addpath('stabilization');
figure(1);

f = readFrame(vid);
[ x, y, fs ] = stabilize_frame( f, temp, 2 );
[masks, map] = createMap(f, vid.Height);
m = 2;
count = 1;
figure

while hasFrame(vid)
    
    fprev = f;
    fprevs = fs;
    f = readFrame(vid);
    [ x, y, fs ] = stabilize_frame( f, temp, 2 );
    nh = noHandsFilter(f);
    nhf = nh(3:718,3:1278);
    diff = abs(fs-fprevs);
      
    se = ones(4,1);
    bwd = im2bw(diff,.2);
    d = bwd.*nhf;
    d1 = sum(d);
    for i = 1:floor(1276/m)
        d2(1,i) = d1(1,m*i-1)+ d1(1,m*i); %2 col each bin
        %d2(1,i) = d1(1,m*i-1)+ d1(1,m*i-2)+ d1(1,m*i); %3 col each bin
    end
    subplot(2,1,1);
    imshow(fs); 
    str = sprintf('%f ',count);
    title(str);
    subplot(2,1,2);
    %imshow(d1);
    plot(d2);
    ylim([0, 200]);
    
    drawnow;
    count = count +1;
end

% m = [7;1;4;4;12;2;6;10;2];
% [temp,originalpos] = sort( m, 'descend' );
% n = temp(1:3);
% p=originalpos(1:3);

% init_frame = readFrame(vid);
% temp = load('template.mat');
% [~, ~, stable_init] = stabilize_frame(init_frame, temp, 3);
% [B, map] = createMap(init_frame, vid.Height);
% 
% n = 2;
% figure

% while hasFrame(vid)
%     
%     for i = 1:n
%         if i == n
%             final_frame = readFrame(vid);
%             [~, ~, final_stable] = stabilize_frame(final_frame, temp, 3);
%         else
%             readFrame(vid);
%         end
%     end
%     
%     diff = padarray(abs(final_stable-stable_init),[3 3],'both');
%     
% %     subplot(2,1,1);
% %     imshow(final_frame);
% %     
% %     subplot(2,1,2);
% 
%     %subplot(2,1,1)
%     nhf = noHandsFilter(final_frame,0.5,24);
% %    se = ones(4,1);
%     bwd = im2bw(diff,graythresh(diff)+0.2);
%     imshow(bwd.*nhf);   
%     
%     drawnow;
% end