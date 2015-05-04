% extract casio
h = figure;
col0 = 305; col1 = 445;
row0 = 625; row1 = 645;
img = imread('frame0.bmp');
imshow(img);
rectangle('Position', [col0 row0 col1-col0 row1-row0])

frm = getframe(h); imwrite(frm.cdata, 'framedCasio.bmp');

f1_bw = rgb2gray(img);

template = f1_bw(row0:row1, col0:col1);
save('template.mat', 'template', 'col0', 'row0');
imshow(template)



