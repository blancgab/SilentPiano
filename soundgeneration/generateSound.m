% M: input matrix:
%   1     2     3     4     5     6  
% [ track chan  nn    vel   t1    t2 ] (any more cols ignored...)

C = expectedResults;

kp = zeros(30,6);

[r, ~] = size(kp);

for i=1:r
    kp(i,1) = 1;
    kp(i,2) = 1;
    kp(i,3) = 
    kp(i,4) = 0.5;
end