function Yt = generalized_logistic_function(t, B, A, K, v, Q, C, M)

% A = lower asymptote
% K = upper asymptote
% B = growth rate
% v = defines asymptote to which the function grows
% Q = Y(0)
% C = typically is 1

if nargin < 2
    A = 0;
    K = 1;
    B = 3;
    v = 0.5;
    Q = 0.5;
    C = 1;
    M = 0;
end

Yt = A + (K - A) / ((C + Q*exp(-B*(t-M))) ^(1/v));


