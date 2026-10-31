% An arithmetic-average Asian call has no closed form. The geometric-average
% version does, and its payoff tracks the arithmetic one closely, so it makes
% a control variate that cuts the error for the same number of paths.
rng(7);
S0 = 100;  K = 100;  r = 0.05;  sigma = 0.2;  T = 1;  N = 252;  n = 100000;
dt = T / N;
incr = (r - 0.5*sigma^2)*dt + sigma*sqrt(dt)*randn(n, N);
logS = log(S0) + cumsum(incr, 2);
arith = exp(-r*T) * max(mean(exp(logS), 2) - K, 0);
geo = exp(-r*T) * max(exp(mean(logS, 2)) - K, 0);

% Closed form for the discretely monitored geometric average.
sg = sigma * sqrt((N + 1)*(2*N + 1) / (6*N^2));
mg = (r - 0.5*sigma^2)*(N + 1)/(2*N) + 0.5*sg^2;
d1 = (log(S0/K) + (mg + 0.5*sg^2)*T) / (sg*sqrt(T));
geo_exact = exp(-r*T) * (S0*exp(mg*T)*normcdf(d1) - K*normcdf(d1 - sg*sqrt(T)));

c = cov(arith, geo);
b = c(1, 2) / c(2, 2);
adjusted = arith - b * (geo - geo_exact);
fprintf('plain estimate %.4f, standard error %.4f\n', mean(arith), std(arith)/sqrt(n));
fprintf('with the control variate %.4f, standard error %.4f (variance %.0f times smaller)\n', mean(adjusted), std(adjusted)/sqrt(n), var(arith)/var(adjusted));

shown = 1:3000;
scatter(geo(shown), arith(shown));
title('Arithmetic against geometric payoff');
xlabel('Geometric-average payoff');
ylabel('Arithmetic-average payoff');
