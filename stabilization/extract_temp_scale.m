function extract_temp_scale(filename, scale, show)
if nargin < 3
    show = 1;
end

if nargin < 2
  scale = 4;
end
% extract casio
%vid = VideoReader(fullfile('../videos','TwoHanded.mov'));
vid = VideoReader(filename);
img = readFrame(vid);

col0 = scale*305 - 1; col1 = scale*445 - 1;
row0 = scale*625 - 1; row1 = scale * 645-1;

%img = imread('frame0.bmp');
f1_bw = rgb2gray(img);
img = imresize(f1_bw, scale, 'bicubic');




template = img(row0:row1, col0:col1);
save('template.mat', 'template', 'col0', 'row0');
if show
    h = figure;
    imshow(img);
    rectangle('Position', [col0 row0 col1-col0 row1-row0])

    frm = getframe(h); imwrite(frm.cdata, 'framedCasio.bmp');
    imshow(template);
end

end


