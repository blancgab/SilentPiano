% Silent Piano

vid = VideoReader(fullfile('videos','TwoHanded.mov'));
addpath('stabilization');
figure(1);

vidWidth = vid.Width;
vidHeight = vid.Height;

init_frame = readFrame(vid);
temp = load('template.mat');
[~, ~, stable_init] = stabilize_frame(init_frame, temp, 3);
% createMap(f)

n = 2;

while hasFrame(vid)
    
    for i = 1:n
        if i == n
            final_frame = readFrame(vid);
            [~, ~, final_stable] = stabilize_frame(final_frame, temp, 3);
        else
            readFrame(vid);
        end
    end
    
    diff = padarray(abs(final_stable-stable_init),[3 3],'both');
    
%     subplot(2,1,1);
%     imshow(final_frame);
%     
%     subplot(2,1,2);

    subplot(2,1,1)
    nhf = noHandsFilter(final_frame,0.5,24);
%    se = ones(4,1);
    bwd = im2bw(diff,graythresh(diff)+0.2);
    imshow(bwd.*nhf);   
    
    bins = [1 10;
           45 55;
           93 103;
           141 151;
           189 199;
           237 247;
           285 295;
           333 343;
           381 391;
           429 439;
           477 487;
           525 535;
           573 583;
           621 631;
           669 679;
           717 727;
           765 775;
           813 823;
           861 871;
           909 919;
           958 968;
           1006 1016;
           1053 1063;
           1102 1112;
           1150 1160;
           1198 1208];
    

    S = sum(bwd(150:600,:));
    bin_sum = zeros(26,1);
    for i = 1:26
        for j = bins(i,1):bins(i,2)
            bin_sum(i) = bin_sum(i) + S(j);
        end
    end
    subplot(2,1,2)
    plot(bin_sum)
    ylim([0 1000])
    stable_init = final_stable;
    
    drawnow;
end