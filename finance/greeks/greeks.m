% Delta and gamma from the Black-Scholes formulas, checked against blsprice
K = 100;  r = 0.03;  sigma = 0.25;
S = (50:1:150)';
T = [0.1 0.5 1];

d1 = (log(S / K) + (r + sigma^2/2) * T) ./ (sigma * sqrt(T));
delta = normcdf(d1);
gamma = normpdf(d1) ./ (S * sigma .* sqrt(T));

subplot(2, 1, 1);
plot(S, delta);
title('Call delta');
xlabel('Spot');
ylabel('Delta');
legend('0.1 years', '0.5 years', '1 year');
subplot(2, 1, 2);
plot(S, gamma);
title('Gamma');
xlabel('Spot');
ylabel('Gamma');

h = 0.01;
fd = (blsprice(100 + h, K, r, 1, sigma) - blsprice(100 - h, K, r, 1, sigma)) / (2*h);
fprintf('Delta at the money, one year: %.4f (from blsprice: %.4f)\n', delta(S == 100, 3), fd);
fprintf('Gamma at the money, 0.1 years: %.4f\n', gamma(S == 100, 1));
