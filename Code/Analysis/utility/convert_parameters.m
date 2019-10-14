
% convert mean and variance of beta distribution to its parameters a and b
syms a b mu sigma;

eqn1 = mu == a / b;
eqn2 = sigma2 == a  /(b^2);

sol = solve([eqn1, eqn2], [a, b]);