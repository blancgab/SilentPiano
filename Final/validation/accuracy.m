function [ out ] = accuracy(C ,M )
%UNTITLED3 Summary of this function goes here
%   Output include 2 column, col 1: 1 if match, 0 if unmatch
%                            col 2: duration different from the expected 
%M =[ 1, 1, 73-i, 120, startframe/29.97, endframe/29.97];

[h w] = size(M); % h = 62
[hc wc] = size(C); % hc = 45
out = zeros(hc,3);

    for i = 1: hc
        for j = 1:h
            if (C(i,3)==M(j,3))
                frame_diff = abs(floor((M(j,5)*29.97)- (C(i,5)*29.97)));
                if(frame_diff <5)
                   out(i,1) = 1;
                   out(i,3) = abs(M(j,5)- C(i,5));
                   out(i,2) = frame_diff;
                end          
             end
         end
    end
   
     for k = 1:hc
         if (out(k,1) == 0)
             for l = 1:h
                if(C(k,3)==(M(l,3)-1) || C(i,3)==(M(l,3)+1)) % missing by 1 note
                    frame_diff2 = abs(floor((M(l,5)*29.97)- (C(k,5)*29.97)));
                    if(frame_diff2 <5)
                     out(k,1) = 2;
                    end
                end
             end
         end 
     end
end
% 
% elseif (C(i,3)==(M(j,3)-1) || C(i,3)==(M(j,3)+1)) % missing by 1 note
%                  frame_diff = abs(floor((M(j,5)*29.97)- (C(i,5)*29.97)));
%                     if(frame_diff <5)
%                      out(i,1) = 2;
%                     end 

% %Evaluation section
% C = expectedMidiMatrix();
% out = accuracy(C,M);
% result = cat(2,C,out);