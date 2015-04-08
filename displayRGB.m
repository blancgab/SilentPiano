function displayRGB(frame)
%RGB Summary of this function goes here
%   Detailed explanation goes here

subplot(3,1,1);
imshow(frame(:,:,1));
subplot(3,1,2);
imshow(frame(:,:,2));
subplot(3,1,3);
imshow(frame(:,:,3));


end

