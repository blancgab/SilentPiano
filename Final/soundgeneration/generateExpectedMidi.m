% M: input matrix:
%   1     2     3     4     5     6  
% [ track chan  nn    vel   t1    t2 ] (any more cols ignored...)

C = expectedMidiMatrix;
m = matrix2midi(C);
writemidi(m, 'expected.midi');